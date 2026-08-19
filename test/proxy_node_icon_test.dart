import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/features/proxies/presentation/widgets/proxy_node_tile.dart';

void main() {
  testWidgets('shows a country flag with a protocol badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProxyNodeIcon(countryCode: 'jp', type: 'hysteria2'),
        ),
      ),
    );

    expect(find.text('🇯🇵'), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('JP HYSTERIA2 proxy'), findsOneWidget);
  });

  testWidgets('uses the protocol icon when the region is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProxyNodeIcon(type: 'wireguard')),
      ),
    );

    expect(find.byIcon(Icons.vpn_lock_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('wireguard proxy'), findsOneWidget);
  });
}
