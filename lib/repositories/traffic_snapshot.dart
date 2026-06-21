part of 'proxy_repository.dart';

/// Immutable traffic counters shown by the app UI.
@immutable
class TrafficSnapshot {
  /// Creates a traffic snapshot from byte counters and connection count.
  const TrafficSnapshot({
    required this.uploadBytes,
    required this.downloadBytes,
    required this.activeConnections,
  });

  /// Empty traffic snapshot used before live API data arrives.
  static const zero = TrafficSnapshot(
    uploadBytes: 0,
    downloadBytes: 0,
    activeConnections: 0,
  );

  /// Total uploaded bytes.
  final int uploadBytes;

  /// Total downloaded bytes.
  final int downloadBytes;

  /// Current active connection count.
  final int activeConnections;

  /// Combined uploaded and downloaded bytes.
  int get totalBytes => uploadBytes + downloadBytes;

  /// Returns a copy with selected fields replaced.
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
