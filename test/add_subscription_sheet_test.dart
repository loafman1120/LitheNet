import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/features/subscriptions/presentation/widgets/add_subscription_sheet.dart';

void main() {
  testWidgets('add subscription sheet accepts host-only HTTPS URLs',
      (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  builder: (_) => const AddSubscriptionSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'https://example.com',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, {'url': 'https://example.com'});
  });

  testWidgets('add subscription sheet extracts URLs from Clash import links',
      (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  builder: (_) => const AddSubscriptionSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'clash://install-config?url=https%3A%2F%2Fexample.com%2Fsub',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, {'url': 'https://example.com/sub'});
  });

  testWidgets('add subscription sheet extracts URLs from common import params',
      (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  builder: (_) => const AddSubscriptionSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Subscription URL'),
      'quantumult-x:///update-configuration?remote-resource=https%3A%2F%2Fexample.com%2Fqx',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, {'url': 'https://example.com/qx'});
  });
}
