import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/data/storage/json_file_store.dart';
import 'package:lithenet/features/proxies/application/proxies_controller.dart';
import 'package:lithenet/features/proxies/application/proxy_catalog.dart';
import 'package:lithenet/features/subscriptions/application/subscriptions_controller.dart';
import 'package:lithenet/features/subscriptions/data/profile_store.dart';
import 'package:lithenet/features/subscriptions/data/subscription_fetcher.dart';
import 'package:lithenet/features/subscriptions/data/subscription_headers.dart';
import 'package:lithenet/features/subscriptions/data/subscription_list_store.dart';
import 'package:lithenet/features/subscriptions/data/subscription_parser.dart';
import 'package:lithenet/features/subscriptions/data/subscriptions_repository.dart';

void main() {
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
      expect(capturedHeaders[HttpHeaders.userAgentHeader], 'Lithe/0.1');
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

  test('detects Clash YAML profile and counts nodes', () async {
    const parser = AutoSubscriptionParser();
    const subscription = Subscription(
      id: 'sub-1',
      name: 'Demo',
      url: 'https://example.com/sub',
    );
    final profile = await parser.parse(
      FetchResult(
        subscriptionId: subscription.id,
        statusCode: 200,
        headers: const {},
        bodyBytes: utf8.encode('''
proxies:
  - name: HK-01
    type: vmess
  - name: JP-01
    type: trojan
rules:
  - MATCH,DIRECT
'''),
        duration: Duration.zero,
        notModified: false,
      ),
      subscription,
    );

    expect(profile.format, SubscriptionFormat.clashYaml);
    expect(profile.nodeCount, 2);
    expect(profile.rawHash, isNotEmpty);
  });

  test('subscription updates feed proxy catalog and controller', () async {
    final catalog = ProxyCatalog();
    final controller = SubscriptionsController(
      repository: _FakeSubscriptionRepository(),
    )..bindProxyCatalog(catalog);
    final proxies = ProxiesController(catalog: catalog);

    await controller.addSubscription('https://example.com/sub', name: 'Demo');

    expect(catalog.groups, isNotEmpty);
    expect(proxies.groups.first.name, 'All');
    expect(proxies.filteredNodes.map((node) => node.name), contains('HK-01'));
    expect(controller.subscriptions.single.nodeCount, 2);

    controller.dispose();
    proxies.dispose();
    catalog.dispose();
  });

  test('keeps subscription visible when persistence fails', () async {
    final controller = SubscriptionsController(
      store: _ThrowingSubscriptionListStore(),
      repository: _FakeSubscriptionRepository(),
    );
    addTearDown(controller.dispose);

    final added = await controller.addSubscription('https://example.com/sub');

    expect(added, isTrue);
    expect(controller.subscriptions.single.url, 'https://example.com/sub');
    expect(
      controller.subscriptions.single.updateStatus,
      SubscriptionUpdateStatus.failed,
    );
    expect(controller.lastError, contains('Failed to save subscription'));
  });

  test('loads persisted subscriptions and restores proxy catalog', () async {
    final directory =
        await Directory.systemTemp.createTemp('lithenet_subscriptions');
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

    final catalog = ProxyCatalog();
    final controller = SubscriptionsController(
      store: listStore,
      profileStore: profileStore,
      repository: _FakeSubscriptionRepository(),
    )..bindProxyCatalog(catalog);
    addTearDown(controller.dispose);
    addTearDown(catalog.dispose);

    await controller.load();

    expect(controller.subscriptions.single.name, 'Persisted');
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
