import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/empty_state.dart';
import '../application/logs_controller.dart';
import 'widgets/log_line_tile.dart';
import 'widgets/log_toolbar.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late final LogsController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = LogsController()..startDemoLogs();
  }

  @override
  void dispose() {
    _controller.stopDemoLogs();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final entries = _controller.filteredEntries;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Logs'),
            actions: [
              IconButton(
                onPressed: _copyVisible,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy visible',
              ),
              IconButton(
                onPressed: _export,
                icon: const Icon(Icons.share),
                tooltip: 'Export',
              ),
              IconButton(
                onPressed: _controller.clear,
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear',
              ),
            ],
          ),
          body: Column(
            children: [
              LogToolbar(
                paused: _controller.paused,
                levelFilter: _controller.levelFilter,
                onPauseToggle: _controller.togglePause,
                onLevelChanged: _controller.setLevelFilter,
                onSearchChanged: _controller.setSearchQuery,
              ),
              Expanded(
                child: entries.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No logs',
                        description: 'Logs will appear here in real time.',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return LogLineTile(entry: entries[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyVisible() {
    final text = _controller.exportLogs();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _export() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export logs'),
        content: const Text('Sanitize sensitive data (URLs, IPs, tokens)?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _doExport(sanitize: false);
            },
            child: const Text('Raw'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _doExport(sanitize: true);
            },
            child: const Text('Sanitized'),
          ),
        ],
      ),
    );
  }

  void _doExport({required bool sanitize}) {
    final text = _controller.exportLogs(sanitize: sanitize);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sanitize
            ? 'Sanitized logs copied to clipboard'
            : 'Logs copied to clipboard'),
      ),
    );
  }
}
