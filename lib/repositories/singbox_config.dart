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
        'address': ['172.19.0.1/30'],
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

Directory _ensureAppDirectory() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      Directory.current.path;
  final separator = Platform.pathSeparator;
  final dir = Directory('$home$separator.lithenet');
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
