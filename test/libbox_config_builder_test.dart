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
}
