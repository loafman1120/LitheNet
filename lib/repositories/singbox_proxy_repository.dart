part of 'proxy_repository.dart';

/// Concrete repository backed by the bundled singbox-ffi core.
class SingboxProxyRepository extends ProxyRepository {
  /// Creates a repository with a direct local proxy config.
  SingboxProxyRepository({
    AppSettings initialSettings = const AppSettings(),
    AppStoragePaths? storagePaths,
    bool demoMode = false,
  })  : _systemProxyEnabled = initialSettings.systemProxy,
        _proxyMode = initialSettings.proxyMode,
        _listenAddress = initialSettings.listenAddress,
        _mixedPort = initialSettings.mixedPort,
        _storagePaths = storagePaths,
        _demoMode = demoMode,
        _commandSecret = _generateRuntimeSecret(),
        _apiEndpoint = SingboxApiEndpoint(secret: _generateRuntimeSecret()),
        _configJson = _buildDirectConfig(
          listenAddress: initialSettings.listenAddress,
          mixedPort: initialSettings.mixedPort,
          proxyMode: initialSettings.proxyMode,
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
  bool _systemProxyEnabled;
  ProxyMode _proxyMode;
  String _status = 'Stopped';
  String _message =
      'Load the bundled singbox-ffi core, validate a config, then start.';
  String _listenAddress;
  int _mixedPort;
  String _configJson;
  String? _loadedCoreSource;
  String? _singboxVersion;
  String? _goVersion;
  SingboxApiEndpoint _apiEndpoint;
  final SingboxApiConfigInjector _apiConfigInjector =
      const SingboxApiConfigInjector();
  final AppStoragePaths? _storagePaths;
  final bool _demoMode;
  final String _commandSecret;
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
  bool get running => isSingboxServiceRunning(_service);

  @override
  bool get systemProxyEnabled => _systemProxyEnabled;

  @override
  bool get canRequestTunElevation =>
      _proxyMode == ProxyMode.tun &&
      isTunPermissionError(_message) &&
      (Platform.isWindows || Platform.isLinux);

  @override
  ProxyMode get proxyMode => _proxyMode;

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
      proxyMode: _proxyMode,
    );
    _message = 'Updated local proxy endpoint.';
    notifyListeners();
  }

  @override
  void setProxyMode(ProxyMode mode) {
    _proxyMode = mode;
    _configJson = _buildDirectConfig(
      listenAddress: _listenAddress,
      mixedPort: _mixedPort,
      proxyMode: _proxyMode,
    );
    _message = switch (mode) {
      ProxyMode.mixed => 'Generated a system proxy config.',
      ProxyMode.tun => 'Generated a Windows TUN config. Run as administrator.',
    };
    notifyListeners();
  }

  @override
  Future<void> setSystemProxyEnabled(bool enabled) async {
    _systemProxyEnabled = enabled;
    notifyListeners();

    final service = _service;
    if (!isSingboxServiceRunning(service)) {
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
  Future<void> requestTunElevation() async {
    if (_proxyMode != ProxyMode.tun) {
      return;
    }
    await _guard(() async {
      if (Platform.isWindows) {
        await restartWindowsAsAdministrator();
        return;
      }
      if (Platform.isLinux) {
        await restartLinuxWithPkexec();
        return;
      }
      throw UnsupportedError(
          'TUN elevation is not supported on this platform.');
    });
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
      proxyMode: _proxyMode,
    );
    _message = 'Generated a direct outbound config.';
    notifyListeners();
  }

  @override
  Future<void> loadCore() async {
    await _guard(() {
      _runMeasuredSync('loadCore', () {
        _openCore();
      });
    });
  }

  @override
  Future<void> validateConfig() async {
    await _guard(() async {
      await _ensureApiEndpoint();
      _runMeasuredSync('validateConfig', () {
        _ensureCore().checkConfig(_normalizedConfig());
      });
      _message = 'Config is valid.';
      notifyListeners();
    });
  }

  @override
  Future<void> start() async {
    await _guard(() async {
      await _ensureApiEndpoint(verifyAvailable: true);
      final service = _runMeasuredSync('start', () {
        final core = _ensureCore();
        final config = _normalizedConfig();
        core.checkConfig(config);
        return core.start(config);
      });

      _service = service;
      _status = 'Running';
      _message = _runningMessage();
      _startLogStream(service);
      _startApiClient();
      _appendLog(
        LogLevel.info,
        'core',
        _runningMessage(),
      );
      _enableSystemProxy(service);
      notifyListeners();
    });
  }

  @override
  Future<void> reload() async {
    await _guard(() {
      final service = _service;
      if (service == null || !isSingboxServiceRunning(service)) {
        throw SingboxException(
          'service is not running',
          kind: SingboxErrorKind.serviceState,
        );
      }
      _runMeasuredSync('reload', () {
        final config = _normalizedConfig();
        _ensureCore().checkConfig(config);
        service.reload(config);
      });
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
    final coreDir = _ensureCoreDirectory(_storagePaths);
    final tempDir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}lithenet',
    );
    tempDir.createSync(recursive: true);

    core.init(
      SingboxInitOptions(
        basePath: coreDir.path,
        workingPath: coreDir.path,
        tempPath: tempDir.path,
        commandSecret: _commandSecret,
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

  Future<void> _ensureApiEndpoint({bool verifyAvailable = false}) async {
    if (_apiEndpoint.port > 0 && !verifyAvailable) {
      return;
    }

    final port = await _findAvailableLoopbackPort(
      preferredPort: verifyAvailable ? _apiEndpoint.port : 0,
    );
    if (port == _apiEndpoint.port) {
      return;
    }

    _apiEndpoint = SingboxApiEndpoint(
      host: _apiEndpoint.host,
      port: port,
      secret: _apiEndpoint.secret,
      dashboardEnabled: _apiEndpoint.dashboardEnabled,
    );
    _appendLog(
      LogLevel.info,
      'api',
      'Selected local API endpoint ${_apiEndpoint.host}:$port.',
    );
  }

  T _runMeasuredSync<T>(String operation, T Function() action) {
    final stopwatch = Stopwatch()..start();
    _message = 'Running $operation...';
    _appendLog(LogLevel.info, 'core', 'Starting $operation.');
    notifyListeners();
    try {
      return action();
    } finally {
      stopwatch.stop();
      _appendLog(
        LogLevel.info,
        'core',
        '$operation completed in ${stopwatch.elapsedMilliseconds} ms.',
      );
    }
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
      final message = _friendlyErrorMessage(error);
      _message = message;
      _appendLog(LogLevel.error, 'core', message);
      notifyListeners();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();
    if (_proxyMode == ProxyMode.tun && isTunPermissionError(message)) {
      if (Platform.isWindows) {
        return 'TUN needs administrator permission. Restart LitheNet as administrator to continue.';
      }
      if (Platform.isLinux) {
        return 'TUN needs elevated network permission. Restart LitheNet with policy authentication to continue.';
      }
      return 'TUN needs elevated network permission on this platform.';
    }
    return message;
  }

  String _normalizedConfig() {
    final decoded = jsonDecode(_configJson);
    final normalized = const JsonEncoder.withIndent('  ').convert(decoded);
    return _apiConfigInjector.inject(normalized, _apiEndpoint);
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
    if (!_systemProxyEnabled ||
        service == null ||
        _proxyMode == ProxyMode.tun) {
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

  String _runningMessage() {
    return switch (_proxyMode) {
      ProxyMode.mixed =>
        'Mixed proxy is running on $_listenAddress:$_mixedPort.',
      ProxyMode.tun =>
        'TUN proxy is running. Administrator permission may be required.',
    };
  }

  void _handleCoreLogEvent(SingboxLogEvent event) {
    if (event.isReset) {
      _logs.clear();
      notifyListeners();
      return;
    }
    final message = cleanSingboxLogMessage(event.message);
    _appendLog(mapSingboxLogLevel(event, message), 'core', message);
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

  void _notifyRepositoryListeners() {
    notifyListeners();
  }
}
