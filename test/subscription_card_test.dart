import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target/data/models/subscription.dart';
import 'package:target/features/subscriptions/presentation/widgets/subscription_card.dart';

void main() {
  testWidgets('active and update status badges share the same row', (
    tester,
  ) async {
    const subscription = Subscription(
      id: 'sub-1',
      name: 'Example subscription',
      url: 'https://example.com/subscription',
      enabled: true,
      updateStatus: SubscriptionUpdateStatus.updated,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: SubscriptionCard(
              subscription: subscription,
              onTap: _noop,
              onMenuSelected: _ignore,
            ),
          ),
        ),
      ),
    );

    final activeCenter = tester.getCenter(find.text('Active'));
    final updatedCenter = tester.getCenter(find.text('Updated'));

    expect(activeCenter.dy, closeTo(updatedCenter.dy, 0.01));
    expect(activeCenter.dx, lessThan(updatedCenter.dx));
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

void _ignore(String _) {}
