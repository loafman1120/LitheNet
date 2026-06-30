import 'dart:async';
import 'dart:io';

import '../../../data/models/subscription.dart';
import 'subscription_errors.dart';

abstract class SubscriptionFetcher {
  Future<FetchResult> fetch(Subscription subscription);
}

class FetchResult {
  const FetchResult({
    required this.subscriptionId,
    required this.statusCode,
    required this.headers,
    required this.bodyBytes,
    required this.duration,
    required this.notModified,
  });

  final String subscriptionId;
  final int statusCode;
  final Map<String, String> headers;
  final List<int> bodyBytes;
  final Duration duration;
  final bool notModified;
}

class HttpSubscriptionFetcher implements SubscriptionFetcher {
  HttpSubscriptionFetcher({
    HttpClient? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? HttpClient() {
    _client.autoUncompress = false;
  }

  final HttpClient _client;
  final Duration timeout;

  @override
  Future<FetchResult> fetch(Subscription subscription) async {
    final stopwatch = Stopwatch()..start();
    final uri = Uri.tryParse(subscription.url);
    if (uri == null || uri.host.isEmpty) {
      throw const SubscriptionException(
        SubscriptionErrorCodes.invalidUrl,
        'Subscription URL is invalid.',
      );
    }
    if (uri.scheme != 'https' &&
        !(subscription.allowInsecureHttp && uri.scheme == 'http')) {
      throw const SubscriptionException(
        SubscriptionErrorCodes.safe,
        'Only HTTPS subscriptions are allowed by default.',
      );
    }

    try {
      final request = await _client.getUrl(uri).timeout(timeout);
      for (final header in SubscriptionRequestDefaults.headers.entries) {
        request.headers.set(header.key, header.value);
      }
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'gzip');
      request.headers.set(
        HttpHeaders.userAgentHeader,
        _effectiveUserAgent(subscription.userAgent),
      );
      for (final header in subscription.headers.entries) {
        request.headers.set(header.key, header.value);
      }
      final etag = subscription.lastEtag;
      if (etag != null && etag.isNotEmpty) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final lastModified = subscription.lastModified;
      if (lastModified != null) {
        request.headers.set(
          HttpHeaders.ifModifiedSinceHeader,
          HttpDate.format(lastModified.toUtc()),
        );
      }

      final response = await request.close().timeout(timeout);
      final headers = _headersToMap(response.headers);
      final statusCode = response.statusCode;

      if (statusCode == HttpStatus.notModified) {
        return FetchResult(
          subscriptionId: subscription.id,
          statusCode: statusCode,
          headers: headers,
          bodyBytes: const [],
          duration: stopwatch.elapsed,
          notModified: true,
        );
      }
      if (statusCode == HttpStatus.unauthorized ||
          statusCode == HttpStatus.forbidden) {
        throw SubscriptionException(
          SubscriptionErrorCodes.auth,
          'Authentication failed with HTTP $statusCode.',
        );
      }
      if (statusCode < 200 || statusCode >= 300) {
        throw SubscriptionException(
          SubscriptionErrorCodes.network,
          'Subscription server returned HTTP $statusCode.',
        );
      }

      final bytes = await response.fold<List<int>>(
        <int>[],
        (buffer, chunk) => buffer..addAll(chunk),
      );
      return FetchResult(
        subscriptionId: subscription.id,
        statusCode: statusCode,
        headers: headers,
        bodyBytes: _decodeBody(headers, bytes),
        duration: stopwatch.elapsed,
        notModified: false,
      );
    } on SubscriptionException {
      rethrow;
    } on TimeoutException catch (error) {
      throw SubscriptionException(
        SubscriptionErrorCodes.network,
        'Subscription request timed out: $error',
      );
    } on HandshakeException catch (error) {
      throw SubscriptionException(
        SubscriptionErrorCodes.network,
        'TLS handshake failed: $error',
      );
    } on Object catch (error) {
      throw SubscriptionException(
        SubscriptionErrorCodes.network,
        'Subscription request failed: $error',
      );
    }
  }

  Map<String, String> _headersToMap(HttpHeaders headers) {
    final result = <String, String>{};
    headers.forEach((name, values) {
      result[name.toLowerCase()] = values.join(',');
    });
    return result;
  }

  String _effectiveUserAgent(String userAgent) {
    final trimmed = userAgent.trim();
    if (trimmed.isEmpty ||
        trimmed == 'LitheNet/0.1' ||
        trimmed == 'clash.meta') {
      return SubscriptionRequestDefaults.userAgent;
    }
    return trimmed;
  }

  List<int> _decodeBody(Map<String, String> headers, List<int> bytes) {
    final encoding = headers[HttpHeaders.contentEncodingHeader]?.toLowerCase();
    if (encoding != null && encoding.contains('gzip')) {
      return gzip.decode(bytes);
    }
    return bytes;
  }
}
