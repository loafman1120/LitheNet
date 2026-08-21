import 'package:flutter_test/flutter_test.dart';
import 'package:target/core/logging/ansi_escape.dart';

void main() {
  test('removes sing-box ANSI color sequences without changing Unicode', () {
    const message = '\x1B[36moutbound/anytls[高速隧道1x-日本01]: connected\x1B[0m';

    expect(
      stripAnsiEscapeSequences(message),
      'outbound/anytls[高速隧道1x-日本01]: connected',
    );
  });

  test('removes extended colors and OSC terminal commands', () {
    const message = '\x1B]0;sing-box\x07\x1B[38;5;113mavailable: 42ms\x1B[0m';

    expect(stripAnsiEscapeSequences(message), 'available: 42ms');
  });

  test('leaves ordinary escape-like text unchanged', () {
    const message = r'configuration contains literal [37m text';

    expect(stripAnsiEscapeSequences(message), message);
  });
}
