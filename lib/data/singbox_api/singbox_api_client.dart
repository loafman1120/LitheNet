import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../app/app_identity.dart';
import 'singbox_api_models.dart';
import 'singbox_api_proto.dart';

class SingboxApiException implements Exception {
  const SingboxApiException(this.message);

  final String message;

  @override
  String toString() => 'SingboxApiException: $message';
}

class SingboxApiClient {
  SingboxApiClient({
    required SingboxApiEndpoint endpoint,
    HttpClient? httpClient,
  })  : _endpoint = endpoint,
        _httpClient = httpClient ?? HttpClient();

  final SingboxApiEndpoint _endpoint;
  final HttpClient _httpClient;

  Stream<SingboxApiStatus> subscribeStatus({
    Duration interval = const Duration(seconds: 1),
  }) {
    return _stream(
      method: 'SubscribeStatus',
      request: encodeSubscribeStatusRequest(interval),
      decode: decodeStatus,
    );
  }

  Stream<SingboxApiConnectionEvents> subscribeConnections({
    Duration interval = const Duration(seconds: 1),
  }) {
    return _stream(
      method: 'SubscribeConnections',
      request: encodeSubscribeConnectionsRequest(interval),
      decode: decodeConnectionEvents,
    );
  }

  Stream<List<SingboxApiGroup>> subscribeGroups() {
    return _stream(
      method: 'SubscribeGroups',
      request: encodeEmpty(),
      decode: decodeGroups,
    );
  }

  Stream<List<SingboxApiGroupItem>> subscribeOutbounds() {
    return _stream(
      method: 'SubscribeOutbounds',
      request: encodeEmpty(),
      decode: decodeOutboundList,
    );
  }

  Future<void> urlTest(String outboundTag) {
    return _unary(
      method: 'URLTest',
      request: encodeUrlTestRequest(outboundTag),
    );
  }

  Future<void> selectOutbound({
    required String groupTag,
    required String outboundTag,
  }) {
    return _unary(
      method: 'SelectOutbound',
      request: encodeSelectOutboundRequest(groupTag, outboundTag),
    );
  }

  void close() {
    _httpClient.close(force: true);
  }

  Future<void> _unary({
    required String method,
    required Uint8List request,
  }) async {
    await for (final _ in _stream<Null>(
      method: method,
      request: request,
      decode: (_) => null,
    )) {
      return;
    }
  }

  Stream<T> _stream<T>({
    required String method,
    required Uint8List request,
    required T Function(Uint8List bytes) decode,
  }) async* {
    final httpRequest = await _httpClient.postUrl(_methodUri(method));
    httpRequest.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/grpc-web+proto')
      ..set('X-Grpc-Web', '1')
      ..set('X-User-Agent', AppIdentity.displayName)
      ..set(HttpHeaders.acceptHeader, 'application/grpc-web+proto');
    if (_endpoint.secret.isNotEmpty) {
      httpRequest.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${_endpoint.secret}',
      );
    }
    httpRequest.add(_frame(request));
    final response = await httpRequest.close();
    if (response.statusCode != HttpStatus.ok) {
      throw SingboxApiException(
        'API $method failed with HTTP ${response.statusCode}',
      );
    }

    final parser = _GrpcWebFrameParser();
    await for (final chunk in response) {
      for (final frame in parser.add(Uint8List.fromList(chunk))) {
        if (frame.isTrailer) {
          _checkTrailer(frame.payload, method);
        } else if (frame.payload.isNotEmpty) {
          yield decode(frame.payload);
        }
      }
    }
    for (final frame in parser.finish()) {
      if (frame.isTrailer) {
        _checkTrailer(frame.payload, method);
      } else if (frame.payload.isNotEmpty) {
        yield decode(frame.payload);
      }
    }
  }

  Uri _methodUri(String method) {
    return _endpoint.uri.replace(
      path: '/daemon.StartedService/$method',
    );
  }

  Uint8List _frame(Uint8List message) {
    final frame = Uint8List(5 + message.length);
    frame[0] = 0;
    final length = message.length;
    frame[1] = (length >> 24) & 0xff;
    frame[2] = (length >> 16) & 0xff;
    frame[3] = (length >> 8) & 0xff;
    frame[4] = length & 0xff;
    frame.setRange(5, frame.length, message);
    return frame;
  }

  void _checkTrailer(Uint8List payload, String method) {
    final text = String.fromCharCodes(payload);
    final status = RegExp(r'grpc-status:\s*(\d+)', caseSensitive: false)
        .firstMatch(text)
        ?.group(1);
    if (status != null && status != '0') {
      final message = RegExp(r'grpc-message:\s*(.*)', caseSensitive: false)
              .firstMatch(text)
              ?.group(1)
              ?.trim() ??
          'unknown gRPC error';
      throw SingboxApiException('API $method failed: $message');
    }
  }
}

class _GrpcWebFrame {
  const _GrpcWebFrame({
    required this.isTrailer,
    required this.payload,
  });

  final bool isTrailer;
  final Uint8List payload;
}

class _GrpcWebFrameParser {
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  Uint8List _pending = Uint8List(0);

  Iterable<_GrpcWebFrame> add(Uint8List chunk) sync* {
    if (_pending.isNotEmpty) {
      _buffer.add(_pending);
      _pending = Uint8List(0);
    }
    _buffer.add(chunk);
    yield* _drain(allowPartial: true);
  }

  Iterable<_GrpcWebFrame> finish() sync* {
    if (_pending.isNotEmpty) {
      _buffer.add(_pending);
      _pending = Uint8List(0);
    }
    yield* _drain(allowPartial: false);
  }

  Iterable<_GrpcWebFrame> _drain({required bool allowPartial}) sync* {
    final bytes = _buffer.takeBytes();
    var offset = 0;
    while (offset + 5 <= bytes.length) {
      final flags = bytes[offset];
      final length = (bytes[offset + 1] << 24) |
          (bytes[offset + 2] << 16) |
          (bytes[offset + 3] << 8) |
          bytes[offset + 4];
      if (offset + 5 + length > bytes.length) {
        break;
      }
      final start = offset + 5;
      final end = start + length;
      yield _GrpcWebFrame(
        isTrailer: (flags & 0x80) != 0,
        payload: Uint8List.sublistView(bytes, start, end),
      );
      offset = end;
    }
    if (offset < bytes.length) {
      final remaining = Uint8List.sublistView(bytes, offset);
      if (!allowPartial && remaining.isNotEmpty) {
        throw const FormatException('Incomplete gRPC-Web frame');
      }
      _pending = remaining;
    }
  }
}
