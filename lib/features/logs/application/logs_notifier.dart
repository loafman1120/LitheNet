import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/runtime/core_notifier.dart';
import '../../../data/models/log_entry.dart';

/// Immutable snapshot of the logs workspace.
@immutable
class LogsState {
  const LogsState({
    this.entries = const [],
    this.levelFilter,
    this.searchQuery = '',
    this.paused = false,
  });

  final List<LogEntry> entries;
  final LogLevel? levelFilter;
  final String searchQuery;
  final bool paused;

  List<LogEntry> get filteredEntries {
    var list = entries;

    if (levelFilter != null) {
      list = list.where((e) => e.level == levelFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (e) =>
                e.message.toLowerCase().contains(q) ||
                e.source.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  LogsState copyWith({
    List<LogEntry>? entries,
    LogLevel? levelFilter,
    String? searchQuery,
    bool? paused,
    bool clearLevelFilter = false,
  }) {
    return LogsState(
      entries: entries ?? this.entries,
      levelFilter: clearLevelFilter ? null : levelFilter ?? this.levelFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      paused: paused ?? this.paused,
    );
  }
}

class LogsNotifier extends Notifier<LogsState> {
  static const _maxEntries = 2000;

  StreamSubscription<LogEntry>? _appLogSubscription;
  Timer? _demoTimer;
  int _demoCounter = 0;

  @override
  LogsState build() {
    _appLogSubscription = AppLogger.entriesStream.listen(addEntry);
    ref.onDispose(() {
      unawaited(_appLogSubscription?.cancel());
      _demoTimer?.cancel();
    });
    return LogsState(entries: List.of(AppLogger.entries));
  }

  void setLevelFilter(LogLevel? level) {
    state = state.copyWith(levelFilter: level);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void togglePause() {
    final paused = !state.paused;
    final entries = paused ? state.entries : List.of(AppLogger.entries);
    state = state.copyWith(paused: paused, entries: entries);
  }

  void clear() {
    AppLogger.clear();
    state = state.copyWith(entries: const []);
    ref.read(coreProvider.notifier).clearLogs();
  }

  void addEntry(LogEntry entry) {
    if (state.paused) return;
    final entries = [...state.entries, entry];
    if (entries.length > _maxEntries) {
      entries.removeRange(0, entries.length - _maxEntries);
    }
    state = state.copyWith(entries: entries);
  }

  String exportLogs({bool sanitize = false}) {
    final buffer = StringBuffer();
    for (final entry in state.filteredEntries) {
      var msg = entry.message;
      if (sanitize) {
        msg = _sanitize(msg);
      }
      buffer.writeln(
        '${entry.timeString} [${entry.level.label}] ${entry.source} $msg',
      );
    }
    return buffer.toString();
  }

  String _sanitize(String text) {
    return text
        .replaceAllMapped(RegExp(r'https?://[^\s]+'), (m) => '[URL]')
        .replaceAllMapped(
          RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
          (m) => '[IP]',
        )
        .replaceAllMapped(
          RegExp(r'token=[^\s&]+', caseSensitive: false),
          (m) => 'token=[HIDDEN]',
        );
  }

  void startDemoLogs() {
    _demoTimer?.cancel();
    final sources = ['core', 'dns', 'router', 'inbound', 'outbound'];
    final messages = [
      'Connection established to remote server',
      'DNS query resolved: example.com -> 1.2.3.4',
      'Route matched: domain suffix .com -> proxy',
      'Connection closed: bytes sent 1024, received 4096',
      'TLS handshake completed',
      'SOCKS5 connection from 127.0.0.1:54321',
      'Mixed proxy listening on 127.0.0.1:2080',
      'Config reloaded successfully',
    ];
    final levels = LogLevel.values;

    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _demoCounter++;
      addEntry(
        LogEntry(
          time: DateTime.now(),
          level: levels[_demoCounter % levels.length],
          source: sources[_demoCounter % sources.length],
          message: messages[_demoCounter % messages.length],
        ),
      );
    });
  }

  void stopDemoLogs() {
    _demoTimer?.cancel();
    _demoTimer = null;
  }
}

final logsProvider = NotifierProvider<LogsNotifier, LogsState>(
  LogsNotifier.new,
);
