import 'dart:convert';

import '../../../data/models/subscription.dart';
import '../../../data/storage/json_file_store.dart';
import '../../../data/storage/secret_store.dart';

abstract class SubscriptionListStore {
  Future<List<Subscription>> load();
  Future<void> save(List<Subscription> subscriptions);
}

class SecureSubscriptionListStore implements SubscriptionListStore {
  SecureSubscriptionListStore(this._store, this._secrets);

  static const _secretKey = 'subscriptions.v1';

  final JsonFileStore _store;
  final SecretStore _secrets;

  @override
  Future<List<Subscription>> load() async {
    final encoded = await _secrets.read(_secretKey);
    if (encoded != null) {
      return _decode(encoded);
    }

    final legacy = await _store.readObject();
    if (legacy == null) {
      return const [];
    }
    final subscriptions = _subscriptionsFrom(legacy);
    await save(subscriptions);
    return subscriptions;
  }

  @override
  Future<void> save(List<Subscription> subscriptions) async {
    await _secrets.write(
      _secretKey,
      jsonEncode({
        'version': 1,
        'subscriptions': [
          for (final subscription in subscriptions) subscription.toJson(),
        ],
      }),
    );
    if (await _store.file.exists()) {
      await _store.file.delete();
    }
  }

  List<Subscription> _decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw const FormatException('Invalid secure subscription list.');
    }
    return _subscriptionsFrom(Map<String, dynamic>.from(decoded));
  }

  List<Subscription> _subscriptionsFrom(Map<String, dynamic> data) {
    return [
      for (final item in data['subscriptions'] as List? ?? const [])
        if (item is Map) Subscription.fromJson(Map<String, dynamic>.from(item)),
    ];
  }
}

class MemorySubscriptionListStore implements SubscriptionListStore {
  MemorySubscriptionListStore([List<Subscription> initial = const []])
    : _subscriptions = List.of(initial);

  List<Subscription> _subscriptions;

  @override
  Future<List<Subscription>> load() async => List.of(_subscriptions);

  @override
  Future<void> save(List<Subscription> subscriptions) async {
    _subscriptions = List.of(subscriptions);
  }
}
