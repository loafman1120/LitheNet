import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/rustbox_config_builder.dart';
import 'package:lithenet/data/models/app_settings.dart';

void main() {
  test('builds the documented mixed inbound configuration', () {
    final config = RustBoxConfigBuilder.build(
      const AppSettings(listenAddress: '127.0.0.1', mixedPort: 2080),
    );

    expect(config, contains('schema_version = 1'));
    expect(config, contains('type = "mixed"'));
    expect(config, contains('listen = "127.0.0.1:2080"'));
    expect(config, contains('outbound = "direct"'));
  });

  test('builds TUN and optional IPv6 fields from settings', () {
    final config = RustBoxConfigBuilder.build(
      const AppSettings(
        proxyMode: ProxyMode.tun,
        systemProxy: false,
        ipv6: true,
      ),
    );

    expect(config, contains('type = "tun"'));
    expect(
      config,
      contains('addresses = ["172.18.0.1/30","fd00:1:fd00:1::1/126"]'),
    );
    expect(config, contains('platform_http_proxy = false'));
    expect(config, isNot(contains('type = "mixed"')));
  });

  test('rejects unsafe listen addresses', () {
    expect(
      () => RustBoxConfigBuilder.build(
        const AppSettings(listenAddress: '127.0.0.1\n[[outbounds]]'),
      ),
      throwsArgumentError,
    );
  });
}
