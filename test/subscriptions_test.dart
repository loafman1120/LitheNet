import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/core_gateway.dart';
import 'package:lithenet/core/runtime/core_notifier.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/data/storage/json_file_store.dart';
import 'package:lithenet/features/proxies/application/proxies_notifier.dart';
import 'package:lithenet/features/proxies/application/proxy_catalog.dart';
import 'package:lithenet/features/subscriptions/application/subscriptions_notifier.dart';
import 'package:lithenet/features/subscriptions/data/profile_store.dart';
import 'package:lithenet/features/subscriptions/data/subscription_fetcher.dart';
import 'package:lithenet/features/subscriptions/data/subscription_errors.dart';
import 'package:lithenet/features/subscriptions/data/subscription_headers.dart';
import 'package:lithenet/features/subscriptions/data/subscription_list_store.dart';
import 'package:lithenet/features/subscriptions/data/subscription_parser.dart';
import 'package:lithenet/features/subscriptions/data/subscription_url_normalizer.dart';
import 'package:lithenet/features/subscriptions/data/subscriptions_repository.dart';

void main() {
  test('subscription URL validation rejects malformed percent encoding', () {
    const normalizer = SubscriptionUrlNormalizer();

    for (final input in ['%', 'https%3A%2F%2Fexample.com%ZZ', 'prefix%2']) {
      expect(normalizer.normalize(input), isNull);
      expect(normalizer.isValid(input), isFalse);
    }
  });

  test('rejects non-sing-box JSON subscription formats', () async {
    const parser = AutoSubscriptionParser();
    final result = FetchResult(
      subscriptionId: 'sub-links',
      bodyBytes: utf8.encode(
        'vless://00000000-0000-0000-0000-000000000001@vless.example.com:443?security=tls&sni=cdn.example.com#VLESS%20Node\n'
        'trojan://secret@trojan.example.com:443?sni=trojan.example.com#Trojan%20Node',
      ),
      headers: const {},
      statusCode: 200,
      duration: Duration.zero,
      notModified: false,
    );
    const subscription = Subscription(
      id: 'sub-links',
      name: 'Links',
      url: 'https://example.com/sub',
      formatHint: SubscriptionFormat.v2rayBase64,
    );

    // New subscriptions must be complete sing-box JSON configs; legacy
    // link-based formats are rejected so the parser contract stays explicit.
    await expectLater(
      parser.parse(result, subscription),
      throwsA(
        isA<SubscriptionException>().having(
          (error) => error.code,
          'code',
          SubscriptionErrorCodes.format,
        ),
      ),
    );
  });

  test('parses subscription metadata headers', () {
    final metadata = const SubscriptionHeaderParser().parse({
      'Profile-Title': 'base64:${base64.encode(utf8.encode('工作订阅'))}',
      'Profile-Update-Interval': '12',
      'Subscription-Userinfo':
          'upload=1234; download=5678; total=10000; expire=1780000000',
      'Profile-Web-Page-URL': 'https://portal.example.com',
      'ETag': '"rev-1"',
      'Last-Modified': 'Sat, 20 Jun 2026 09:10:11 GMT',
    });

    expect(metadata.title, '工作订阅');
    expect(metadata.updateIntervalSeconds, 43200);
    expect(metadata.uploadBytes, 1234);
    expect(metadata.downloadBytes, 5678);
    expect(metadata.totalBytes, 10000);
    expect(metadata.webPageUrl, 'https://portal.example.com');
    expect(metadata.etag, '"rev-1"');
    expect(metadata.lastModified, isNotNull);
  });

  test('masks sensitive subscription URL parts', () {
    const subscription = Subscription(
      id: 'sub-1',
      name: 'Demo',
      url:
          'https://user:password@example.com/sub?token=secret&remark-name=work',
    );

    expect(subscription.safeUrl, contains('redacted@example.com'));
    expect(subscription.safeUrl, contains('token=***'));
    expect(subscription.safeUrl, contains('remark-name=work'));
    expect(subscription.safeUrl, isNot(contains('secret')));
    expect(subscription.safeUrl, isNot(contains('password')));
  });

  test('subscription fetcher sends compatibility request headers', () async {
    final capturedHeaders = <String, String>{};
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final serving = server.first.then((request) {
      capturedHeaders.addAll({
        HttpHeaders.userAgentHeader:
            request.headers.value(HttpHeaders.userAgentHeader) ?? '',
        HttpHeaders.acceptHeader:
            request.headers.value(HttpHeaders.acceptHeader) ?? '',
        HttpHeaders.acceptLanguageHeader:
            request.headers.value(HttpHeaders.acceptLanguageHeader) ?? '',
        HttpHeaders.cacheControlHeader:
            request.headers.value(HttpHeaders.cacheControlHeader) ?? '',
        HttpHeaders.pragmaHeader:
            request.headers.value(HttpHeaders.pragmaHeader) ?? '',
      });
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.text
        ..write('proxies: []');
      return request.response.close();
    });

    try {
      final result = await HttpSubscriptionFetcher().fetch(
        Subscription(
          id: 'sub-headers',
          name: 'Headers',
          url: 'http://127.0.0.1:${server.port}/sub',
          userAgent: 'LitheNet/0.1',
          allowInsecureHttp: true,
        ),
      );
      await serving;

      expect(result.statusCode, HttpStatus.ok);
      expect(capturedHeaders[HttpHeaders.userAgentHeader],
          SubscriptionRequestDefaults.userAgent);
      expect(capturedHeaders[HttpHeaders.acceptHeader], '*/*');
      expect(
        capturedHeaders[HttpHeaders.acceptLanguageHeader],
        'zh-CN,zh;q=0.9,en;q=0.8',
      );
      expect(capturedHeaders[HttpHeaders.cacheControlHeader], 'no-cache');
      expect(capturedHeaders[HttpHeaders.pragmaHeader], 'no-cache');
    } finally {
      await server.close(force: true);
    }
  });

  test('parses sing-box JSON subscription into nodes', () async {
    const parser = AutoSubscriptionParser();
    const subscription = Subscription(
      id: 'sub-singbox',
      name: 'Demo',
      url: 'https://example.com/sub',
    );
    final profile = await parser.parse(
      FetchResult(
        subscriptionId: subscription.id,
        statusCode: 200,
        headers: const {},
        bodyBytes: utf8.encode('''
{
  "outbounds": [
    {"type": "direct", "tag": "direct"},
    {"type": "block", "tag": "block"},
    {"type": "urltest", "tag": "auto"},
    {"type": "anytls", "tag": "HK-01", "server": "node.example.com", "server_port": 443, "password": "secret"},
    {"type": "vless", "tag": "JP-01", "server": "jp.example.com", "server_port": 8443, "uuid": "00000000-0000-0000-0000-000000000001"}
  ]
}
'''),
        duration: Duration.zero,
        notModified: false,
      ),
      subscription,
    );

    expect(profile.format, SubscriptionFormat.singBoxJson);
    // direct/block/urltest are control outbounds and must be filtered out.
    expect(profile.nodeCount, 2);
    expect(profile.nodes.map((node) => node.name), ['HK-01', 'JP-01']);
    expect(
      profile.nodes.first.metadata['config'],
      containsPair('server_port', 443),
    );
    expect(
      profile.nodes.last.metadata['config'],
      containsPair('uuid', contains('00000000')),
    );
  });

  test('subscription updates feed proxy catalog and notifier', () async {
    final container = ProviderContainer(
      overrides: [
        coreGatewayProvider.overrideWithValue(const UnavailableCoreGateway()),
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscriptions = container.read(subscriptionsProvider.notifier);
    container.read(proxiesProvider.notifier);

    await subscriptions.addSubscription('https://example.com/sub', name: 'Demo');

    expect(container.read(proxyCatalogProvider).groups, isNotEmpty);
    final proxyState = container.read(proxiesProvider);
    expect(proxyState.groups.first.name, 'All');
    expect(proxyState.filteredNodes.map((node) => node.name), contains('HK-01'));
    expect(
      container.read(subscriptionsProvider).subscriptions.single.nodeCount,
      2,
    );
  });

  test('keeps subscription visible when persistence fails', () async {
    final container = ProviderContainer(
      overrides: [
        coreGatewayProvider.overrideWithValue(const UnavailableCoreGateway()),
        subscriptionListStoreProvider.overrideWithValue(
          _ThrowingSubscriptionListStore(),
        ),
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscriptions = container.read(subscriptionsProvider.notifier);
    final added = await subscriptions.addSubscription('https://example.com/sub');

    expect(added, isTrue);
    final state = container.read(subscriptionsProvider);
    expect(state.subscriptions.single.url, 'https://example.com/sub');
    expect(
      state.subscriptions.single.updateStatus,
      SubscriptionUpdateStatus.failed,
    );
    expect(state.lastError, contains('Failed to save subscription'));
  });

  test('can add after loading an unmodifiable subscription list', () async {
    final container = ProviderContainer(
      overrides: [
        coreGatewayProvider.overrideWithValue(const UnavailableCoreGateway()),
        subscriptionListStoreProvider.overrideWithValue(
          _UnmodifiableSubscriptionListStore(),
        ),
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscriptions = container.read(subscriptionsProvider.notifier);
    await subscriptions.load();
    final added = await subscriptions.addSubscription('https://example.com/sub');

    expect(added, isTrue);
    expect(container.read(subscriptionsProvider).subscriptions, hasLength(1));
  });

  test('loads persisted subscriptions and restores proxy catalog', () async {
    final directory = await Directory.systemTemp.createTemp(
      'lithenet_subscriptions',
    );
    addTearDown(() => directory.delete(recursive: true));

    final listStore = FileSubscriptionListStore(
      JsonFileStore(
        File('${directory.path}${Platform.pathSeparator}subscriptions.json'),
      ),
    );
    final profileStore = FileProfileStore(
      Directory('${directory.path}${Platform.pathSeparator}profiles'),
    );
    const subscription = Subscription(
      id: 'sub-persisted',
      name: 'Persisted',
      url: 'https://example.com/sub',
      nodeCount: 1,
    );
    final profile = ParsedProfile(
      id: 'profile-persisted',
      subscriptionId: subscription.id,
      title: subscription.name,
      format: SubscriptionFormat.clashYaml,
      rawHash: 'hash-persisted',
      nodeCount: 1,
      nodes: const [
        ProxyNode(
          id: 'trojan-us-01',
          name: 'US-01',
          type: 'trojan',
          countryCode: 'US',
          metadata: {'group': 'US'},
        ),
      ],
      groups: const ['US'],
      rawText: 'proxies: []',
      createdAt: DateTime(2026, 6, 30),
    );
    await listStore.save([subscription]);
    await profileStore.replaceAtomically(profile);

    final container = ProviderContainer(
      overrides: [
        coreGatewayProvider.overrideWithValue(const UnavailableCoreGateway()),
        subscriptionListStoreProvider.overrideWithValue(listStore),
        profileStoreProvider.overrideWithValue(profileStore),
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscriptions = container.read(subscriptionsProvider.notifier);
    await subscriptions.load();

    final state = container.read(subscriptionsProvider);
    expect(state.subscriptions.single.name, 'Persisted');
    final catalog = container.read(proxyCatalogProvider);
    expect(catalog.groups.first.name, 'All');
    expect(
      catalog.groups.first.nodes.map((node) => node.name),
      contains('US-01'),
    );
  });
}

class _ThrowingSubscriptionListStore implements SubscriptionListStore {
  @override
  Future<List<Subscription>> load() async => const [];

  @override
  Future<void> save(List<Subscription> subscriptions) async {
    throw const FileSystemException('write failed');
  }
}

class _UnmodifiableSubscriptionListStore implements SubscriptionListStore {
  @override
  Future<List<Subscription>> load() async => List.unmodifiable(const []);

  @override
  Future<void> save(List<Subscription> subscriptions) async {}
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionUpdateResult> updateOne(Subscription subscription) async {
    final profile = ParsedProfile(
      id: 'profile-1',
      subscriptionId: subscription.id,
      title: 'Demo',
      format: SubscriptionFormat.clashYaml,
      rawHash: 'hash-1',
      nodeCount: 2,
      nodes: const [
        ProxyNode(
          id: 'vmess-hk-01',
          name: 'HK-01',
          type: 'vmess',
          countryCode: 'HK',
          metadata: {'group': 'HK'},
        ),
        ProxyNode(
          id: 'trojan-jp-01',
          name: 'JP-01',
          type: 'trojan',
          countryCode: 'JP',
          metadata: {'group': 'JP'},
        ),
      ],
      groups: const ['HK', 'JP'],
      rawText: 'proxies: []',
      createdAt: DateTime(2026, 6, 20),
    );
    return SubscriptionUpdateResult(
      subscription: subscription.copyWith(
        updateStatus: SubscriptionUpdateStatus.updated,
        activeProfileId: profile.id,
        nodeCount: profile.nodeCount,
      ),
      status: SubscriptionUpdateStatus.updated,
      changed: true,
      profileChanged: true,
      duration: Duration.zero,
      profile: profile,
    );
  }
}
