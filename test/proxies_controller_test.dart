import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/features/proxies/application/proxies_controller.dart';
import 'package:lithenet/features/proxies/application/proxy_catalog.dart';
import 'package:lithenet/features/subscriptions/data/subscription_parser.dart';

void main() {
  test('bulk latency test can update catalog-backed groups', () async {
    final catalog = ProxyCatalog()..replaceFromProfile(_profile);
    final controller = ProxiesController(catalog: catalog);
    addTearDown(controller.dispose);
    addTearDown(catalog.dispose);

    await expectLater(controller.testAllLatency(), completes);

    expect(controller.testing, isFalse);
    expect(controller.lastError, isNotNull);
    expect(controller.groups.first.nodes, hasLength(1));
  });

  test('node selection can update catalog-backed groups', () async {
    final catalog = ProxyCatalog()..replaceFromProfile(_profile);
    final controller = ProxiesController(catalog: catalog);
    addTearDown(controller.dispose);
    addTearDown(catalog.dispose);

    await expectLater(controller.selectNode('vmess-hk-01'), completes);

    expect(controller.groups.first.selectedNodeId, 'vmess-hk-01');
  });
}

final _profile = ParsedProfile(
  id: 'profile-proxy-test',
  subscriptionId: 'sub-proxy-test',
  title: 'Proxy test',
  format: SubscriptionFormat.clashYaml,
  rawHash: 'hash-proxy-test',
  nodeCount: 1,
  nodes: const [
    ProxyNode(
      id: 'vmess-hk-01',
      name: 'HK-01',
      type: 'vmess',
      countryCode: 'HK',
      metadata: {'group': 'HK'},
    ),
  ],
  groups: const ['HK'],
  rawText: 'proxies: []',
  createdAt: DateTime(2026, 7, 16),
);
