import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/core_gateway.dart';
import 'package:lithenet/core/runtime/core_notifier.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/features/proxies/application/proxies_notifier.dart';
import 'package:lithenet/features/proxies/application/proxy_catalog.dart';
import 'package:lithenet/features/subscriptions/data/subscription_parser.dart';

void main() {
  ProviderContainer newContainer() {
    final container = ProviderContainer(
      overrides: [
        coreGatewayProvider.overrideWithValue(const UnavailableCoreGateway()),
      ],
    );
    container.read(proxyCatalogProvider.notifier).replaceFromProfile(_profile);
    return container;
  }

  test('bulk latency test can update catalog-backed groups', () async {
    final container = newContainer();
    addTearDown(container.dispose);
    final notifier = container.read(proxiesProvider.notifier);

    await expectLater(notifier.testAllLatency(), completes);

    final state = container.read(proxiesProvider);
    expect(state.testing, isFalse);
    expect(state.lastError, isNotNull);
    expect(state.groups.first.nodes, hasLength(1));
  });

  test('node selection can update catalog-backed groups', () async {
    final container = newContainer();
    addTearDown(container.dispose);
    final notifier = container.read(proxiesProvider.notifier);

    await expectLater(notifier.selectNode('vmess-hk-01'), completes);

    expect(
      container.read(proxiesProvider).groups.first.selectedNodeId,
      'vmess-hk-01',
    );
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
