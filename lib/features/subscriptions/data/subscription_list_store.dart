import '../../../data/models/subscription.dart';
import '../../../data/storage/json_file_store.dart';

abstract class SubscriptionListStore {
  Future<List<Subscription>> load();
  Future<void> save(List<Subscription> subscriptions);
}

class FileSubscriptionListStore implements SubscriptionListStore {
  const FileSubscriptionListStore(this._store);

  final JsonFileStore _store;

  @override
  Future<List<Subscription>> load() async {
    final data = await _store.readObject();
    if (data == null) {
      return const [];
    }
    return [
      for (final item in data['subscriptions'] as List? ?? const [])
        if (item is Map) Subscription.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  @override
  Future<void> save(List<Subscription> subscriptions) {
    return _store.writeObject({
      'version': 1,
      'subscriptions': [
        for (final subscription in subscriptions) subscription.toJson(),
      ],
    });
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
