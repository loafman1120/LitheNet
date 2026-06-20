import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/features/proxies/application/proxies_controller.dart';
import 'package:lithenet/features/proxies/application/proxy_catalog.dart';
import 'package:lithenet/features/subscriptions/application/subscriptions_controller.dart';
import 'package:lithenet/features/subscriptions/data/subscription_fetcher.dart';
import 'package:lithenet/features/subscriptions/data/subscription_headers.dart';
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
