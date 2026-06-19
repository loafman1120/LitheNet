import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:singbox_ffi/singbox_ffi.dart';

void main() {
  runApp(const LitheNetApp());
}

class LitheNetApp extends StatelessWidget {
  const LitheNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LitheNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff246bfe),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      home: const LitheNetHomePage(),
    );
  }
}

class LitheNetHomePage extends StatefulWidget {
  const LitheNetHomePage({super.key});

  @override
  State<LitheNetHomePage> createState() => _LitheNetHomePageState();
}

class _LitheNetHomePageState extends State<LitheNetHomePage> {
  final _listenController = TextEditingController(text: '127.0.0.1');
  final _portController = TextEditingController(text: '2080');
  late final TextEditingController _configController;

  SingboxFfi? _core;
  SingboxService? _service;
  String? _loadedCoreSource;
  String? _singboxVersion;
  String? _goVersion;
  String _status = 'Stopped';
  String _message = 'Load the bundled singbox-ffi core, validate a config, then start.';
  bool _busy = false;

  bool get _running => _service != null;

  @override
  void initState() {
    super.initState();
    _configController = TextEditingController(text: _buildDirectConfig());
  }

  @override
  void dispose() {
    try {
      _service?.close();
    } catch (_) {
      // Flutter is tearing down; there is no useful UI surface left for errors.
    }
    _listenController.dispose();
    _portController.dispose();
    _configController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final controls = _buildControls(context);
            final editor = _buildEditor(context);

            return Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 380,
                                child: SingleChildScrollView(child: controls),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: editor),
                            ],
                          )
                        : ListView(
                            children: [
                              controls,
                              const SizedBox(height: 16),
                              SizedBox(height: 520, child: editor),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _running ? Colors.green.shade700 : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LitheNet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _versionLine,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Chip(
            avatar: Icon(
              _running ? Icons.radio_button_checked : Icons.radio_button_off,
              color: statusColor,
              size: 18,
            ),
            label: Text(_status),
            side: BorderSide(color: statusColor.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _section(
          context,
          title: 'Core',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Bundled singbox-ffi plugin'),
              subtitle: Text(
                'Flutter packages ${SingboxFfi.defaultLibraryName} through the singbox_ffi FFI plugin.',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _busy || _running || _core != null ? null : _loadCore,
                    icon: const Icon(Icons.memory),
                    label: const Text('Load Core'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _validateConfig,
                    icon: const Icon(Icons.fact_check),
                    label: const Text('Validate'),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _section(
          context,
          title: 'Local Proxy',
          children: [
            TextField(
              controller: _listenController,
              enabled: !_running && !_busy,
              decoration: const InputDecoration(labelText: 'Listen address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              enabled: !_running && !_busy,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Mixed port'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy || _running ? null : _resetConfig,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Direct Config'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _section(
          context,
          title: 'Service',
          children: [
            FilledButton.icon(
              onPressed:
                  _busy ? null : (_running ? _stopService : _startService),
              icon: Icon(_running ? Icons.stop : Icons.play_arrow),
              label: Text(_running ? 'Stop Proxy' : 'Start Proxy'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy || !_running ? null : _reloadService,
              icon: const Icon(Icons.sync),
              label: const Text('Reload Config'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _section(
          context,
          title: 'Status',
          children: [
            SelectableText(_message),
          ],
        ),
      ],
    );
  }

  Widget _buildEditor(BuildContext context) {
    return _section(
      context,
      title: 'sing-box Config',
      children: [
        Expanded(
          child: TextField(
            controller: _configController,
            enabled: !_busy,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontFamily: 'Consolas',
              fontSize: 13,
              height: 1.35,
            ),
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              labelText: 'JSON',
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  String get _versionLine {
    final singbox = _singboxVersion;
    final go = _goVersion;
    if (singbox == null || go == null) {
      return 'Core not loaded';
    }
    return 'sing-box $singbox - $go';
  }

  Future<void> _loadCore() async {
    await _guard(() {
      _openCore();
    });
  }

  Future<void> _validateConfig() async {
    await _guard(() {
      _ensureCore().checkConfig(_normalizedConfig());
      setState(() {
        _message = 'Config is valid.';
      });
    });
  }

  Future<void> _startService() async {
    await _guard(() {
      final core = _ensureCore();
      final config = _normalizedConfig();
      core.checkConfig(config);
      final service = core.start(config);

      setState(() {
        _service = service;
        _status = 'Running';
        final listen = _listenController.text.trim();
        final port = _portController.text.trim();
        _message = 'Mixed proxy is running on $listen:$port.';
      });
    });
  }

  Future<void> _reloadService() async {
    await _guard(() {
      final service = _service;
      if (service == null) {
        throw SingboxException('service is not running');
      }
      final config = _normalizedConfig();
      _ensureCore().checkConfig(config);
      service.reload(config);
      setState(() {
        _message = 'Config reloaded.';
      });
    });
  }

  Future<void> _stopService() async {
    await _guard(() {
      _service?.close();
      setState(() {
        _service = null;
        _status = 'Stopped';
        _message = 'Proxy stopped.';
      });
    });
  }

  void _resetConfig() {
    setState(() {
      _configController.text = _buildDirectConfig();
      _message = 'Generated a direct outbound config.';
    });
  }

  SingboxFfi _ensureCore() {
    final core = _core;
    if (core != null) {
      return core;
    }
    return _openCore();
  }

  SingboxFfi _openCore() {
    final loaded = _core;
    if (loaded != null) {
      setState(() {
        _message = 'Core already loaded from $_loadedCoreSource.';
      });
      return loaded;
    }

    final core = SingboxFfi.openBundled();
    const source = 'singbox_ffi plugin bundle';
    final appDir = _ensureAppDirectory();
    final tempDir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}lithenet',
    );
    tempDir.createSync(recursive: true);

    core.init(
      SingboxInitOptions(
        basePath: appDir.path,
        workingPath: appDir.path,
        tempPath: tempDir.path,
        commandSecret: 'lithenet-local',
        oomKillerDisabled: true,
      ),
    );

    setState(() {
      _core = core;
      _loadedCoreSource = source;
      _singboxVersion = core.version();
      _goVersion = core.goVersion();
      _message = 'Core loaded from $_loadedCoreSource.';
    });
    return core;
  }

  Future<void> _guard(void Function() action) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
    });
    try {
      action();
    } catch (error) {
      setState(() {
        _message = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String _normalizedConfig() {
    final decoded = jsonDecode(_configController.text);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  }

  String _buildDirectConfig() {
    final listen = _listenController.text.trim().isEmpty
        ? '127.0.0.1'
        : _listenController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 2080;

    return const JsonEncoder.withIndent('  ').convert({
      'log': {'level': 'info'},
      'inbounds': [
        {
          'type': 'mixed',
          'tag': 'mixed-in',
          'listen': listen,
          'listen_port': port,
        }
      ],
      'outbounds': [
        {'type': 'direct', 'tag': 'direct'}
      ],
      'route': {'final': 'direct'},
    });
  }

  Directory _ensureAppDirectory() {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final separator = Platform.pathSeparator;
    final dir = Directory('$home$separator.lithenet');
    dir.createSync(recursive: true);
    return dir;
  }
}
