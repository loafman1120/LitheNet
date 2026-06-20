import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../data/models/subscription.dart';

class SubscriptionsController extends ChangeNotifier {
  List<Subscription> _subscriptions = [];
  final bool _busy = false;

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);
  bool get busy => _busy;

  Subscription? get activeSubscription {
    try {
      return _subscriptions.firstWhere((s) => s.enabled);
    } catch (_) {
      return null;
    }
  }

  void addSubscription(String url, {String? name}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final sub = Subscription(
      id: id,
      name: name ?? 'Subscription ${_subscriptions.length + 1}',
      url: url,
      lastUpdatedAt: DateTime.now(),
    );
    _subscriptions.add(sub);
    notifyListeners();
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

  void updateSubscription(String id) {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index < 0) return;
    _subscriptions[index] = _subscriptions[index].copyWith(
      lastUpdatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<bool> importFromClipboard(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAbsolutePath) return false;

    addSubscription(trimmed);
    return true;
  }

  String exportSubscriptions() {
    final data = _subscriptions
        .map((s) => {
              'id': s.id,
              'name': s.name,
              'url': s.url,
              'enabled': s.enabled,
            })
        .toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void importFromJson(String json) {
    try {
      final list = jsonDecode(json) as List;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final url = map['url'] as String?;
        if (url != null) {
          addSubscription(
            url,
            name: map['name'] as String?,
          );
        }
      }
    } catch (_) {
      // ignore malformed data
    }
  }
}
