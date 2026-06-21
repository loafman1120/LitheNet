part of 'proxy_repository.dart';

/// Defines the app-facing contract for proxy core state and operations.
abstract class ProxyRepository extends ChangeNotifier {
  /// Whether a repository command is currently running.
  bool get busy;

  /// Whether the bundled sing-box core has been loaded.
  bool get coreLoaded;

  /// Whether the proxy service is currently running.
  bool get running;

  /// Whether the service should configure the OS system proxy.
  bool get systemProxyEnabled;

  /// Short user-facing service status.
  String get status;

  /// Detailed user-facing status or error message.
  String get message;

  /// Host address used by the local mixed proxy inbound.
  String get listenAddress;

  /// Port used by the local mixed proxy inbound.
  int get mixedPort;

  /// Current sing-box configuration JSON.
  String get configJson;

  /// Human-readable source used to load the core.
  String? get loadedCoreSource;

  /// Loaded sing-box core version, when available.
  String? get singboxVersion;

  /// Go runtime version reported by the core, when available.
  String? get goVersion;

  /// Latest traffic counters from the local API.
  TrafficSnapshot get traffic;

  /// Active connections reported by the local API.
  List<SingboxApiConnection> get connections;

  /// Proxy groups reported by the local API.
  List<SingboxApiGroup> get apiGroups;

  /// Outbound items reported by the local API.
  List<SingboxApiGroupItem> get apiOutbounds;

  /// Recent core and API log entries.
  List<LogEntry> get logs;

  /// Combined sing-box and Go version line for display.
  String get versionLine {
    final singbox = singboxVersion;
    final go = goVersion;
    if (singbox == null || go == null) {
      return 'Core not loaded';
    }
    return 'sing-box $singbox - $go';
  }

  /// Updates the local mixed proxy endpoint and regenerates the default config.
  void updateEndpoint({
    required String listenAddress,
    required int mixedPort,
  });

  /// Enables or disables OS system proxy integration.
  Future<void> setSystemProxyEnabled(bool enabled);

  /// Replaces the current configuration JSON.
  void updateConfig(String configJson);

  /// Restores a direct outbound configuration for the current endpoint.
  void resetDirectConfig();

  /// Loads and initializes the bundled sing-box core.
  Future<void> loadCore();

  /// Validates the current configuration JSON.
  Future<void> validateConfig();

  /// Starts the local proxy service.
  Future<void> start();

  /// Reloads the running proxy service with the current config.
  Future<void> reload();

  /// Stops the local proxy service and clears live API state.
  Future<void> stop();

  /// Selects an outbound for the given proxy group.
  Future<void> selectOutbound({
    required String groupTag,
    required String outboundTag,
  });

  /// Requests a URL latency test for an outbound.
  Future<void> urlTest(String outboundTag);

  /// Clears cached and native log entries.
  void clearLogs();
}
