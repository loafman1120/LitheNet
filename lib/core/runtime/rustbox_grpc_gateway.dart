import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/proxy_group.dart';
import '../../data/models/proxy_node.dart';
import 'core_gateway.dart';
import 'core_models.dart';
import 'grpc/generated/rustbox.control.v1.pb.dart' as control_pb;
import 'grpc/generated/rustbox.control.v1.pbgrpc.dart';
import 'grpc/generated/started_service.pb.dart' as daemon_pb;
import 'grpc/generated/started_service.pbgrpc.dart';
import 'rustbox_config_builder.dart';
import 'rustbox_log_parser.dart';
import 'rustbox_process.dart';

class RustBoxGrpcGateway implements CoreGateway {
  RustBoxGrpcGateway({
    this._processResolver = const RustBoxProcessResolver(),
    Directory? workingDirectory,
  }) : _workingDirectory =
           workingDirectory ??
           Directory(
             '${Directory.systemTemp.path}${Platform.pathSeparator}lithenet',
           );

  final RustBoxProcessResolver _processResolver;
  final Directory _workingDirectory;
  final StreamController<CoreSnapshot> _snapshots =
      StreamController<CoreSnapshot>.broadcast();
  final List<LogEntry> _logs = [];
  final Set<String> _eventKeys = {};
  final Map<String, ProxyGroup> _groups = {};
  final Map<String, int> _latencies = {};

  AppSettings _settings = const AppSettings();
  Process? _process;
  ClientChannel? _channel;
  RustBoxControlClient? _control;
  StartedServiceClient? _daemon;
  CallOptions? _callOptions;
  StreamSubscription<daemon_pb.Groups>? _groupSubscription;
  Timer? _pollTimer;
  Future<void>? _refreshFuture;
  CoreSnapshot _current = const CoreSnapshot(
    lifecycle: CoreLifecycle.stopped,
    message: 'RustBox is ready.',
  );
  bool _disposed = false;

  @override
  String get name => 'RustBox gRPC';

  @override
  bool get isAvailable =>
      !_disposed && (Platform.isWindows || Platform.isLinux);

  @override
  Stream<CoreSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<CoreSnapshot> current() async {
    if (_control == null) {
      return _current;
    }
    await _refresh();
    return _current;
  }

  @override
  Future<void> configure(AppSettings settings) async {
    _settings = settings;
    RustBoxConfigBuilder.build(settings);
    if (_process != null) {
      await stop();
      await start();
    }
  }

  @override
  Future<void> start() async {
    _ensureAvailable();
    if (_process != null) {
      return;
    }

    _publish(
      _copyCurrent(
        lifecycle: CoreLifecycle.starting,
        message: 'Starting RustBox gRPC…',
      ),
    );

    final executable = await _processResolver.resolve();
    await _workingDirectory.create(recursive: true);
    final configFile = File(
      '${_workingDirectory.path}${Platform.pathSeparator}rustbox.toml',
    );
    await configFile.writeAsString(
      RustBoxConfigBuilder.build(_settings),
      flush: true,
    );
    final port = await _availablePort();
    final token = _randomToken();

    final process = await Process.start(executable, [
      'run',
      '--config',
      configFile.path,
      '--control-grpc',
      '127.0.0.1:$port',
      '--control-token',
      token,
    ]);
    _process = process;
    _captureProcessOutput(process.stdout, LogLevel.info, 'rustbox');
    _captureProcessOutput(process.stderr, LogLevel.warning, 'rustbox');
    unawaited(_watchProcess(process));

    final channel = ClientChannel(
      '127.0.0.1',
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _channel = channel;
    _control = RustBoxControlClient(channel);
    _daemon = StartedServiceClient(channel);
    _callOptions = CallOptions(
      metadata: {'authorization': 'Bearer $token'},
      timeout: const Duration(seconds: 3),
    );

    try {
      await _waitUntilReady();
      _subscribeGroups();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_refreshSafely()),
      );
      await _refresh();
    } catch (_) {
      await _shutdownTransport(killProcess: true);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    final process = _process;
    final client = _control;
    if (process == null || client == null) {
      _publish(
        _copyCurrent(
          lifecycle: CoreLifecycle.stopped,
          message: 'RustBox is stopped.',
        ),
      );
      return;
    }

    _publish(
      _copyCurrent(
        lifecycle: CoreLifecycle.stopping,
        message: 'Stopping RustBox…',
      ),
    );
    try {
      await client.stop(control_pb.StopRequest(), options: _callOptions);
      await process.exitCode.timeout(const Duration(seconds: 5));
    } on Object {
      process.kill();
      await process.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () => -1,
      );
    } finally {
      await _shutdownTransport();
      _publish(
        _copyCurrent(
          lifecycle: CoreLifecycle.stopped,
          message: 'RustBox is stopped.',
          traffic: TrafficSnapshot.zero,
          connections: const [],
        ),
      );
    }
  }

  @override
  Future<void> selectOutbound(String groupId, String outboundId) async {
    final daemon = _daemon;
    final group = _groups[groupId];
    if (daemon == null || group == null) {
      return;
    }
    await daemon.selectOutbound(
      daemon_pb.SelectOutboundRequest(
        groupTag: groupId,
        outboundTag: outboundId,
      ),
      options: _callOptions,
    );
  }

  @override
  Future<int?> testLatency(String outboundId) async => _latencies[outboundId];

  @override
  Future<void> clearLogs() async {
    _logs.clear();
    _publish(_copyCurrent(logs: const []));
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await stop();
    await _snapshots.close();
  }

  Future<void> _waitUntilReady() async {
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    Object? lastError;
    while (DateTime.now().isBefore(deadline)) {
      try {
        await _control!.getEngineSnapshot(
          control_pb.GetEngineSnapshotRequest(),
          options: _callOptions,
        );
        return;
      } on Object catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }
    throw StateError('RustBox gRPC did not become ready: $lastError');
  }

  void _subscribeGroups() {
    _groupSubscription = _daemon!
        .subscribeGroups(Empty(), options: _callOptions)
        .listen(_applyGroups, onError: (_) {});
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
                if (latency != null) {
                  _latencies[item.tag] = latency;
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

  Future<void> _refreshSafely() async {
    try {
      await _refresh();
    } on Object catch (error) {
      if (_process != null) {
        _publish(
          _copyCurrent(
            lifecycle: CoreLifecycle.failed,
            message: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    final existing = _refreshFuture;
    if (existing != null) {
      await existing;
      return;
    }
    final operation = _performRefresh();
    _refreshFuture = operation;
    try {
      await operation;
    } finally {
      if (identical(_refreshFuture, operation)) {
        _refreshFuture = null;
      }
    }
  }

  Future<void> _performRefresh() async {
    final client = _control;
    if (client == null) {
      return;
    }
    final results = await Future.wait<Object>([
      client.getEngineSnapshot(
        control_pb.GetEngineSnapshotRequest(),
        options: _callOptions,
      ),
      client.getObservabilitySnapshot(
        control_pb.GetObservabilitySnapshotRequest(),
        options: _callOptions,
      ),
    ]);
    final engine = results[0] as control_pb.EngineSnapshot;
    final observability = results[1] as control_pb.ObservabilitySnapshot;
    _applyEvents(observability.recentEvents);
    final metrics = observability.metrics;
    _publish(
      CoreSnapshot(
        lifecycle: _lifecycle(engine.state),
        message:
            '${engine.inboundCount} inbound · ${engine.outboundCount} outbound',
        traffic: TrafficSnapshot(
          uploadBytes: metrics.inboundToOutboundBytes.toInt(),
          downloadBytes: metrics.outboundToInboundBytes.toInt(),
          activeConnections: metrics.flowsActive.toInt(),
        ),
        connections: observability.connections.map(_connection).toList(),
        proxyGroups: _groups.values.toList(),
        logs: List.unmodifiable(_logs),
      ),
    );
  }

  CoreConnection _connection(control_pb.ConnectionStats value) {
    return CoreConnection(
      id: value.flowId.toString(),
      destination: value.destination,
      domain: '',
      outbound: value.outcome,
      network: value.network,
      protocol: value.state.name,
      uplinkTotal: value.inboundToOutboundBytes.toInt(),
      downlinkTotal: value.outboundToInboundBytes.toInt(),
    );
  }

  void _applyEvents(Iterable<control_pb.Event> events) {
    final now = DateTime.now();
    for (final event in events) {
      final key =
          '${event.flowId}|${event.level}|${event.target}|'
          '${event.kind}|${event.message}|${event.attributes}';
      if (!_eventKeys.add(key)) {
        continue;
      }
      _logs.add(
        LogEntry(
          time: now,
          level: _logLevel(event.level),
          source: event.target.isEmpty ? event.kind : event.target,
          message: event.message,
        ),
      );
    }
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
  }

  void _captureProcessOutput(
    Stream<List<int>> stream,
    LogLevel level,
    String source,
  ) {
    stream.transform(utf8.decoder).transform(const LineSplitter()).listen((
      line,
    ) {
      final parsed = parseRustBoxLogLine(line, level);
      if (parsed == null) {
        return;
      }
      _logs.add(
        LogEntry(
          time: DateTime.now(),
          level: parsed.level,
          source: source,
          message: parsed.message,
        ),
      );
    });
  }

  Future<void> _watchProcess(Process process) async {
    final exitCode = await process.exitCode;
    if (_process != process) {
      return;
    }
    await _shutdownTransport();
    if (!_disposed && _current.lifecycle != CoreLifecycle.stopping) {
      _publish(
        _copyCurrent(
          lifecycle: exitCode == 0
              ? CoreLifecycle.stopped
              : CoreLifecycle.failed,
          message: 'RustBox exited with code $exitCode.',
          traffic: TrafficSnapshot.zero,
          connections: const [],
        ),
      );
    }
  }

  Future<void> _shutdownTransport({bool killProcess = false}) async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _groupSubscription?.cancel();
    _groupSubscription = null;
    final channel = _channel;
    _channel = null;
    _control = null;
    _daemon = null;
    _callOptions = null;
    await channel?.shutdown();
    final process = _process;
    _process = null;
    if (killProcess) {
      process?.kill();
    }
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
    if (!_snapshots.isClosed) {
      _snapshots.add(snapshot);
    }
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw const CoreUnavailableException(
        'RustBox gRPC process mode is supported on Windows and Linux.',
      );
    }
  }

  CoreLifecycle _lifecycle(control_pb.EngineState state) => switch (state) {
    control_pb.EngineState.ENGINE_STATE_CREATED ||
    control_pb.EngineState.ENGINE_STATE_PREPARED ||
    control_pb.EngineState.ENGINE_STATE_STOPPED => CoreLifecycle.stopped,
    control_pb.EngineState.ENGINE_STATE_RUNNING => CoreLifecycle.running,
    control_pb.EngineState.ENGINE_STATE_STOPPING => CoreLifecycle.stopping,
    control_pb.EngineState.ENGINE_STATE_FAILED => CoreLifecycle.failed,
    _ => CoreLifecycle.unavailable,
  };

  LogLevel _logLevel(String value) => switch (value.toLowerCase()) {
    'trace' => LogLevel.trace,
    'debug' => LogLevel.debug,
    'warn' || 'warning' => LogLevel.warning,
    'error' => LogLevel.error,
    _ => LogLevel.info,
  };

  Future<int> _availablePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  String _randomToken() {
    final random = Random.secure();
    return List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
