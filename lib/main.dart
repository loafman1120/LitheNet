import 'dart:io';

import 'package:flutter/material.dart';

import 'singbox_ffi.dart';

void main() {
  runApp(const LitheNetApp());
}

class LitheNetApp extends StatelessWidget {
  const LitheNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LitheNet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const ProxyHomePage(),
    );
  }
}

class ProxyHomePage extends StatefulWidget {
  const ProxyHomePage({super.key});

  @override
  State<ProxyHomePage> createState() => _ProxyHomePageState();
}

class _ProxyHomePageState extends State<ProxyHomePage> {
  static const _host = '127.0.0.1';
  static const _port = 2080;

  SingboxFfi? _core;
  SingboxService? _service;
  String _status = 'Stopped';
  String _details = 'Download singboxffi.dll, then start the local proxy.';
  bool _busy = false;

  bool get _running => _service != null;

  @override
  void dispose() {
    _service?.close();
    super.dispose();
  }

  Future<void> _toggleProxy() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      if (_running) {
        _service!.close();
        _service = null;
        _status = 'Stopped';
        _details = 'Proxy stopped.';
      } else {
        final core = _core ?? SingboxFfi.openDefault();
        _core = core;
        core.init();
        core.checkConfig(_configJson);
        _service = core.start(_configJson);
        _status = 'Running';
        _details = 'Mixed proxy listening on $_host:$_port.';
      }
    } on Object catch (error) {
      _status = 'Error';
      _details = error.toString();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final corePath = SingboxFfi.defaultLibraryPath();
    return Scaffold(
      appBar: AppBar(title: const Text('LitheNet')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Local Proxy',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(_details),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _busy ? null : _toggleProxy,
                  icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                  label: Text(_running ? 'Stop proxy' : 'Start proxy'),
                ),
                const SizedBox(height: 24),
                SelectableText('Core path: $corePath'),
                const SizedBox(height: 8),
                const SelectableText(
                  'Test: curl.exe -x socks5h://127.0.0.1:2080 https://example.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _configJson = '''
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "127.0.0.1",
      "listen_port": 2080
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "final": "direct"
  }
}
''';
