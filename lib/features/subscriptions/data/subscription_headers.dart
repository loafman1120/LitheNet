import 'dart:convert';
import 'dart:io';

class SubscriptionHeaderMetadata {
  const SubscriptionHeaderMetadata({
    this.title,
    this.updateIntervalSeconds,
    this.uploadBytes,
    this.downloadBytes,
    this.totalBytes,
    this.expiresAt,
    this.webPageUrl,
    this.supportUrl,
    this.movedPermanentlyTo,
    this.etag,
    this.lastModified,
  });

  final String? title;
  final int? updateIntervalSeconds;
  final int? uploadBytes;
  final int? downloadBytes;
  final int? totalBytes;
  final DateTime? expiresAt;
  final String? webPageUrl;
  final String? supportUrl;
  final String? movedPermanentlyTo;
  final String? etag;
  final DateTime? lastModified;
}

class SubscriptionHeaderParser {
  const SubscriptionHeaderParser();

  SubscriptionHeaderMetadata parse(Map<String, String> headers) {
    final normalized = {
      for (final entry in headers.entries)
        entry.key.toLowerCase(): entry.value.trim(),
    };
    final userInfo = _parseUserInfo(normalized['subscription-userinfo']);
    return SubscriptionHeaderMetadata(
      title: _parseTitle(normalized),
      updateIntervalSeconds:
          _parseUpdateInterval(normalized['profile-update-interval']),
      uploadBytes: userInfo['upload'],
      downloadBytes: userInfo['download'],
      totalBytes: userInfo['total'],
      expiresAt: _parseUnixSeconds(userInfo['expire']),
      webPageUrl: normalized['profile-web-page-url'],
      supportUrl: normalized['support-url'],
      movedPermanentlyTo: normalized['moved-permanently-to'],
      etag: normalized['etag'],
      lastModified: _parseHttpDate(normalized['last-modified']),
    );
  }

  String? _parseTitle(Map<String, String> headers) {
    final profileTitle = headers['profile-title'];
    if (profileTitle != null && profileTitle.isNotEmpty) {
      if (profileTitle.startsWith('base64:')) {
        return utf8.decode(base64.decode(profileTitle.substring(7)));
      }
      return profileTitle;
    }

    final disposition = headers['content-disposition'];
    if (disposition == null) {
      return null;
    }
    final utf8Name =
        RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(disposition)?.group(1);
    if (utf8Name != null) {
      return Uri.decodeComponent(utf8Name);
    }
    return RegExp(r'filename="?([^";]+)"?').firstMatch(disposition)?.group(1);
  }

  int? _parseUpdateInterval(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed * 3600;
  }

  Map<String, int> _parseUserInfo(String? value) {
    if (value == null || value.isEmpty) {
      return const {};
    }
    final result = <String, int>{};
    for (final part in value.split(';')) {
      final pair = part.trim().split('=');
      if (pair.length != 2) {
        continue;
      }
      final parsed = int.tryParse(pair[1].trim());
      if (parsed != null) {
        result[pair[0].trim().toLowerCase()] = parsed;
      }
    }
    return result;
  }

  DateTime? _parseUnixSeconds(int? value) {
    if (value == null || value <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }

  DateTime? _parseHttpDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return HttpDate.parse(value);
    } catch (_) {
      return null;
    }
  }
}
