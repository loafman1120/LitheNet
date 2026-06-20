import 'package:flutter/foundation.dart';

enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error;

  String get label => name.toUpperCase();

  bool get isError => this == LogLevel.error;
  bool get isWarningOrAbove =>
      this == LogLevel.warning || this == LogLevel.error;
}

@immutable
class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.source,
    required this.message,
  });

  final DateTime time;
  final LogLevel level;
  final String source;
  final String message;

  String get timeString {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
