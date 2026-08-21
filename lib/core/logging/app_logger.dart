import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';

import '../../data/models/log_entry.dart';

/// Shared application logger.
///
/// Keep authentication tokens, subscription URLs, and full proxy
/// configurations out of messages sent here.
abstract final class AppLogger {
  static const _maxFileBytes = 5 * 1024 * 1024;
  static const _logFileName = 'target.log';
  static const _previousLogFileName = 'target.previous.log';

  static final StreamController<LogEntry> _entriesController =
      StreamController<LogEntry>.broadcast();
  static final List<LogEntry> _entries = [];
  static final List<String> _pendingFileLines = [];
  static final Logger _logger = Logger(
    printer: SimplePrinter(colors: false, printTime: true),
  );
  static File? _logFile;

  static Stream<LogEntry> get entriesStream => _entriesController.stream;
  static List<LogEntry> get entries => List.unmodifiable(_entries);
  static String? get logFilePath => _logFile?.path;

  /// Enables durable logging and flushes entries recorded during bootstrap.
  static Future<void> initialize(Directory logsDirectory) async {
    await logsDirectory.create(recursive: true);
    final file = File(
      '${logsDirectory.path}${Platform.pathSeparator}$_logFileName',
    );
    _rotateIfNeeded(file);
    _logFile = file;
    for (final line in _pendingFileLines) {
      _appendToFile(line);
    }
    _pendingFileLines.clear();
  }

  /// Stops file logging. Primarily useful for tests using a temporary path.
  static void shutdownFileLogging() => _logFile = null;

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
    _record(
      LogLevel.warning,
      source,
      _withError(message, error),
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String source = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _record(
      LogLevel.error,
      source,
      _withError(message, error),
      stackTrace: stackTrace,
    );
  }

  static void fatal(
    String message, {
    String source = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _record(
      LogLevel.error,
      source,
      _withError(message, error),
      stackTrace: stackTrace,
    );
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

  static void _record(
    LogLevel level,
    String source,
    String message, {
    StackTrace? stackTrace,
  }) {
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
    final stack = stackTrace == null ? '' : '\n$stackTrace';
    final fileLine = '${_formatEntry(entry)}$stack';
    if (_logFile == null) {
      _pendingFileLines.add(fileLine);
    } else {
      _appendToFile(fileLine);
    }
  }

  static String _formatEntry(LogEntry entry) {
    final level = entry.level.name.toUpperCase().padRight(7);
    return '${entry.time.toIso8601String()} [$level] '
        '[${entry.source}] ${entry.message}';
  }

  static void _appendToFile(String message) {
    final file = _logFile;
    if (file == null) return;
    try {
      _rotateIfNeeded(file);
      file.writeAsStringSync('$message\n', mode: FileMode.append, flush: true);
    } on Object catch (error) {
      // File logging must never make an application operation fail.
      _logger.e('Failed to write application log file', error: error);
    }
  }

  static void _rotateIfNeeded(File file) {
    if (!file.existsSync() || file.lengthSync() < _maxFileBytes) return;
    final previous = File(
      '${file.parent.path}${Platform.pathSeparator}$_previousLogFileName',
    );
    if (previous.existsSync()) previous.deleteSync();
    file.renameSync(previous.path);
  }

  static String _withError(String message, Object? error) =>
      error == null ? message : '$message: $error';
}
