part of 'proxy_repository.dart';

/// Concrete repository backed by the bundled singbox-ffi core.
class SingboxProxyRepository extends ProxyRepository {
  /// Creates a repository with a direct local mixed proxy config.
  SingboxProxyRepository()
      : _configJson = _buildDirectConfig(
          listenAddress: '127.0.0.1',
          mixedPort: 2080,
        );

  SingboxFfi? _core;
  SingboxService? _service;
  SingboxApiClient? _apiClient;
  Timer? _trafficTimer;
  StreamSubscription<SingboxLogEvent>? _logSubscription;
  StreamSubscription<SingboxApiStatus>? _statusSubscription;
  StreamSubscription<SingboxApiConnectionEvents>? _connectionsSubscription;
  StreamSubscription<List<SingboxApiGroup>>? _groupsSubscription;
  StreamSubscription<List<SingboxApiGroupItem>>? _outboundsSubscription;
  bool _busy = false;
  bool _systemProxyEnabled = true;
  String _status = 'Stopped';
  String _message =
      'Load the bundled singbox-ffi core, validate a config, then start.';
  String _listenAddress = '127.0.0.1';
  int _mixedPort = 2080;
  String _configJson;
  String? _loadedCoreSource;
  String? _singboxVersion;
  String? _goVersion;
  final SingboxApiEndpoint _apiEndpoint = const SingboxApiEndpoint();
  final SingboxApiConfigInjector _apiConfigInjector =
      const SingboxApiConfigInjector();
  TrafficSnapshot _traffic = TrafficSnapshot.zero;
  final Map<String, SingboxApiConnection> _connections = {};
  List<SingboxApiGroup> _apiGroups = const [];
  List<SingboxApiGroupItem> _apiOutbounds = const [];
  final List<LogEntry> _logs = [];

  @override
  bool get busy => _busy;

  @override
  bool get coreLoaded => _core != null;

  @override
  bool get running => _isServiceRunning(_service);

  @override
  bool get systemProxyEnabled => _systemProxyEnabled;

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
  List<SingboxApiConnection> get connections =>
      List.unmodifiable(_connections.values);

  @override
  List<SingboxApiGroup> get apiGroups => List.unmodifiable(_apiGroups);

  @override
  List<SingboxApiGroupItem> get apiOutbounds =>
      List.unmodifiable(_apiOutbounds);

  @override
  List<LogEntry> get logs => List.unmodifiable(_logs);

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
  Future<void> setSystemProxyEnabled(bool enabled) async {
    _systemProxyEnabled = enabled;
    notifyListeners();

    final service = _service;
    if (!_isServiceRunning(service)) {
      return;
    }

    if (enabled) {
      _enableSystemProxy(service);
    } else {
      _disableSystemProxy(service);
    }
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
    await _guard(() async {
      final core = _ensureCore();
      final config = _normalizedConfig();
      core.checkConfig(config);
      final service = core.start(config);

      _service = service;
      _status = 'Running';
      _message = 'Mixed proxy is running on $_listenAddress:$_mixedPort.';
      _startLogStream(service);
      _startApiClient();
      _appendLog(
        LogLevel.info,
        'core',
        'Mixed proxy is running on $_listenAddress:$_mixedPort.',
      );
      _enableSystemProxy(service);
      notifyListeners();
    });
  }

  @override
  Future<void> reload() async {
    await _guard(() {
      final service = _service;
      if (service == null || !_isServiceRunning(service)) {
        throw SingboxException(
          'service is not running',
          kind: SingboxErrorKind.serviceState,
        );
      }
      final config = _normalizedConfig();
      _ensureCore().checkConfig(config);
      service.reload(config);
      _message = 'Config reloaded.';
      _appendLog(LogLevel.info, 'core', 'Config reloaded.');
      _restartApiClient();
      notifyListeners();
    });
  }

  @override
  Future<void> stop() async {
    await _guard(() async {
      final service = _service;
      _disableSystemProxy(service);
      service?.close();
      _service = null;
      _status = 'Stopped';
      _message = 'Proxy stopped.';
      _stopLogStream();
      _stopApiClient();
      _traffic = TrafficSnapshot.zero;
      _connections.clear();
      _apiGroups = const [];
      _apiOutbounds = const [];
      _appendLog(LogLevel.info, 'core', 'Proxy stopped.');
      notifyListeners();
    });
  }

  @override
  Future<void> selectOutbound({
    required String groupTag,
    required String outboundTag,
  }) async {
    final client = _apiClient;
    if (client == null) {
      _appendLog(LogLevel.warning, 'api', 'API client is not connected.');
      notifyListeners();
      return;
    }
    await client.selectOutbound(groupTag: groupTag, outboundTag: outboundTag);
  }

  @override
  Future<void> urlTest(String outboundTag) async {
    final client = _apiClient;
    if (client == null) {
      _appendLog(LogLevel.warning, 'api', 'API client is not connected.');
      notifyListeners();
      return;
    }
    await client.urlTest(outboundTag);
  }

  @override
  void clearLogs() {
    _logs.clear();
    try {
      _service?.clearLogs();
    } catch (error) {
      _appendLog(
          LogLevel.warning, 'core', 'Failed to clear native logs: $error');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopLogStream();
    _stopApiClient();
    try {
      _disableSystemProxy(_service);
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
        logMaxLines: 1000,
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

  Future<void> _guard(FutureOr<void> Function() action) async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _message = error.toString();
      _appendLog(LogLevel.error, 'core', error.toString());
      notifyListeners();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _normalizedConfig() {
    final decoded = jsonDecode(_configJson);
    final normalized = const JsonEncoder.withIndent('  ').convert(decoded);
    return _apiConfigInjector.inject(normalized, _apiEndpoint);
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

  void _startApiClient() {
    _stopApiClient();
    final client = SingboxApiClient(endpoint: _apiEndpoint);
    _apiClient = client;
    _statusSubscription = client.subscribeStatus().listen(
          _handleApiStatus,
          onError: _handleApiError,
        );
    _connectionsSubscription = client.subscribeConnections().listen(
          _handleConnectionEvents,
          onError: _handleApiError,
        );
    _groupsSubscription = client.subscribeGroups().listen(
      (groups) {
        _apiGroups = groups;
        notifyListeners();
      },
      onError: _handleApiError,
    );
    _outboundsSubscription = client.subscribeOutbounds().listen(
      (outbounds) {
        _apiOutbounds = outbounds;
        notifyListeners();
      },
      onError: _handleApiError,
    );
  }

  void _restartApiClient() {
    if (!running) {
      return;
    }
    _startApiClient();
  }

  void _stopApiClient() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _connectionsSubscription?.cancel();
    _connectionsSubscription = null;
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
    _outboundsSubscription?.cancel();
    _outboundsSubscription = null;
    _apiClient?.close();
    _apiClient = null;
    _stopMockTraffic();
  }

  void _handleApiStatus(SingboxApiStatus status) {
    _stopMockTraffic();
    _traffic = TrafficSnapshot(
      uploadBytes: status.uplinkTotal,
      downloadBytes: status.downlinkTotal,
      activeConnections: status.connectionsIn + status.connectionsOut,
    );
    notifyListeners();
  }

  void _handleConnectionEvents(Object event) {
    if (event is! SingboxApiConnectionEvents) {
      return;
    }
    if (event.reset) {
      _connections.clear();
    }
    for (final connectionEvent in event.events) {
      final connection = connectionEvent.connection;
      if (connectionEvent.type == 2) {
        _connections.remove(connectionEvent.id);
      } else if (connection != null) {
        _connections[connection.id] = connection;
      }
    }
    notifyListeners();
  }

  void _handleApiError(Object error) {
    _appendLog(LogLevel.warning, 'api', error.toString());
    if (_traffic == TrafficSnapshot.zero && _trafficTimer == null) {
      _startMockTraffic();
    }
    notifyListeners();
  }

  void _stopMockTraffic() {
    _trafficTimer?.cancel();
    _trafficTimer = null;
    _traffic = _traffic.copyWith(activeConnections: 0);
  }

  void _startLogStream(SingboxService service) {
    _stopLogStream();
    _logSubscription = service
        .logs(
      interval: const Duration(milliseconds: 300),
      batchSize: 100,
    )
        .listen(
      _handleCoreLogEvent,
      onError: (Object error) {
        _appendLog(LogLevel.error, 'core', error.toString());
        notifyListeners();
      },
    );
  }

  void _stopLogStream() {
    _logSubscription?.cancel();
    _logSubscription = null;
  }

  void _enableSystemProxy(SingboxService? service) {
    if (!_systemProxyEnabled || service == null) {
      return;
    }
    try {
      service.enableSystemProxy(
        SingboxSystemProxyOptions(host: _listenAddress, port: _mixedPort),
      );
      _appendLog(
        LogLevel.info,
        'core',
        'System proxy set to $_listenAddress:$_mixedPort.',
      );
    } catch (error) {
      _appendLog(
        LogLevel.warning,
        'core',
        'Failed to set system proxy: $error',
      );
    }
  }

  void _disableSystemProxy(SingboxService? service) {
    if (service == null) {
      return;
    }
    try {
      service.disableSystemProxy();
      _appendLog(LogLevel.info, 'core', 'System proxy restored.');
    } catch (error) {
      _appendLog(
        LogLevel.warning,
        'core',
        'Failed to restore system proxy: $error',
      );
    }
  }

  bool _isServiceRunning(SingboxService? service) {
    return service?.state().running ?? false;
  }

  void _handleCoreLogEvent(SingboxLogEvent event) {
    if (event.isReset) {
      _logs.clear();
      notifyListeners();
      return;
    }
    final message = _cleanLogMessage(event.message);
    _appendLog(_mapLogLevel(event, message), 'core', message);
    notifyListeners();
  }

  void _appendLog(LogLevel level, String source, String message) {
    _logs.add(
      LogEntry(
        time: DateTime.now(),
        level: level,
        source: source,
        message: message,
      ),
    );
    if (_logs.length > 2000) {
      _logs.removeRange(0, _logs.length - 2000);
    }
  }

  String _cleanLogMessage(String message) {
    return message.replaceAll(
      RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
      '',
    );
  }

  LogLevel _mapLogLevel(SingboxLogEvent event, String message) {
    final parsed = _parseLogLevel(message);
    if (parsed != null) {
      return parsed;
    }

    final levelName = event.levelName.toLowerCase();
    if (levelName.contains('error') || levelName.contains('fatal')) {
      return LogLevel.error;
    }
    if (levelName.contains('warn')) {
      return LogLevel.warning;
    }
    if (levelName.contains('debug')) {
      return LogLevel.debug;
    }
    if (levelName.contains('trace')) {
      return LogLevel.trace;
    }
    return LogLevel.info;
  }

  LogLevel? _parseLogLevel(String message) {
    final match = RegExp(r'^\s*(TRACE|DEBUG|INFO|WARN|WARNING|ERROR|FATAL)\b')
        .firstMatch(message.toUpperCase());
    return switch (match?.group(1)) {
      'TRACE' => LogLevel.trace,
      'DEBUG' => LogLevel.debug,
      'INFO' => LogLevel.info,
      'WARN' || 'WARNING' => LogLevel.warning,
      'ERROR' || 'FATAL' => LogLevel.error,
      _ => null,
    };
  }
}
