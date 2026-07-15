import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/rustbox_log_parser.dart';
import 'package:lithenet/data/models/log_entry.dart';

void main() {
  test('removes ANSI styling and reads tracing log level', () {
    final parsed = parseRustBoxLogLine(
      '\x1B[2m2026-07-15T04:05:38Z\x1B[0m '
      '\x1B[32m INFO\x1B[0m rustbox_app: RustBox started',
      LogLevel.warning,
    );

    expect(parsed?.level, LogLevel.info);
    expect(
      parsed?.message,
      '2026-07-15T04:05:38Z  INFO rustbox_app: RustBox started',
    );
  });

  test('reads bracketed levels emitted on stderr', () {
    final parsed = parseRustBoxLogLine(
      '[INFO] rustbox.inbound.mixed service_started',
      LogLevel.warning,
    );

    expect(parsed?.level, LogLevel.info);
  });

  test('keeps the stream fallback for unstructured messages', () {
    final parsed = parseRustBoxLogLine('startup detail', LogLevel.warning);

    expect(parsed?.level, LogLevel.warning);
  });

  test('discards lines containing only ANSI codes and whitespace', () {
    expect(parseRustBoxLogLine('\x1B[2m\x1B[0m  ', LogLevel.info), isNull);
  });
}
