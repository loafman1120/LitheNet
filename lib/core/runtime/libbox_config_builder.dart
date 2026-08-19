import 'dart:convert';
import 'dart:io';

import '../../data/models/app_settings.dart';
import '../../data/models/proxy_node.dart';

String singBoxWindowsPath(String path) {
  final absolute = File(path).absolute.path.replaceAll(r'\', '/');
  if (RegExp(r'^[A-Za-z]:/').hasMatch(absolute)) {
    return '//?/$absolute';
  }
  return absolute;
}

class LibboxConfigBuilder {
  const LibboxConfigBuilder._();

  static void migrateLegacyTransports(Map<String, dynamic> config) {
    final rawOutbounds = config['outbounds'];
    if (rawOutbounds is! List) return;

    config['outbounds'] = rawOutbounds.map((rawOutbound) {
      if (rawOutbound is! Map) return rawOutbound;
      final outbound = Map<String, dynamic>.from(rawOutbound);
      final rawTransport = outbound['transport'];
      if (rawTransport is! Map) return outbound;

      final transport = Map<String, dynamic>.from(rawTransport);
      final host = transport.remove('host');
      if (host != null) {
        final headers = transport['headers'] is Map
            ? Map<String, dynamic>.from(transport['headers'] as Map)
            : <String, dynamic>{};
        final hasHost = headers.keys.any((key) => key.toLowerCase() == 'host');
        if (!hasHost) headers['Host'] = host;
        transport['headers'] = headers;
      }
      outbound['transport'] = transport;
      return outbound;
    }).toList();
  }

  static String build(
    AppSettings settings, {
    List<ProxyNode> proxyNodes = const [],
    String? cacheFilePath,
  }) {
    final address = settings.listenAddress.trim();
    if (address.isEmpty || address.contains(RegExp(r'[\r\n]'))) {
      throw ArgumentError.value(
        settings.listenAddress,
        'listenAddress',
        'must be a single non-empty address',
      );
    }
    if (settings.mixedPort <= 0 || settings.mixedPort >= 65536) {
      throw RangeError.range(settings.mixedPort, 1, 65535, 'mixedPort');
    }

    final inbounds = <Map<String, Object?>>[];
    if (settings.proxyMode == ProxyMode.mixed || settings.systemProxy) {
      inbounds.add({
        'type': 'mixed',
        'tag': 'mixed',
        'listen': address,
        'listen_port': settings.mixedPort,
      });
    }
    if (settings.proxyMode == ProxyMode.tun) {
      inbounds.add({
        'type': 'tun',
        'tag': 'tun',
        'interface_name': 'lithe0',
        'address': ['172.18.0.1/30', if (settings.ipv6) 'fd00:1:fd00:1::1/126'],
        'mtu': 1500,
        'auto_route': true,
        'strict_route': false,
        'route_exclude_address': ['127.0.0.0/8'],
      });
    }

    final outbounds = <Map<String, Object?>>[
      {'type': 'direct', 'tag': 'direct'},
    ];
    final outboundTags = <String>[];
    for (final node in proxyNodes) {
      final config = node.metadata['config'];
      if (config is! Map) continue;
      final outbound = _outbound(node, Map<String, dynamic>.from(config));
      if (outbound == null) continue;
      outbounds.add(outbound);
      outboundTags.add(node.id);
    }

    var finalOutbound = 'direct';
    if (outboundTags.isNotEmpty) {
      outbounds.add({
        'type': 'urltest',
        'tag': 'urltest',
        'outbounds': outboundTags,
        'url': 'https://www.gstatic.com/generate_204',
        'interval': '5m',
        'tolerance': 50,
      });
      outbounds.add({
        'type': 'selector',
        'tag': 'proxy',
        'outbounds': ['urltest', ...outboundTags, 'direct'],
        'default': 'urltest',
      });
      finalOutbound = 'proxy';
    }

    final config = <String, Object?>{
      'log': {'level': 'info', 'timestamp': true},
      'inbounds': inbounds,
      'outbounds': outbounds,
      'route': {'auto_detect_interface': true, 'final': finalOutbound},
    };
    if (cacheFilePath != null && cacheFilePath.trim().isNotEmpty) {
      config['experimental'] = {
        'cache_file': {
          'enabled': true,
          'path': singBoxWindowsPath(cacheFilePath),
        },
      };
    }
    return jsonEncode(config);
  }

  static Map<String, Object?>? _outbound(
    ProxyNode node,
    Map<String, dynamic> config,
  ) {
    final server = (config['server'] ?? config['address'])?.toString();
    final serverPort = _int(config['port'] ?? config['server_port']);
    if (server == null || server.isEmpty || serverPort == null) return null;

    final type = switch (node.type.toLowerCase()) {
      'ss' || 'shadowsocks' => 'shadowsocks',
      'socks5' => 'socks',
      'hy2' => 'hysteria2',
      'tuic-v5' => 'tuic',
      'naiveproxy' => 'naive',
      'shadow-tls' => 'shadowtls',
      'any-tls' => 'anytls',
      final value => value,
    };
    if (!const {
      'shadowsocks',
      'vmess',
      'vless',
      'trojan',
      'hysteria2',
      'tuic',
      'naive',
      'shadowtls',
      'anytls',
      'socks',
      'http',
    }.contains(type)) {
      return null;
    }

    final outbound = <String, Object?>{
      'type': type,
      'tag': node.id,
      'server': server,
      'server_port': serverPort,
    };
    void copy(String target, [String? source]) {
      final value = config[source ?? target];
      if (value != null) outbound[target] = value;
    }

    switch (type) {
      case 'shadowsocks':
        outbound['method'] = config['cipher'] ?? config['method'];
        copy('password');
      case 'vmess':
        copy('uuid');
        outbound['security'] = config['cipher'] ?? config['security'] ?? 'auto';
        outbound['alter_id'] =
            _int(config['alterId'] ?? config['alter_id']) ?? 0;
      case 'vless':
        copy('uuid');
        copy('flow');
      case 'trojan' || 'hysteria2' || 'anytls':
        outbound['password'] =
            config['password'] ?? config['auth'] ?? config['auth-str'];
      case 'tuic':
        copy('uuid');
        copy('password');
        copy('congestion_control');
      case 'naive':
        outbound['username'] = config['username'] ?? config['user'];
        copy('password');
      case 'shadowtls':
        outbound['version'] = _int(config['version']) ?? 3;
        copy('password');
      case 'socks' || 'http':
        copy('username');
        copy('password');
    }

    if (_requiresTls(type, config)) {
      final sourceTls = config['tls'];
      final tls = sourceTls is Map
          ? Map<String, dynamic>.from(sourceTls)
          : <String, dynamic>{};
      final tlsConfig = <String, Object?>{
        'enabled': true,
        'server_name': tls['server_name'] ?? config['sni'] ?? server,
        'insecure': tls['insecure'] ?? config['skip-cert-verify'] == true,
      };
      final reality = config['reality'];
      if (reality is Map && reality['public_key'] != null) {
        tlsConfig['reality'] = {
          'enabled': true,
          'public_key': reality['public_key'],
          'short_id': reality['short_id'] ?? '',
        };
      }
      outbound['tls'] = tlsConfig;
    }
    final transport = config['transport'];
    if (transport is Map && transport['type'] != null) {
      final transportConfig = Map<String, dynamic>.from(transport);
      if (transportConfig['type'] == 'web-socket') {
        transportConfig['type'] = 'ws';
      }
      outbound['transport'] = transportConfig;
    }

    final required = switch (type) {
      'shadowsocks' => ['method', 'password'],
      'vmess' || 'vless' => ['uuid'],
      'trojan' || 'hysteria2' || 'anytls' || 'shadowtls' => ['password'],
      'tuic' => ['uuid', 'password'],
      'naive' => ['username', 'password'],
      _ => const <String>[],
    };
    if (required.any((key) => outbound[key] == null)) return null;
    outbound.removeWhere((_, value) => value == null);
    return outbound;
  }

  static bool _requiresTls(String type, Map<String, dynamic> config) {
    if (const {
      'trojan',
      'hysteria2',
      'tuic',
      'naive',
      'anytls',
    }.contains(type)) {
      return true;
    }
    return config['tls'] == true ||
        config['tls'] == 'tls' ||
        config['tls'] is Map ||
        config['reality'] is Map;
  }

  static int? _int(Object? value) => switch (value) {
    int number => number,
    String text => int.tryParse(text),
    _ => null,
  };
}
