import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:lithenet/main.dart';

void main() {
  testWidgets('shows LitheNet control surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LitheNetApp());

    expect(find.text('LitheNet'), findsOneWidget);
    expect(find.text('No active profile'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Proxies'), findsOneWidget);
    expect(find.text('Subs'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
