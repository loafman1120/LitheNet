import 'dart:convert';

import '../../data/models/app_settings.dart';

class RustBoxConfigBuilder {
  const RustBoxConfigBuilder._();

  static String build(AppSettings settings) {
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

    final buffer = StringBuffer()
      ..writeln('schema_version = 1')
      ..writeln()
      ..writeln('[observability]')
      ..writeln('level = "info"')
      ..writeln();

    if (settings.proxyMode == ProxyMode.mixed || settings.systemProxy) {
      buffer
        ..writeln('[[inbounds]]')
        ..writeln('id = "mixed"')
        ..writeln('type = "mixed"')
        ..writeln('listen = ${jsonEncode('$address:${settings.mixedPort}')}')
        ..writeln();
    }

    if (settings.proxyMode == ProxyMode.tun) {
      final addresses = <String>[
        '172.18.0.1/30',
        if (settings.ipv6) 'fd00:1:fd00:1::1/126',
      ];
      buffer
        ..writeln('[[inbounds]]')
        ..writeln('id = "tun"')
        ..writeln('type = "tun"')
        ..writeln('interface_name = "lithenet0"')
        ..writeln('addresses = ${jsonEncode(addresses)}')
        ..writeln('mtu = 1500')
        ..writeln('auto_route = true')
        ..writeln('strict_route = false')
        ..writeln('route_excludes = ["127.0.0.0/8"]')
        ..writeln('platform_http_proxy = ${settings.systemProxy}')
        ..writeln('auto_redirect = false')
        ..writeln();
    }

    buffer
      ..writeln('[[outbounds]]')
      ..writeln('id = "direct"')
      ..writeln('type = "direct"')
      ..writeln()
      ..writeln('[[routes]]')
      ..writeln('type = "default"')
      ..writeln('outbound = "direct"');
    return buffer.toString();
  }
}
