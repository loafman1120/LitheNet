import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/runtime/core_controller.dart';
import '../../../data/models/log_entry.dart';

class LogsController extends ChangeNotifier {
  final List<LogEntry> _entries = [];
  LogLevel? _levelFilter;
  String _searchQuery = '';
  bool _paused = false;
  Timer? _demoTimer;
  int _demoCounter = 0;
  CoreController? _core;

  List<LogEntry> get entries => List.unmodifiable(_entries);
  LogLevel? get levelFilter => _levelFilter;
  String get searchQuery => _searchQuery;
  bool get paused => _paused;

  List<LogEntry> get filteredEntries {
    var list = _entries;

    if (_levelFilter != null) {
      list = list.where((e) => e.level == _levelFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list =
          list
              .where(
                (e) =>
                    e.message.toLowerCase().contains(q) ||
                    e.source.toLowerCase().contains(q),
              )
              .toList();
    }

    return list;
  }

  void setLevelFilter(LogLevel? level) {
    _levelFilter = level;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void togglePause() {
    _paused = !_paused;
    if (!_paused) {
      _syncFromCore();
    }
    notifyListeners();
  }

  void clear() {
    final core = _core;
    if (core != null) {
      core.clearLogs();
      return;
    }
    _entries.clear();
    notifyListeners();
  }

  void addEntry(LogEntry entry) {
    _entries.add(entry);
    if (_entries.length > 2000) {
      _entries.removeRange(0, _entries.length - 2000);
    }
    notifyListeners();
  }

  void bind(CoreController core) {
    if (_core == core) {
      return;
    }
    _core?.removeListener(_syncFromCore);
    _core = core..addListener(_syncFromCore);
    _syncFromCore();
  }

  String exportLogs({bool sanitize = false}) {
    final buffer = StringBuffer();
    for (final entry in filteredEntries) {
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

  @override
  void dispose() {
    _core?.removeListener(_syncFromCore);
    stopDemoLogs();
    super.dispose();
  }

  void _syncFromCore() {
    if (_paused) {
      return;
    }
    final core = _core;
    if (core == null) {
      return;
    }
    _entries
      ..clear()
      ..addAll(core.logs);
    notifyListeners();
  }
}
