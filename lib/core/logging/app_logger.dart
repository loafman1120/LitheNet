import 'dart:async';

import 'package:logger/logger.dart';

import '../../data/models/log_entry.dart';

/// Shared application logger.
///
/// Keep authentication tokens, subscription URLs, and full proxy
/// configurations out of messages sent here.
abstract final class AppLogger {
  static final StreamController<LogEntry> _entriesController =
      StreamController<LogEntry>.broadcast();
  static final List<LogEntry> _entries = [];
  static final Logger _logger = Logger(
    printer: SimplePrinter(colors: false, printTime: true),
  );

  static Stream<LogEntry> get entriesStream => _entriesController.stream;
  static List<LogEntry> get entries => List.unmodifiable(_entries);

  static void trace(String message, {String source = 'APP'}) {
    _logger.t(message);
    _record(LogLevel.trace, source, message);
  }

  static void debug(String message, {String source = 'APP'}) {
    _logger.d(message);
    _record(LogLevel.debug, source, message);
  }

  static void info(String message, {String source = 'APP'}) {
    _logger.i(message);
    _record(LogLevel.info, source, message);
  }

  static void warning(
    String message, {
    String source = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _record(LogLevel.warning, source, _withError(message, error));
  }

  static void error(
    String message, {
    String source = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _record(LogLevel.error, source, _withError(message, error));
  }

  static void fatal(
    String message, {
    String source = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _record(LogLevel.error, source, _withError(message, error));
  }

  static void log(LogLevel level, String message, {String source = 'APP'}) {
    switch (level) {
      case LogLevel.trace:
        trace(message, source: source);
      case LogLevel.debug:
        debug(message, source: source);
      case LogLevel.info:
        info(message, source: source);
      case LogLevel.warning:
        warning(message, source: source);
      case LogLevel.error:
        error(message, source: source);
    }
  }

  static void clear() => _entries.clear();

  static void _record(LogLevel level, String source, String message) {
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      source: source,
      message: message,
    );
    _entries.add(entry);
    if (_entries.length > 2000) {
      _entries.removeRange(0, _entries.length - 2000);
    }
    _entriesController.add(entry);
  }

  static String _withError(String message, Object? error) =>
      error == null ? message : '$message: $error';
}
