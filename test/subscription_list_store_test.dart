import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:target/data/models/subscription.dart';
import 'package:target/data/storage/json_file_store.dart';
import 'package:target/data/storage/secret_store.dart';
import 'package:target/features/subscriptions/data/profile_store.dart';
import 'package:target/features/subscriptions/data/subscription_list_store.dart';
import 'package:target/features/subscriptions/data/subscription_parser.dart';

void main() {
  late Directory directory;
  late JsonFileStore jsonStore;
  late MemorySecretStore secretStore;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('Target_secrets');
    jsonStore = JsonFileStore(File('${directory.path}/subscriptions.json'));
    secretStore = MemorySecretStore();
  });

  tearDown(() => directory.delete(recursive: true));

  test('stores the complete subscription list as one secret', () async {
    final store = SecureSubscriptionListStore(jsonStore, secretStore);
    const subscription = Subscription(
      id: 'private-subscription',
      name: 'Private',
      url: 'https://example.com/sub?token=secret',
      headers: {'Authorization': 'Bearer secret'},
    );

    await store.save(const [subscription]);

    expect(await jsonStore.file.exists(), isFalse);
    expect(secretStore.values, hasLength(1));
    expect(secretStore.values.values.single, contains(subscription.url));
    expect(secretStore.values.values.single, contains('Bearer secret'));

    final restored = await SecureSubscriptionListStore(
      jsonStore,
      secretStore,
    ).load();
    expect(restored.single.url, subscription.url);
    expect(restored.single.name, subscription.name);
    expect(restored.single.headers, subscription.headers);
  });

  test('migrates legacy plaintext subscription credentials', () async {
    const subscription = Subscription(
      id: 'legacy-subscription',
      name: 'Legacy',
      url: 'https://example.com/legacy?token=secret',
      headers: {'Authorization': 'Bearer legacy-secret'},
    );
    await jsonStore.writeObject({
      'version': 1,
      'subscriptions': [subscription.toJson()],
    });

    final restored = await SecureSubscriptionListStore(
      jsonStore,
      secretStore,
    ).load();

    expect(restored.single.url, subscription.url);
    expect(await jsonStore.file.exists(), isFalse);
    expect(
      secretStore.values.values.single,
      contains(jsonEncode(subscription.url)),
    );
  });

  test('replaces the single secret when the list changes', () async {
    final store = SecureSubscriptionListStore(jsonStore, secretStore);
    const subscription = Subscription(
      id: 'removed-subscription',
      name: 'Removed',
      url: 'https://example.com/removed',
    );
    await store.save(const [subscription]);

    await store.save(const []);

    expect(secretStore.values, hasLength(1));
    expect(secretStore.values.values.single, isNot(contains(subscription.url)));
  });

  test('migrates complete profile files into secure storage', () async {
    final profileDirectory = Directory('${directory.path}/profiles');
    final legacyStore = FileProfileStore(profileDirectory);
    final secureStore = SecureProfileStore(secretStore, legacyStore);
    final profile = ParsedProfile(
      id: 'profile-private',
      subscriptionId: 'private-subscription',
      title: 'Private',
      format: SubscriptionFormat.singBoxJson,
      rawHash: 'hash',
      nodeCount: 0,
      nodes: const [],
      groups: const [],
      rawText: '{"password":"profile-secret"}',
      createdAt: DateTime.utc(2026, 8, 20),
    );
    await legacyStore.replaceAtomically(profile);

    await secureStore.migrateLegacyProfiles();

    expect(await profileDirectory.list().isEmpty, isTrue);
    expect(secretStore.values.values.single, contains('profile-secret'));
    final restored = await secureStore.currentFor(profile.subscriptionId);
    expect(restored?.rawText, profile.rawText);
  });
}
