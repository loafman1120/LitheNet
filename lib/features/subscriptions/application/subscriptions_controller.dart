import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../data/models/subscription.dart';
import '../../proxies/application/proxy_catalog.dart';
import '../data/subscriptions_repository.dart';

class SubscriptionsController extends ChangeNotifier {
  SubscriptionsController({
    SubscriptionRepository? repository,
  }) : _repository = repository ?? DefaultSubscriptionRepository();

  final SubscriptionRepository _repository;
  ProxyCatalog? _proxyCatalog;
  List<Subscription> _subscriptions = [];
  bool _busy = false;

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);
  bool get busy => _busy;

  Subscription? get activeSubscription {
    try {
      return _subscriptions.firstWhere((s) => s.enabled);
    } catch (_) {
      return null;
    }
  }

  void bindProxyCatalog(ProxyCatalog catalog) {
    _proxyCatalog = catalog;
  }

  Future<void> addSubscription(String url, {String? name}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final sub = Subscription(
      id: id,
      name: name ?? 'Subscription ${_subscriptions.length + 1}',
      url: url,
    );
    _subscriptions.add(sub);
    notifyListeners();
    await updateSubscription(id);
  }

  void removeSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void renameSubscription(String id, String newName) {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    _subscriptions[index] = _subscriptions[index].copyWith(name: newName);
    notifyListeners();
  }

  void setActive(String id) {
    _subscriptions = _subscriptions.map((s) {
      return s.copyWith(enabled: s.id == id);
    }).toList();
    notifyListeners();
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
    if (profile != null && result.profileChanged) {
      _proxyCatalog?.replaceFromProfile(profile);
    }
    _busy = _subscriptions.any(
      (subscription) =>
          subscription.updateStatus == SubscriptionUpdateStatus.updating,
    );
    notifyListeners();
  }

  Future<bool> importFromClipboard(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAbsolutePath) return false;

    await addSubscription(trimmed);
    return true;
  }

  String exportSubscriptions() {
    final data = _subscriptions.map((s) => s.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void importFromJson(String json) {
    try {
      final list = jsonDecode(json) as List;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final url = map['url'] as String?;
        if (url != null) {
          _subscriptions.add(Subscription.fromJson(map));
        }
      }
      notifyListeners();
    } catch (_) {
      // ignore malformed data
    }
  }
}
