part of 'proxy_repository.dart';

String _buildDirectConfig({
  required String listenAddress,
  required int mixedPort,
  required ProxyMode proxyMode,
}) {
  final inbound = switch (proxyMode) {
    ProxyMode.mixed => {
        'type': 'mixed',
        'tag': 'mixed-in',
        'listen': listenAddress,
        'listen_port': mixedPort,
      },
    ProxyMode.tun => {
        'type': 'tun',
        'tag': 'tun-in',
        'address': [_buildRuntimeTunAddress()],
        'auto_route': true,
        'strict_route': true,
      },
  };
  final route = switch (proxyMode) {
    ProxyMode.mixed => {'final': 'direct'},
    ProxyMode.tun => {
        'auto_detect_interface': true,
        'rules': [
          {
            'inbound': 'tun-in',
            'action': 'sniff',
          },
        ],
        'final': 'direct',
      },
  };

  return const JsonEncoder.withIndent('  ').convert({
    'log': {'level': 'info'},
    'inbounds': [inbound],
    'outbounds': [
      {'type': 'direct', 'tag': 'direct'},
    ],
    'route': route,
  });
}

String _buildRuntimeCacheFileName() {
  final processId = _processIdOrZero();
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final suffix = _generateRuntimeSecret(8).toLowerCase();
  return '${AppIdentity.dartPackageName}-cache-$processId-$timestamp-$suffix.db';
}

String _buildRuntimeTunAddress() {
  final seed = DateTime.now().microsecondsSinceEpoch + _processIdOrZero();
  final secondOctet = 16 + seed % 16;
  final thirdOctet = (seed ~/ 16) % 256;
  return '172.$secondOctet.$thirdOctet.1/30';
}

int _processIdOrZero() {
  try {
    return pid;
  } catch (_) {
    return 0;
  }
}

void _ensureRuntimeCacheFile(
  Map<String, dynamic> config,
  String cacheFileName,
) {
  final experimental = _mapFrom(config['experimental']);
  final cacheFile = _mapFrom(experimental['cache_file']);
  final enabled = cacheFile['enabled'];

  if (enabled == false) {
    config['experimental'] = experimental;
    experimental['cache_file'] = cacheFile;
    return;
  }

  final path = cacheFile['path'];
  if (path is! String || path.trim().isEmpty || path.trim() == 'cache.db') {
    cacheFile['path'] = cacheFileName;
  }

  cacheFile['enabled'] = true;
  experimental['cache_file'] = cacheFile;
  config['experimental'] = experimental;
}

Map<String, dynamic> _mapFrom(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

Directory _ensureAppDirectory() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      Directory.current.path;
  final separator = Platform.pathSeparator;
  final dir = Directory('$home$separator.lithe');
  dir.createSync(recursive: true);
  return dir;
}

Directory _ensureCoreDirectory([AppStoragePaths? storagePaths]) {
  final dir = storagePaths?.coreDirectory ?? _ensureAppDirectory();
  dir.createSync(recursive: true);
  return dir;
}

Future<int> _findAvailableLoopbackPort({
  int preferredPort = 0,
  int attempts = 20,
}) async {
  if (preferredPort <= 0) {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  for (var offset = 0; offset < attempts; offset += 1) {
    final port = preferredPort + offset;
    try {
      final socket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      await socket.close();
      return port;
    } on SocketException {
      continue;
    }
  }

  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

String _generateRuntimeSecret([int bytes = 24]) {
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(
    List<int>.generate(
      bytes,
      (_) => alphabet.codeUnitAt(random.nextInt(alphabet.length)),
    ),
  );
}
