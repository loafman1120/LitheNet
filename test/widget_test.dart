import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:lithenet/main.dart';

void main() {
  testWidgets('shows LitheNet control surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LitheNetApp());

    expect(find.text('LitheNet'), findsOneWidget);
    expect(find.text('Core'), findsOneWidget);
    expect(find.text('Local Proxy'), findsOneWidget);
    expect(find.text('sing-box Config'), findsOneWidget);
    expect(find.text('Start Proxy'), findsOneWidget);
  });
}
