import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/libbox_config_builder.dart';
import 'package:lithenet/data/models/app_settings.dart';
import 'package:lithenet/data/models/proxy_node.dart';

void main() {
  test('builds a sing-box mixed inbound configuration', () {
    final config =
        jsonDecode(
              LibboxConfigBuilder.build(
                const AppSettings(listenAddress: '127.0.0.1', mixedPort: 2080),
              ),
            )
            as Map<String, dynamic>;

    expect(config['log'], containsPair('level', 'info'));
    expect(config['inbounds'], contains(containsPair('type', 'mixed')));
    expect((config['inbounds'] as List).single['listen_port'], 2080);
    expect(config['route'], containsPair('final', 'direct'));
  });

  test('builds TUN and optional IPv6 fields from settings', () {
    final config =
        jsonDecode(
              LibboxConfigBuilder.build(
                const AppSettings(
                  proxyMode: ProxyMode.tun,
                  systemProxy: false,
                  ipv6: true,
                ),
              ),
            )
            as Map<String, dynamic>;
    final inbound = (config['inbounds'] as List).single as Map;

    expect(inbound['type'], 'tun');
    expect(inbound['address'], contains('fd00:1:fd00:1::1/126'));
    expect(inbound['auto_route'], isTrue);
  });

  test('rejects unsafe listen addresses', () {
    expect(
      () => LibboxConfigBuilder.build(
        const AppSettings(listenAddress: '127.0.0.1\n{}'),
      ),
      throwsArgumentError,
    );
  });

  test('builds selector and URLTest groups from subscription nodes', () {
    final config =
        jsonDecode(
              LibboxConfigBuilder.build(
                const AppSettings(),
                proxyNodes: const [
                  ProxyNode(
                    id: 'vless-node',
                    name: 'VLESS',
                    type: 'vless',
                    metadata: {
                      'config': {
                        'server': 'vless.example.com',
                        'port': 443,
                        'uuid': '00000000-0000-0000-0000-000000000001',
                        'tls': true,
                      },
                    },
                  ),
                ],
              ),
            )
            as Map<String, dynamic>;
    final outbounds = config['outbounds'] as List;

    expect(outbounds, contains(containsPair('tag', 'vless-node')));
    expect(outbounds, contains(containsPair('tag', 'urltest')));
    expect(outbounds, contains(containsPair('tag', 'proxy')));
    expect(config['route'], containsPair('final', 'proxy'));
  });

  test('strips invalid ALPN only from anytls outbounds', () {
    final config = <String, dynamic>{
      'outbounds': [
        {
          'type': 'anytls',
          'tag': 'anytls-node',
          'tls': {'enabled': true, 'alpn': ['h3']},
        },
        {
          'type': 'hysteria2',
          'tag': 'hy2-node',
          'tls': {'enabled': true, 'alpn': ['h3']},
        },
        {'type': 'direct', 'tag': 'direct'},
      ],
    };

    LibboxConfigBuilder.normalizeAnyTlsAlpn(config);

    final outbounds = config['outbounds'] as List;
    final anyTls = outbounds[0] as Map;
    final hy2 = outbounds[1] as Map;
    expect(anyTls['tls'], isNot(contains('alpn')));
    expect(hy2['tls'], containsPair('alpn', ['h3']));
  });

  test('does not create a tun inbound in mixed mode', () {
    final inbounds = LibboxConfigBuilder.buildInbounds(
      const AppSettings(proxyMode: ProxyMode.mixed, mixedPort: 2080),
    );

    expect(inbounds, hasLength(1));
    expect(inbounds.single, containsPair('type', 'mixed'));
    expect(inbounds.single, containsPair('listen_port', 2080));
  });

  test('creates a tun inbound only in tun mode', () {
    final inbounds = LibboxConfigBuilder.buildInbounds(
      const AppSettings(proxyMode: ProxyMode.tun, systemProxy: false),
    );

    expect(inbounds, hasLength(1));
    expect(inbounds.single, containsPair('type', 'tun'));
  });
}
