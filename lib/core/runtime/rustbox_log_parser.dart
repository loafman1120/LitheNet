import '../../data/models/log_entry.dart';

final _ansiEscapePattern = RegExp(
  r'\x1B(?:\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1B\\))',
);
final _levelPattern = RegExp(
  r'(?:^|[\s\[])\b(TRACE|DEBUG|INFO|WARN|WARNING|ERROR)\b',
  caseSensitive: false,
);

class RustBoxLogLine {
  const RustBoxLogLine({required this.level, required this.message});

  final LogLevel level;
  final String message;
}

RustBoxLogLine? parseRustBoxLogLine(String line, LogLevel fallbackLevel) {
  final message = line.replaceAll(_ansiEscapePattern, '').trim();
  if (message.isEmpty) {
    return null;
  }

  final levelName = _levelPattern.firstMatch(message)?.group(1)?.toLowerCase();
  final level = switch (levelName) {
    'trace' => LogLevel.trace,
    'debug' => LogLevel.debug,
    'info' => LogLevel.info,
    'warn' || 'warning' => LogLevel.warning,
    'error' => LogLevel.error,
    _ => fallbackLevel,
  };

  return RustBoxLogLine(level: level, message: message);
}
