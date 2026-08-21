// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/proxy_group.dart';
import '../../data/models/proxy_node.dart';
import '../../data/storage/app_storage_paths.dart';
import '../logging/ansi_escape.dart';
import '../logging/app_logger.dart';
import 'core_gateway.dart';
import 'core_models.dart';
import 'grpc/generated/started_service.pb.dart' as daemon_pb;
import 'grpc/generated/started_service.pbgrpc.dart' hide LogLevel;
import 'grpc/generated/libbox/v1/manager.pb.dart' as manager_pb;
import 'grpc/generated/libbox/v1/manager.pbgrpc.dart';
import 'libbox_config_builder.dart';
import 'libboxd_service_manager.dart';

class LibboxGateway implements CoreGateway {
  LibboxGateway({
    AppStoragePaths? storagePaths,
    Directory? workingDirectory,
  })  : _injectedPaths = storagePaths,
        _workingDirectory = workingDirectory;

  /// Test-only override. When provided, this directory is used as the
  /// isolated AppStoragePaths root so tests never touch the real
  /// platform support directory.
  final AppStoragePaths? _injectedPaths;
  final Directory? _workingDirectory;

  AppStoragePaths? _resolvedPaths;
  Future<AppStoragePaths>? _pathsFuture;

  final StreamController<CoreSnapshot> _snapshots =
      StreamController<CoreSnapshot>.broadcast();
  final List<LogEntry> _logs = [];
  final Map<String, ProxyGroup> _groups = {};
  final Map<String, CoreConnection> _connections = {};
  final Map<String, int> _latencies = {};
  final Map<String, int> _latencyTimes = {};
  final Map<String, _PendingUrlTest> _pendingUrlTests = {};
  final List<StreamSubscription<Object?>> _subscriptions = [];

  AppSettings _settings = const AppSettings();
  List<ProxyNode> _proxyNodes = const [];
  String? _rawConfig;
  final LibboxdServiceManager _serviceManager = LibboxdServiceManager();
  LibboxManagerClient? _manager;
  Process? _daemonProcess;
  ClientChannel? _channel;
  StartedServiceClient? _daemon;
  CallOptions? _callOptions;
  String? _socketPath;
  Future<void> _lifecycleTail = Future<void>.value();
  CoreSnapshot _current = const CoreSnapshot(
    lifecycle: CoreLifecycle.stopped,
    message: 'Libbox is ready.',
  );
  bool _disposed = false;

  @override
  String get name => 'Libbox';

  @override
  bool get isAvailable =>
      !_disposed &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  Stream<CoreSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<CoreSnapshot> current() async {
    final manager = _manager;
    if (manager == null) return _current;
    final state = await manager.getState(Empty(), options: _callOptions);
    final lifecycle = switch (state.state) {
      manager_pb.ServiceStateType.SERVICE_STATE_RUNNING =>
        CoreLifecycle.running,
      manager_pb.ServiceStateType.SERVICE_STATE_STARTING =>
        CoreLifecycle.starting,
      manager_pb.ServiceStateType.SERVICE_STATE_STOPPING =>
        CoreLifecycle.stopping,
      manager_pb.ServiceStateType.SERVICE_STATE_FAILED => CoreLifecycle.failed,
      _ => CoreLifecycle.stopped,
    };
    _publish(
      _copyCurrent(
        lifecycle: lifecycle,
        message: state.errorMessage.isNotEmpty
            ? state.errorMessage
            : lifecycle == CoreLifecycle.running
            ? 'Libbox is running.'
            : 'Libbox is stopped.',
      ),
    );
    return _current;
  }

  @override
  Future<void> configure(AppSettings settings) => _serialize(() async {
    _settings = settings;
    final config = await _buildConfig();
    final manager = _manager;
    if (manager != null) {
      final check = await manager.checkConfig(
        manager_pb.ConfigRequest(content: config),
        options: _callOptions,
      );
      if (!check.valid) throw StateError(check.formattedError);
      await manager.reload(
        manager_pb.ReloadRequest(config: config),
        options: _callOptions,
      );
    }
  });

  @override
  Future<void> setProxyNodes(List<ProxyNode> nodes) => _serialize(() async {
    _proxyNodes = List.unmodifiable(nodes);
    _rawConfig = null;
    final manager = _manager;
    if (manager != null) {
      final config = await _buildConfig();
      await manager.reload(
        manager_pb.ReloadRequest(config: config),
        options: _callOptions,
      );
    }
  });

  @override
  Future<void> setRawConfig(String? config) => _serialize(() async {
    _rawConfig = config?.trim().isEmpty == true ? null : config?.trim();
    final manager = _manager;
    if (manager != null) {
      final next = await _buildConfig();
      await manager.reload(
        manager_pb.ReloadRequest(config: next),
        options: _callOptions,
      );
    }
  });

  @override
  Future<void> start() => _serialize(_startLocked);

  Future<void> _startLocked() async {
    _ensureAvailable();
    if (_manager != null) return;
    _publish(
      _copyCurrent(
        lifecycle: CoreLifecycle.starting,
        message: 'Starting Libbox...',
      ),
    );
    await _ensureProxyPortAvailable();
    await _ensureCore();

    final config = await _buildConfig();
    try {
      await _connectCommandServer();
      final manager = _manager!;
      final check = await manager.checkConfig(
        manager_pb.ConfigRequest(content: config),
        options: _callOptions,
      );
      if (!check.valid) throw StateError(check.formattedError);
      await manager.start(
        manager_pb.StartRequest(config: config),
        options: _callOptions,
      );
      _subscribeCommandStreams();
      _publish(
        _copyCurrent(
          lifecycle: CoreLifecycle.running,
          message: 'Libbox is running.',
        ),
      );
    } on Object {
      await _shutdownTransport();
      await _shutdownTransport();
      rethrow;
    }
  }

  Future<String> _buildConfig() async {
    final cacheFilePath = await _resolveCacheFilePath();
    final raw = _rawConfig;
    if (raw == null) {
      return LibboxConfigBuilder.build(
        _settings,
        proxyNodes: _proxyNodes,
        cacheFilePath: cacheFilePath,
      );
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return raw;
    final config = Map<String, dynamic>.from(decoded);
    // The app owns the inbound surface; never inherit subscription inbounds
    // (airports ship tun inbounds that fail without admin on Windows).
    config['inbounds'] = LibboxConfigBuilder.buildInbounds(_settings);
    LibboxConfigBuilder.migrateLegacyTransports(config);
    LibboxConfigBuilder.migrateLegacyInboundFields(config);
    LibboxConfigBuilder.migrateLegacyDnsOutbound(config);
    LibboxConfigBuilder.normalizeAnyTlsAlpn(config);
    final experimental = config['experimental'] is Map
        ? Map<String, dynamic>.from(config['experimental'] as Map)
        : <String, dynamic>{};
    experimental['cache_file'] = {
      if (experimental['cache_file'] is Map)
        ...Map<String, dynamic>.from(experimental['cache_file'] as Map),
      'enabled': true,
      'path': singBoxWindowsPath(cacheFilePath),
    };
    config['experimental'] = experimental;
    return jsonEncode(config);
  }

  @override
  Future<void> stop() => _serialize(_stopLocked);

  Future<void> _stopLocked() async {
    final manager = _manager;
    if (manager == null) {
      _publish(
        _copyCurrent(
          lifecycle: CoreLifecycle.stopped,
          message: 'Libbox is stopped.',
        ),
      );
      return;
    }
    _publish(
      _copyCurrent(
        lifecycle: CoreLifecycle.stopping,
        message: 'Stopping Libbox...',
      ),
    );
    await manager.stop(Empty(), options: _callOptions);
    await _shutdownTransport();
    _groups.clear();
    _connections.clear();
    _publish(
      const CoreSnapshot(
        lifecycle: CoreLifecycle.stopped,
        message: 'Libbox is stopped.',
      ),
    );
  }

  @override
  Future<void> selectOutbound(String groupId, String outboundId) async {
    final daemon = _requireDaemon('selecting an outbound');
    await daemon.selectOutbound(
      daemon_pb.SelectOutboundRequest(
        groupTag: groupId,
        outboundTag: outboundId,
      ),
      options: _callOptions,
    );
  }

  @override
  Future<int?> testLatency(String outboundId) async {
    final daemon = _requireDaemon('testing latency');
    final baseline = _latencyTimes[outboundId] ?? 0;
    final pending = _PendingUrlTest(baseline);
    _pendingUrlTests[outboundId] = pending;
    try {
      await daemon.uRLTest(
        daemon_pb.URLTestRequest(outboundTag: outboundId),
        options: _callOptions,
      );
      await pending.completer.future.timeout(const Duration(seconds: 15));
      return _latencies[outboundId];
    } finally {
      if (identical(_pendingUrlTests[outboundId], pending)) {
        _pendingUrlTests.remove(outboundId);
      }
    }
  }

  @override
  Future<void> closeConnection(String connectionId) async {
    await _requireDaemon('closing a connection').closeConnection(
      daemon_pb.CloseConnectionRequest(id: connectionId),
      options: _callOptions,
    );
  }

  @override
  Future<int> closeAllConnections() async {
    final count = _connections.length;
    await _requireDaemon(
      'closing connections',
    ).closeAllConnections(Empty(), options: _callOptions);
    return count;
  }

  @override
  Future<int> refreshRuleSets() async => 0;

  @override
  Future<void> clearLogs() async {
    _logs.clear();
    final daemon = _daemon;
    if (daemon != null) {
      await daemon.clearLogs(Empty(), options: _callOptions);
    }
    _publish(_copyCurrent(logs: const []));
  }

  @override
  Future<void> dispose() => _serialize(() async {
    if (_disposed) return;
    await _stopLocked();
    _disposed = true;
    await _snapshots.close();
  });

  // ---------------------------------------------------------------------------
  // path_provider-aware storage resolution
  // ---------------------------------------------------------------------------

  /// Returns the canonical [AppStoragePaths], lazily resolved via
  /// `path_provider` on first use.  Tests can inject an isolated
  /// `workingDirectory` which is wrapped as a synthetic [AppStoragePaths]
  /// so they never touch the real platform support directory.
  Future<AppStoragePaths> _resolveStoragePaths() async {
    if (_resolvedPaths != null) return _resolvedPaths!;
    if (_pathsFuture != null) return await _pathsFuture!;
    final future = () async {
      final injected = _injectedPaths;
      if (injected != null) return injected;
      final working = _workingDirectory;
      if (working != null) {
        return AppStoragePaths.fromRoot(working);
      }
      // Primary: let AppStoragePaths use path_provider's
      // getApplicationSupportDirectory internally.
      return AppStoragePaths.resolve();
    }();
    _pathsFuture = future;
    try {
      _resolvedPaths = await future;
      return _resolvedPaths!;
    } finally {
      _pathsFuture = null;
    }
  }

  Future<Directory> _resolveBaseDirectory() async {
    final override = _settings.serviceBasePath.trim();
    if (override.isNotEmpty) return Directory(override);
    final paths = await _resolveStoragePaths();
    return paths.coreDirectory;
  }

  Future<String> _resolveCacheFilePath() async {
    // Cache lives alongside the base directory so it survives re-installs
    // and follows the user's custom basePath when set.
    final base = await _resolveBaseDirectory();
    // Ensure the base exists so the cache file's parent is ready.
    try {
      await base.create(recursive: true);
    } on Object catch (error, stackTrace) {
      AppLogger.warning('Failed to create libbox base directory',
          source: 'libbox', error: error, stackTrace: stackTrace);
    }
    return '${base.path}${Platform.pathSeparator}cache.db';
  }

  Future<String> _resolveWorkingPath() async {
    final override = _settings.serviceWorkingPath.trim();
    if (override.isNotEmpty) return override;
    // When no override is set, let libboxd default to basePath.
    // Return empty so LibboxdServiceManager skips the flag.
    return '';
  }

  Future<String> _resolveTempPath() async {
    final override = _settings.serviceTempPath.trim();
    if (override.isNotEmpty) return override;
    // Prefer path_provider's cache/temp directory as libbox scratch space.
    try {
      final cacheDir = await getApplicationCacheDirectory();
      if (cacheDir.path.trim().isNotEmpty) {
        final targetCache =
            Directory('${cacheDir.path}${Platform.pathSeparator}Target');
        await targetCache.create(recursive: true);
        return targetCache.path;
      }
    } on Object catch (_) {}
    try {
      final tmp = await getTemporaryDirectory();
      if (tmp.path.trim().isNotEmpty) {
        final targetTmp =
            Directory('${tmp.path}${Platform.pathSeparator}Target');
        await targetTmp.create(recursive: true);
        return targetTmp.path;
      }
    } on Object catch (error, stackTrace) {
      AppLogger.warning('path_provider temp resolve failed',
          source: 'libbox', error: error, stackTrace: stackTrace);
    }
    return '';
  }

  Future<void> _ensureCore() async {
    if (_daemonProcess != null) return;
    final baseDir = await _resolveBaseDirectory();
    await baseDir.create(recursive: true);
    _socketPath = '${baseDir.path}${Platform.pathSeparator}command.sock';
    if (await File(_socketPath!).exists()) return;
    final workingPath = await _resolveWorkingPath();
    final tempPath = await _resolveTempPath();
    AppLogger.info(
        'Launching libboxd base=$baseDir working=$workingPath temp=$tempPath',
        source: 'libbox');
    _daemonProcess = await _serviceManager.launch(
      basePath: baseDir.path,
      workingPath: workingPath,
      tempPath: tempPath,
      locale: _settings.serviceLocale,
    );
  }

  Future<void> _connectCommandServer() async {
    final channel = ClientChannel(
      InternetAddress(_socketPath!, type: InternetAddressType.unix),
      port: 0,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _channel = channel;
    _daemon = StartedServiceClient(channel);
    _manager = LibboxManagerClient(channel);
    _callOptions = CallOptions();
    Object? lastError;
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      try {
        final stream = _daemon!.subscribeServiceStatus(
          Empty(),
          options: _callOptions,
        );
        final status = await stream.first.timeout(const Duration(seconds: 1));
        if (status.status == daemon_pb.ServiceStatus_Type.FATAL) {
          throw StateError(status.errorMessage);
        }
        return;
      } on Object catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    throw StateError('Libbox command server did not become ready: $lastError');
  }

  void _subscribeCommandStreams() {
    final daemon = _daemon!;
    final options = _callOptions;
    _listen(
      daemon.subscribeServiceStatus(Empty(), options: options),
      _applyServiceStatus,
    );
    _listen(daemon.subscribeLog(Empty(), options: options), _applyLogs);
    _listen(
      daemon.subscribeStatus(
        daemon_pb.SubscribeStatusRequest(interval: Int64(1000)),
        options: options,
      ),
      _applyStatus,
    );
    _listen(daemon.subscribeGroups(Empty(), options: options), _applyGroups);
    _listen(
      daemon.subscribeConnections(
        daemon_pb.SubscribeConnectionsRequest(interval: Int64(1000)),
        options: options,
      ),
      _applyConnections,
    );
  }

  void _listen<T>(Stream<T> stream, void Function(T) onData) {
    final subscription = stream.listen(
      onData,
      onError: (Object error, StackTrace stackTrace) {
        if (_manager != null && !_disposed) {
          AppLogger.warning(
            'Libbox gRPC stream failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      },
    );
    _subscriptions.add(subscription as StreamSubscription<Object?>);
  }

  void _applyServiceStatus(daemon_pb.ServiceStatus status) {
    final lifecycle = switch (status.status) {
      daemon_pb.ServiceStatus_Type.STARTING => CoreLifecycle.starting,
      daemon_pb.ServiceStatus_Type.STARTED => CoreLifecycle.running,
      daemon_pb.ServiceStatus_Type.STOPPING => CoreLifecycle.stopping,
      daemon_pb.ServiceStatus_Type.FATAL => CoreLifecycle.failed,
      _ => CoreLifecycle.stopped,
    };
    _publish(
      _copyCurrent(
        lifecycle: lifecycle,
        message: status.errorMessage.isNotEmpty
            ? status.errorMessage
            : lifecycle == CoreLifecycle.running
            ? 'Libbox is running.'
            : _current.message,
      ),
    );
  }

  void _applyLogs(daemon_pb.Log batch) {
    if (batch.reset) _logs.clear();
    final now = DateTime.now();
    for (final message in batch.messages) {
      final entry = LogEntry(
        time: now,
        level: _logLevel(message.level),
        source: 'gRPC',
        message: stripAnsiEscapeSequences(message.message),
      );
      _logs.add(entry);
      AppLogger.log(entry.level, entry.message, source: entry.source);
    }
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
    _publish(_copyCurrent(logs: List.unmodifiable(_logs)));
  }

  void _applyStatus(daemon_pb.Status status) {
    _publish(
      _copyCurrent(
        traffic: TrafficSnapshot(
          uploadBytes: status.uplinkTotal.toInt(),
          downloadBytes: status.downlinkTotal.toInt(),
          activeConnections: _connections.length,
        ),
      ),
    );
  }

  void _applyGroups(daemon_pb.Groups value) {
    _groups
      ..clear()
      ..addEntries(
        value.group.map((group) {
          final nodes = group.items
              .map((item) {
                final latency = item.urlTestDelay > 0
                    ? item.urlTestDelay
                    : null;
                if (latency != null) _latencies[item.tag] = latency;
                final testedAt = item.urlTestTime.toInt();
                if (testedAt > 0) _latencyTimes[item.tag] = testedAt;
                final pending = _pendingUrlTests[item.tag];
                if (pending != null &&
                    !pending.completer.isCompleted &&
                    testedAt > pending.startedAfter) {
                  pending.completer.complete();
                }
                return ProxyNode(
                  id: item.tag,
                  name: item.tag,
                  type: item.type,
                  latencyMs: latency,
                  isSelected: item.tag == group.selected,
                );
              })
              .toList(growable: false);
          return MapEntry(
            group.tag,
            ProxyGroup(
              id: group.tag,
              name: group.tag,
              type: group.type,
              selectedNodeId: group.selected,
              nodes: nodes,
            ),
          );
        }),
      );
    _publish(_copyCurrent(proxyGroups: _groups.values.toList()));
  }

  void _applyConnections(daemon_pb.ConnectionEvents batch) {
    if (batch.reset) _connections.clear();
    for (final event in batch.events) {
      final id = event.id.isNotEmpty ? event.id : event.connection.id;
      if (event.type == daemon_pb.ConnectionEventType.CONNECTION_EVENT_CLOSED) {
        _connections.remove(id);
        continue;
      }
      final value = event.connection;
      _connections[id] = CoreConnection(
        id: id,
        destination: value.destination,
        domain: value.domain,
        outbound: value.outbound,
        network: value.network,
        protocol: value.protocol,
        uplinkTotal: value.uplinkTotal.toInt(),
        downlinkTotal: value.downlinkTotal.toInt(),
        createdAt: value.createdAt.toInt(),
        closedAt: value.closedAt.toInt(),
      );
    }
    _publish(
      _copyCurrent(
        connections: _connections.values.toList(),
        traffic: TrafficSnapshot(
          uploadBytes: _current.traffic.uploadBytes,
          downloadBytes: _current.traffic.downloadBytes,
          activeConnections: _connections.length,
        ),
      ),
    );
  }

  Future<void> _shutdownTransport() async {
    final subscriptions = List<StreamSubscription<Object?>>.of(_subscriptions);
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    final channel = _channel;
    _channel = null;
    _daemon = null;
    _manager = null;
    _callOptions = null;
    await channel?.shutdown();
    final process = _daemonProcess;
    _daemonProcess = null;
    if (process != null) {
      process.kill();
      await process.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () => -1,
      );
    }
  }

  StartedServiceClient _requireDaemon(String operation) {
    final daemon = _daemon;
    if (daemon == null) {
      throw CoreUnavailableException('Start Libbox before $operation.');
    }
    return daemon;
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    Future<void> run() async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }

    _lifecycleTail = _lifecycleTail.then<void>(
      (_) => run(),
      onError: (_, _) => run(),
    );
    return completer.future;
  }

  CoreSnapshot _copyCurrent({
    CoreLifecycle? lifecycle,
    String? message,
    TrafficSnapshot? traffic,
    List<CoreConnection>? connections,
    List<ProxyGroup>? proxyGroups,
    List<LogEntry>? logs,
  }) {
    return CoreSnapshot(
      lifecycle: lifecycle ?? _current.lifecycle,
      message: message ?? _current.message,
      traffic: traffic ?? _current.traffic,
      connections: connections ?? _current.connections,
      proxyGroups: proxyGroups ?? _current.proxyGroups,
      logs: logs ?? _current.logs,
    );
  }

  void _publish(CoreSnapshot snapshot) {
    _current = snapshot;
    if (!_snapshots.isClosed) _snapshots.add(snapshot);
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw const CoreUnavailableException(
        'Libbox is supported on Windows, Linux, and macOS.',
      );
    }
  }

  Future<void> _ensureProxyPortAvailable() async {
    ServerSocket? socket;
    try {
      socket = await ServerSocket.bind(
        _settings.listenAddress,
        _settings.mixedPort,
        shared: false,
      );
    } on SocketException {
      throw CoreUnavailableException(
        'Proxy port ${_settings.listenAddress}:${_settings.mixedPort} is '
        'already in use.',
      );
    } finally {
      await socket?.close();
    }
  }

  static LogLevel _logLevel(daemon_pb.LogLevel level) => switch (level) {
    daemon_pb.LogLevel.TRACE => LogLevel.trace,
    daemon_pb.LogLevel.DEBUG => LogLevel.debug,
    daemon_pb.LogLevel.WARN => LogLevel.warning,
    daemon_pb.LogLevel.ERROR ||
    daemon_pb.LogLevel.FATAL ||
    daemon_pb.LogLevel.PANIC => LogLevel.error,
    _ => LogLevel.info,
  };
}

class _PendingUrlTest {
  _PendingUrlTest(this.startedAfter);

  final int startedAfter;
  final Completer<void> completer = Completer<void>();
}
