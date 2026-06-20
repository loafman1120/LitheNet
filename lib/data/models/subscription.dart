import 'package:flutter/foundation.dart';

@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.url,
    this.lastUpdatedAt,
    this.expiresAt,
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.totalBytes,
    this.nodeCount = 0,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String url;
  final DateTime? lastUpdatedAt;
  final DateTime? expiresAt;
  final int uploadBytes;
  final int downloadBytes;
  final int? totalBytes;
  final int nodeCount;
  final bool enabled;

  double? get usagePercent {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (uploadBytes + downloadBytes) / total;
  }

  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  Subscription copyWith({
    String? id,
    String? name,
    String? url,
    DateTime? lastUpdatedAt,
    DateTime? expiresAt,
    int? uploadBytes,
    int? downloadBytes,
    int? totalBytes,
    int? nodeCount,
    bool? enabled,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      nodeCount: nodeCount ?? this.nodeCount,
      enabled: enabled ?? this.enabled,
    );
  }
}
