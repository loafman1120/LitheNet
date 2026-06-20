import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:singbox_ffi/singbox_ffi.dart';

class ProxyRepositoryScope extends InheritedNotifier<ProxyRepository> {
  const ProxyRepositoryScope({
    required ProxyRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  static ProxyRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ProxyRepositoryScope>();
    assert(scope != null, 'ProxyRepositoryScope was not found in the tree.');
    return scope!.notifier!;
  }
}

abstract class ProxyRepository extends ChangeNotifier {
  bool get busy;
  bool get coreLoaded;
  bool get running;
  String get status;
  String get message;
  String get listenAddress;
  int get mixedPort;
  String get configJson;
  String? get loadedCoreSource;
  String? get singboxVersion;
  String? get goVersion;
  TrafficSnapshot get traffic;

  String get versionLine {
    final singbox = singboxVersion;
    final go = goVersion;
    if (singbox == null || go == null) {
      return 'Core not loaded';
    }
    return 'sing-box $singbox - $go';
  }

  void updateEndpoint({
    required String listenAddress,
    required int mixedPort,
  });

  void updateConfig(String configJson);
  void resetDirectConfig();
  Future<void> loadCore();
  Future<void> validateConfig();
  Future<void> start();
  Future<void> reload();
  Future<void> stop();
}

class SingboxProxyRepository extends ProxyRepository {
  SingboxProxyRepository()
      : _configJson = _buildDirectConfig(
          listenAddress: '127.0.0.1',
          mixedPort: 2080,
        );

  SingboxFfi? _core;
  SingboxService? _service;
  Timer? _trafficTimer;
  bool _busy = false;
  String _status = 'Stopped';
  String _message =
      'Load the bundled singbox-ffi core, validate a config, then start.';
  String _listenAddress = '127.0.0.1';
  int _mixedPort = 2080;
  String _configJson;
  String? _loadedCoreSource;
  String? _singboxVersion;
  String? _goVersion;
  TrafficSnapshot _traffic = TrafficSnapshot.zero;

  @override
  bool get busy => _busy;

  @override
  bool get coreLoaded => _core != null;

  @override
  bool get running => _service != null;

  @override
  String get status => _status;

  @override
  String get message => _message;

  @override
  String get listenAddress => _listenAddress;

  @override
  int get mixedPort => _mixedPort;

  @override
  String get configJson => _configJson;

  @override
  String? get loadedCoreSource => _loadedCoreSource;

  @override
  String? get singboxVersion => _singboxVersion;

  @override
  String? get goVersion => _goVersion;

  @override
  TrafficSnapshot get traffic => _traffic;

  @override
  void updateEndpoint({
    required String listenAddress,
    required int mixedPort,
  }) {
    _listenAddress =
        listenAddress.trim().isEmpty ? '127.0.0.1' : listenAddress.trim();
    _mixedPort = mixedPort;
    _configJson = _buildDirectConfig(
      listenAddress: _listenAddress,
      mixedPort: _mixedPort,
    );
    _message = 'Updated local mixed proxy endpoint.';
    notifyListeners();
  }

  @override
  void updateConfig(String configJson) {
    _configJson = configJson;
    notifyListeners();
  }

  @override
  void resetDirectConfig() {
    _configJson = _buildDirectConfig(
      listenAddress: _listenAddress,
      mixedPort: _mixedPort,
    );
    _message = 'Generated a direct outbound config.';
    notifyListeners();
  }

  @override
  Future<void> loadCore() async {
    await _guard(() {
      _openCore();
    });
  }

  @override
  Future<void> validateConfig() async {
    await _guard(() {
      _ensureCore().checkConfig(_normalizedConfig());
      _message = 'Config is valid.';
      notifyListeners();
    });
  }

  @override
  Future<void> start() async {
    await _guard(() {
      final core = _ensureCore();
      final config = _normalizedConfig();
      core.checkConfig(config);
      final service = core.start(config);

      _service = service;
      _status = 'Running';
      _message = 'Mixed proxy is running on $_listenAddress:$_mixedPort.';
      _startMockTraffic();
      notifyListeners();
    });
  }

  @override
  Future<void> reload() async {
    await _guard(() {
      final service = _service;
      if (service == null) {
        throw SingboxException('service is not running');
      }
      final config = _normalizedConfig();
      _ensureCore().checkConfig(config);
      service.reload(config);
      _message = 'Config reloaded.';
      notifyListeners();
    });
  }

  @override
  Future<void> stop() async {
    await _guard(() {
      _service?.close();
      _service = null;
      _status = 'Stopped';
      _message = 'Proxy stopped.';
      _stopMockTraffic();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _stopMockTraffic();
    try {
      _service?.close();
    } catch (_) {
      // Flutter is tearing down; there is no useful UI surface left for errors.
    }
    super.dispose();
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
      _message = 'Core already loaded from $_loadedCoreSource.';
      notifyListeners();
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

    _core = core;
    _loadedCoreSource = source;
    _singboxVersion = core.version();
    _goVersion = core.goVersion();
    _message = 'Core loaded from $_loadedCoreSource.';
    notifyListeners();
    return core;
  }

  Future<void> _guard(VoidCallback action) async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      action();
    } catch (error) {
      _message = error.toString();
      notifyListeners();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _normalizedConfig() {
    final decoded = jsonDecode(_configJson);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  }

  static String _buildDirectConfig({
    required String listenAddress,
    required int mixedPort,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'log': {'level': 'info'},
      'inbounds': [
        {
          'type': 'mixed',
          'tag': 'mixed-in',
          'listen': listenAddress,
          'listen_port': mixedPort,
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

  void _startMockTraffic() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _traffic = _traffic.copyWith(
        uploadBytes: _traffic.uploadBytes + 48 * 1024,
        downloadBytes: _traffic.downloadBytes + 192 * 1024,
        activeConnections: 4,
      );
      notifyListeners();
    });
  }

  void _stopMockTraffic() {
    _trafficTimer?.cancel();
    _trafficTimer = null;
    _traffic = _traffic.copyWith(activeConnections: 0);
  }
}

@immutable
class TrafficSnapshot {
  const TrafficSnapshot({
    required this.uploadBytes,
    required this.downloadBytes,
    required this.activeConnections,
  });

  static const zero = TrafficSnapshot(
    uploadBytes: 0,
    downloadBytes: 0,
    activeConnections: 0,
  );

  final int uploadBytes;
  final int downloadBytes;
  final int activeConnections;

  int get totalBytes => uploadBytes + downloadBytes;

  TrafficSnapshot copyWith({
    int? uploadBytes,
    int? downloadBytes,
    int? activeConnections,
  }) {
    return TrafficSnapshot(
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      activeConnections: activeConnections ?? this.activeConnections,
    );
  }
}
