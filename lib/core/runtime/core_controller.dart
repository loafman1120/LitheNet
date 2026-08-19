import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/proxy_group.dart';
import '../../data/models/proxy_node.dart';
import 'core_gateway.dart';
import 'core_models.dart';

class CoreController extends ChangeNotifier {
  CoreController({
    required CoreGateway gateway,
    AppSettings initialSettings = const AppSettings(),
  }) : _gateway = gateway,
       _settings = initialSettings {
    _subscription = gateway.snapshots.listen(_applySnapshot);
    unawaited(_refresh());
  }

  final CoreGateway _gateway;
  late final StreamSubscription<CoreSnapshot> _subscription;
  AppSettings _settings;
  CoreSnapshot _snapshot = const CoreSnapshot(
    lifecycle: CoreLifecycle.unavailable,
    message: 'Libbox is not initialized yet.',
  );
  bool _busy = false;
  Future<void> Function()? _startupBarrier;

  String get backendName => _gateway.name;
  bool get available => _gateway.isAvailable;
  bool get busy => _busy;
  bool get running => _snapshot.lifecycle == CoreLifecycle.running;
  CoreLifecycle get lifecycle => _snapshot.lifecycle;
  String get message => _snapshot.message;
  String get status => switch (_snapshot.lifecycle) {
    CoreLifecycle.unavailable => 'Core unavailable',
    CoreLifecycle.stopped => 'Stopped',
    CoreLifecycle.starting => 'Starting',
    CoreLifecycle.running => 'Connected',
    CoreLifecycle.stopping => 'Stopping',
    CoreLifecycle.failed => 'Error',
  };
  AppSettings get settings => _settings;
  TrafficSnapshot get traffic => _snapshot.traffic;
  List<CoreConnection> get connections => _snapshot.connections;
  List<ProxyGroup> get proxyGroups => _snapshot.proxyGroups;
  List<LogEntry> get logs => _snapshot.logs;

  void setStartupBarrier(Future<void> Function() barrier) {
    _startupBarrier = barrier;
  }

  Future<void> configure(AppSettings settings) async {
    _settings = settings;
    if (!available) {
      notifyListeners();
      return;
    }
    await _run(() => _gateway.configure(settings));
  }

  Future<void> setProxyNodes(List<ProxyNode> nodes) async {
    if (!available) return;
    await _run(() => _gateway.setProxyNodes(nodes));
  }

  Future<void> setRawConfig(String? config) async {
    if (!available) return;
    await _run(() => _gateway.setRawConfig(config));
  }

  Future<void> start() async {
    if (!available) return;
    AppLogger.info('Connect requested using $backendName');
    await _run(() async {
      await _startupBarrier?.call();
      await _gateway.configure(_settings);
      await _gateway.start();
    }, operationName: 'connect');
  }

  Future<void> stop() async {
    if (!available) return;
    await _run(_gateway.stop, operationName: 'disconnect');
  }

  Future<void> selectOutbound(String groupId, String outboundId) async {
    if (!available) return;
    await _run(() => _gateway.selectOutbound(groupId, outboundId));
  }

  Future<int?> testLatency(String outboundId) async {
    if (!available) return null;
    try {
      return await _gateway.testLatency(outboundId);
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'Core latency test failed for `$outboundId`',
        source: 'core',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> closeConnection(String connectionId) async {
    if (!available) return false;
    final result = await _runValue(() async {
      await _gateway.closeConnection(connectionId);
      return true;
    }, operationName: 'close connection');
    return result ?? false;
  }

  Future<int?> closeAllConnections() {
    if (!available) return Future.value();
    return _runValue(
      _gateway.closeAllConnections,
      operationName: 'close all connections',
    );
  }

  Future<int?> refreshRuleSets() {
    if (!available) return Future.value();
    return _runValue(
      _gateway.refreshRuleSets,
      operationName: 'refresh rule sets',
    );
  }

  Future<void> clearLogs() async {
    await _gateway.clearLogs();
    _applySnapshot(
      CoreSnapshot(
        lifecycle: _snapshot.lifecycle,
        message: _snapshot.message,
        traffic: _snapshot.traffic,
        connections: _snapshot.connections,
        proxyGroups: _snapshot.proxyGroups,
      ),
    );
  }

  Future<void> _refresh() async {
    _applySnapshot(await _gateway.current());
  }

  Future<void> _run(
    Future<void> Function() operation, {
    String operationName = 'core operation',
  }) async {
    _busy = true;
    notifyListeners();
    try {
      await operation();
      _applySnapshot(await _gateway.current());
      AppLogger.info('Core $operationName completed');
    } on Object catch (error, stackTrace) {
      _setFailure(error, stackTrace, operationName: operationName);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<T?> _runValue<T>(
    Future<T> Function() operation, {
    required String operationName,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      final value = await operation();
      _applySnapshot(await _gateway.current());
      AppLogger.info('Core $operationName completed');
      return value;
    } on Object catch (error, stackTrace) {
      _setFailure(error, stackTrace, operationName: operationName);
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _setFailure(
    Object error,
    StackTrace stackTrace, {
    required String operationName,
  }) {
    AppLogger.error(
      'Core $operationName failed',
      source: 'core',
      error: error,
      stackTrace: stackTrace,
    );
    _applySnapshot(
      CoreSnapshot(
        lifecycle: CoreLifecycle.failed,
        message: error.toString(),
        traffic: _snapshot.traffic,
        connections: _snapshot.connections,
        proxyGroups: _snapshot.proxyGroups,
        logs: _snapshot.logs,
      ),
    );
  }

  void _applySnapshot(CoreSnapshot snapshot) {
    _snapshot = snapshot;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_gateway.dispose());
    super.dispose();
  }
}
