import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/runtime/core_notifier.dart';
import '../../../data/models/subscription.dart';
import '../../proxies/application/proxy_catalog.dart';
import '../data/profile_store.dart';
import '../data/subscription_list_store.dart';
import '../data/subscription_parser.dart';
import '../data/subscription_url_normalizer.dart';
import '../data/subscriptions_repository.dart';

/// Persistence for the subscription list. Override in tests or for file storage.
final subscriptionListStoreProvider = Provider<SubscriptionListStore>(
  (ref) => MemorySubscriptionListStore(),
);

/// Persistence for parsed subscription profiles.
final profileStoreProvider = Provider<AtomicProfileStore>(
  (ref) => InMemoryProfileStore(),
);

/// Fetches and parses a single subscription update.
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => DefaultSubscriptionRepository(store: ref.read(profileStoreProvider)),
);

/// Immutable snapshot of the subscriptions workspace.
@immutable
class SubscriptionsState {
  const SubscriptionsState({
    this.subscriptions = const [],
    this.busy = false,
    this.lastError,
  });

  final List<Subscription> subscriptions;
  final bool busy;
  final String? lastError;

  Subscription? get activeSubscription {
    try {
      return subscriptions.firstWhere((s) => s.enabled);
    } catch (_) {
      return null;
    }
  }

  SubscriptionsState copyWith({
    List<Subscription>? subscriptions,
    bool? busy,
    String? lastError,
    bool clearError = false,
  }) {
    return SubscriptionsState(
      subscriptions: subscriptions ?? this.subscriptions,
      busy: busy ?? this.busy,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

class SubscriptionsNotifier extends Notifier<SubscriptionsState> {
  late final SubscriptionRepository _repository;
  late final SubscriptionListStore _store;
  late final AtomicProfileStore _profileStore;
  final SubscriptionUrlNormalizer _urlNormalizer =
      const SubscriptionUrlNormalizer();
  Future<void> _restoreTail = Future<void>.value();

  /// Completes once the initial load and queued profile restores settle.
  Future<void> get ready => _restoreTail;

  @override
  SubscriptionsState build() {
    _repository = ref.read(subscriptionRepositoryProvider);
    _store = ref.read(subscriptionListStoreProvider);
    _profileStore = ref.read(profileStoreProvider);
    ref.read(coreProvider.notifier).setStartupBarrier(() => ready);
    return const SubscriptionsState();
  }

  Future<void> load() => _loadInitial();

  Future<void> _loadInitial() {
    _restoreTail = _restoreTail.then<void>(
      (_) async {
        try {
          final subscriptions = List.of(await _store.load());
          state = state.copyWith(
            subscriptions: subscriptions,
            clearError: true,
          );
        } on Object catch (error) {
          state = state.copyWith(
            lastError: 'Failed to load subscriptions: $error',
          );
        }
        await _restoreActiveProfile();
      },
      onError: (_, _) => _restoreActiveProfile(),
    );
    return _restoreTail;
  }

  Future<bool> addSubscription(String url, {String? name}) async {
    final normalizedUrl = _urlNormalizer.normalize(url);
    if (normalizedUrl == null) {
      state = state.copyWith(lastError: 'Unsupported subscription link.');
      return false;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final normalizedName = name?.trim();
    final sub = Subscription(
      id: id,
      name: normalizedName == null || normalizedName.isEmpty
          ? 'Subscription ${state.subscriptions.length + 1}'
          : normalizedName,
      url: normalizedUrl,
    );
    state = state.copyWith(
      subscriptions: [...state.subscriptions, sub],
      clearError: true,
    );
    try {
      await _persist();
    } on Object catch (error) {
      state = state.copyWith(lastError: 'Failed to save subscription: $error');
      final index = state.subscriptions.indexWhere((s) => s.id == id);
      if (index >= 0) {
        state = state.copyWith(
          subscriptions: [
            for (var i = 0; i < state.subscriptions.length; i++)
              i == index
                  ? state.subscriptions[i].copyWith(
                      updateStatus: SubscriptionUpdateStatus.failed,
                      lastError: state.lastError,
                    )
                  : state.subscriptions[i],
          ],
        );
      }
      return true;
    }
    await updateSubscription(id);
    return true;
  }

  Future<void> removeSubscription(String id) async {
    state = state.copyWith(
      subscriptions: [
        for (final s in state.subscriptions)
          if (s.id != id) s,
      ],
    );
    await _persist();
    await _scheduleRestore();
  }

  Future<void> renameSubscription(String id, String newName) async {
    final index = state.subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    state = state.copyWith(
      subscriptions: [
        for (var i = 0; i < state.subscriptions.length; i++)
          i == index
              ? state.subscriptions[i].copyWith(name: newName)
              : state.subscriptions[i],
      ],
    );
    await _persist();
  }

  Future<void> setActive(String id) async {
    state = state.copyWith(
      subscriptions: [
        for (final s in state.subscriptions) s.copyWith(enabled: s.id == id),
      ],
    );
    await _persist();
    await _scheduleRestore();
  }

  Future<void> updateSubscription(String id) async {
    final index = state.subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    state = state.copyWith(
      subscriptions: [
        for (var i = 0; i < state.subscriptions.length; i++)
          i == index
              ? state.subscriptions[i].copyWith(
                  updateStatus: SubscriptionUpdateStatus.updating,
                  lastError: '',
                )
              : state.subscriptions[i],
      ],
    );

    final result = await _repository.updateOne(state.subscriptions[index]);
    final currentIndex = state.subscriptions.indexWhere(
      (s) => s.id == result.subscription.id,
    );
    var subscriptions = state.subscriptions;
    if (currentIndex >= 0) {
      subscriptions = [
        for (var i = 0; i < subscriptions.length; i++)
          i == currentIndex ? result.subscription : subscriptions[i],
      ];
    }
    final profile = result.profile;
    if (profile != null && result.subscription.enabled) {
      ref.read(proxyCatalogProvider.notifier).replaceFromProfile(profile);
      await _applyProfileToCore(profile);
    }
    state = state.copyWith(
      subscriptions: subscriptions,
      busy: subscriptions.any(
        (subscription) =>
            subscription.updateStatus == SubscriptionUpdateStatus.updating,
      ),
      lastError: result.status == SubscriptionUpdateStatus.failed
          ? result.message ?? result.subscription.lastError
          : null,
    );
    try {
      await _persist();
    } on Object catch (error) {
      state = state.copyWith(
        lastError: 'Failed to save subscription update: $error',
      );
    }
  }

  Future<bool> importFromClipboard(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    if (!_urlNormalizer.isValid(trimmed)) {
      return false;
    }

    return addSubscription(trimmed);
  }

  String exportSubscriptions() {
    final data = state.subscriptions.map((s) => s.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importFromJson(String json) async {
    try {
      final list = jsonDecode(json) as List;
      final added = <Subscription>[];
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final url = map['url'] as String?;
        if (url != null) {
          added.add(Subscription.fromJson(map));
        }
      }
      if (added.isEmpty) return;
      state = state.copyWith(subscriptions: [...state.subscriptions, ...added]);
      await _persist();
    } catch (_) {
      // ignore malformed data
    }
  }

  Future<void> _restoreActiveProfile() async {
    final catalog = ref.read(proxyCatalogProvider.notifier);
    final subscription = state.activeSubscription;
    final core = ref.read(coreProvider.notifier);
    if (subscription == null) {
      catalog.clear();
      await core.setRawConfig(null);
      await core.setProxyNodes(const []);
      return;
    }
    var profile = await _profileStore.currentFor(subscription.id);
    if (profile != null) {
      catalog.replaceFromProfile(profile);
      await _applyProfileToCore(profile);
    }
  }

  Future<void> _applyProfileToCore(ParsedProfile profile) async {
    final core = ref.read(coreProvider.notifier);
    if (profile.format == SubscriptionFormat.singBoxJson) {
      await core.setRawConfig(profile.rawText);
    } else {
      await core.setRawConfig(null);
      await core.setProxyNodes(profile.nodes);
    }
  }

  Future<void> _scheduleRestore() {
    _restoreTail = _restoreTail.then<void>(
      (_) => _restoreActiveProfile(),
      onError: (_, _) => _restoreActiveProfile(),
    );
    return _restoreTail;
  }

  Future<void> _persist() {
    return _store.save(state.subscriptions);
  }
}

final subscriptionsProvider =
    NotifierProvider<SubscriptionsNotifier, SubscriptionsState>(
      SubscriptionsNotifier.new,
    );
