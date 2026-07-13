import '../../data/models/app_settings.dart';
import 'core_models.dart';

/// Stable app-facing boundary for the native proxy core.
///
/// The future Rustbox Dart package should implement this interface. Widgets and
/// feature controllers must not import the native package directly.
abstract interface class CoreGateway {
  String get name;
  bool get isAvailable;
  Stream<CoreSnapshot> get snapshots;

  Future<CoreSnapshot> current();
  Future<void> configure(AppSettings settings);
  Future<void> start();
  Future<void> stop();
  Future<void> selectOutbound(String groupId, String outboundId);
  Future<int?> testLatency(String outboundId);
  Future<void> clearLogs();
  Future<void> dispose();
}

class CoreUnavailableException implements Exception {
  const CoreUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Explicit placeholder used until the Rustbox Dart bridge is ready.
class UnavailableCoreGateway implements CoreGateway {
  const UnavailableCoreGateway();

  static const _message = 'Rustbox Dart bridge is not connected yet.';

  @override
  String get name => 'Rustbox';

  @override
  bool get isAvailable => false;

  @override
  Stream<CoreSnapshot> get snapshots => const Stream.empty();

  @override
  Future<CoreSnapshot> current() async => const CoreSnapshot(
    lifecycle: CoreLifecycle.unavailable,
    message: _message,
  );

  @override
  Future<void> configure(AppSettings settings) => _unavailable();

  @override
  Future<void> start() => _unavailable();

  @override
  Future<void> stop() => _unavailable();

  @override
  Future<void> selectOutbound(String groupId, String outboundId) =>
      _unavailable();

  @override
  Future<int?> testLatency(String outboundId) => _unavailable();

  @override
  Future<void> clearLogs() async {}

  @override
  Future<void> dispose() async {}

  Future<T> _unavailable<T>() =>
      Future.error(const CoreUnavailableException(_message));
}
