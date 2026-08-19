import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/models/proxy_node.dart';
import 'package:lithenet/data/models/subscription.dart';
import 'package:lithenet/core/runtime/core_gateway.dart';
import 'package:lithenet/core/runtime/core_models.dart';
import 'package:lithenet/data/models/app_settings.dart';
import 'package:lithenet/features/subscriptions/application/subscriptions_controller.dart';
import 'package:lithenet/features/subscriptions/data/subscription_parser.dart';
import 'package:lithenet/features/subscriptions/data/subscriptions_repository.dart';

import 'package:lithenet/main.dart';

void main() {
  testWidgets('shows Lithe control surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LitheNetApp());

    expect(find.text('Lithe'), findsOneWidget);
    expect(find.text('No active profile'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Proxies'), findsOneWidget);
    expect(find.text('Subs'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('shows the runtime error when connecting fails', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(LitheNetApp(coreGateway: _FailingCoreGateway()));
    await tester.pump();
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('Connection Error'), findsOneWidget);
    expect(find.text('Unable to start Libbox.'), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('View logs'), findsOneWidget);
  });

  testWidgets('adds a subscription from the subscriptions page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = SubscriptionsController(
      repository: _WidgetFakeSubscriptionRepository(),
    );

    await tester.pumpWidget(LitheNetApp(subscriptionsController: controller));

    await tester.tap(find.text('Subs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Subscription'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'clash://install-config?url=https%3A%2F%2Fexample.com%2Fsub',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Subscription 1'), findsOneWidget);
    expect(find.textContaining('https://example.com/sub'), findsOneWidget);
  });

  testWidgets('keeps added subscription visible when update fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LitheNetApp());

    await tester.tap(find.text('Subs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Subscription'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'https://example.com/sub',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Subscription 1'), findsOneWidget);
    expect(find.textContaining('https://example.com/sub'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('adds the dati yaml subscription URL from the page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LitheNetApp());

    await tester.tap(find.text('Subs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Subscription'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'https://free.datiya.com/uploads/20260630-clash.yaml',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Subscription 1'), findsOneWidget);
    expect(
      find.textContaining(
        'https://free.datiya.com/uploads/20260630-clash.yaml',
      ),
      findsOneWidget,
    );
  });
}

class _FailingCoreGateway implements CoreGateway {
  @override
  String get name => 'Failing test gateway';

  @override
  bool get isAvailable => true;

  @override
  Stream<CoreSnapshot> get snapshots => const Stream.empty();

  @override
  Future<void> setRawConfig(String? config) async {}

  @override
  Future<CoreSnapshot> current() async =>
      const CoreSnapshot(lifecycle: CoreLifecycle.stopped, message: 'Ready.');

  @override
  Future<void> configure(AppSettings settings) async {}

  @override
  Future<void> setProxyNodes(List<ProxyNode> nodes) async {}

  @override
  Future<void> start() => Future.error('Unable to start Libbox.');

  @override
  Future<void> stop() async {}

  @override
  Future<void> selectOutbound(String groupId, String outboundId) async {}

  @override
  Future<int?> testLatency(String outboundId) async => null;

  @override
  Future<void> closeConnection(String connectionId) async {}

  @override
  Future<int> closeAllConnections() async => 0;

  @override
  Future<int> refreshRuleSets() async => 0;

  @override
  Future<void> clearLogs() async {}

  @override
  Future<void> dispose() async {}
}

class _WidgetFakeSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionUpdateResult> updateOne(Subscription subscription) async {
    final profile = ParsedProfile(
      id: 'profile-widget',
      subscriptionId: subscription.id,
      title: subscription.name,
      format: SubscriptionFormat.clashYaml,
      rawHash: 'hash-widget',
      nodeCount: 1,
      nodes: const [
        ProxyNode(
          id: 'vmess-hk-widget',
          name: 'HK Widget',
          type: 'vmess',
          countryCode: 'HK',
          metadata: {'group': 'HK'},
        ),
      ],
      groups: const ['HK'],
      rawText: 'proxies: []',
      createdAt: DateTime(2026, 6, 30),
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
