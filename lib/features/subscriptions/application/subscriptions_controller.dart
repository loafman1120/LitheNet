import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../data/models/subscription.dart';
import '../../proxies/application/proxy_catalog.dart';
import '../data/profile_store.dart';
import '../data/subscription_list_store.dart';
import '../data/subscription_url_normalizer.dart';
import '../data/subscriptions_repository.dart';

class SubscriptionsController extends ChangeNotifier {
  SubscriptionsController({
    SubscriptionRepository? repository,
    SubscriptionListStore? store,
    AtomicProfileStore? profileStore,
    List<Subscription> initialSubscriptions = const [],
  }) : _subscriptions = List.of(initialSubscriptions) {
    final effectiveProfileStore = profileStore ?? InMemoryProfileStore();
    _profileStore = effectiveProfileStore;
    _store = store ?? MemorySubscriptionListStore(initialSubscriptions);
    _repository = repository ??
        DefaultSubscriptionRepository(
          store: effectiveProfileStore,
        );
  }

  late final SubscriptionRepository _repository;
  late final SubscriptionListStore _store;
  late final AtomicProfileStore _profileStore;
  final SubscriptionUrlNormalizer _urlNormalizer =
      const SubscriptionUrlNormalizer();
  ProxyCatalog? _proxyCatalog;
  List<Subscription> _subscriptions;
  bool _busy = false;
  String? _lastError;

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);
  bool get busy => _busy;
  String? get lastError => _lastError;

  Subscription? get activeSubscription {
    try {
      return _subscriptions.firstWhere((s) => s.enabled);
    } catch (_) {
      return null;
    }
  }

  void bindProxyCatalog(ProxyCatalog catalog) {
    _proxyCatalog = catalog;
    _restoreActiveProfile();
  }

  Future<void> load() async {
    try {
      _subscriptions = await _store.load();
      _lastError = null;
      notifyListeners();
      await _restoreActiveProfile();
    } on Object catch (error) {
      _lastError = 'Failed to load subscriptions: $error';
      notifyListeners();
    }
  }

  Future<bool> addSubscription(String url, {String? name}) async {
    final normalizedUrl = _urlNormalizer.normalize(url);
    if (normalizedUrl == null) {
      _lastError = 'Unsupported subscription link.';
      notifyListeners();
      return false;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final normalizedName = name?.trim();
    final sub = Subscription(
      id: id,
      name: normalizedName == null || normalizedName.isEmpty
          ? 'Subscription ${_subscriptions.length + 1}'
          : normalizedName,
      url: normalizedUrl,
    );
    _subscriptions.add(sub);
    _lastError = null;
    notifyListeners();
    try {
      await _persist();
    } on Object catch (error) {
      _lastError = 'Failed to save subscription: $error';
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _subscriptions[index] = _subscriptions[index].copyWith(
          updateStatus: SubscriptionUpdateStatus.failed,
          lastError: _lastError,
        );
      }
      notifyListeners();
      return true;
    }
    await updateSubscription(id);
    return true;
  }

  Future<void> removeSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
    await _restoreActiveProfile();
  }

  Future<void> renameSubscription(String id, String newName) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    _subscriptions[index] = _subscriptions[index].copyWith(name: newName);
    await _persist();
    notifyListeners();
  }

  Future<void> setActive(String id) async {
    _subscriptions = _subscriptions.map((s) {
      return s.copyWith(enabled: s.id == id);
    }).toList();
    await _persist();
    notifyListeners();
    await _restoreActiveProfile();
  }

  Future<void> updateSubscription(String id) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    _busy = true;
    _subscriptions[index] = _subscriptions[index].copyWith(
      updateStatus: SubscriptionUpdateStatus.updating,
      lastError: '',
    );
    notifyListeners();

    final result = await _repository.updateOne(_subscriptions[index]);
    final currentIndex =
        _subscriptions.indexWhere((s) => s.id == result.subscription.id);
    if (currentIndex >= 0) {
      _subscriptions[currentIndex] = result.subscription;
    }
    final profile = result.profile;
    if (profile != null) {
      _proxyCatalog?.replaceFromProfile(profile);
    }
    _busy = _subscriptions.any(
      (subscription) =>
          subscription.updateStatus == SubscriptionUpdateStatus.updating,
    );
    _lastError = result.status == SubscriptionUpdateStatus.failed
        ? result.message ?? result.subscription.lastError
        : null;
    try {
      await _persist();
    } on Object catch (error) {
      _lastError = 'Failed to save subscription update: $error';
    }
    notifyListeners();
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
    final data = _subscriptions.map((s) => s.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importFromJson(String json) async {
    try {
      final list = jsonDecode(json) as List;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final url = map['url'] as String?;
        if (url != null) {
          _subscriptions.add(Subscription.fromJson(map));
        }
      }
      await _persist();
      notifyListeners();
    } catch (_) {
      // ignore malformed data
    }
  }

  Future<void> _restoreActiveProfile() async {
    final catalog = _proxyCatalog;
    final subscription = activeSubscription;
    if (catalog == null || subscription == null) {
      return;
    }
    final profile = await _profileStore.currentFor(subscription.id);
    if (profile != null) {
      catalog.replaceFromProfile(profile);
    }
  }

  Future<void> _persist() {
    return _store.save(_subscriptions);
  }
}

class SubscriptionsControllerScope
    extends InheritedNotifier<SubscriptionsController> {
  const SubscriptionsControllerScope({
    required SubscriptionsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SubscriptionsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SubscriptionsControllerScope>();
    assert(scope != null, 'SubscriptionsControllerScope was not found.');
    return scope!.notifier!;
  }
}
