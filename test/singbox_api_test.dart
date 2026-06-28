import 'dart:convert';

import 'package:lithenet/data/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/singbox_api/singbox_api_config.dart';
import 'package:lithenet/data/singbox_api/singbox_api_models.dart';
import 'package:lithenet/data/singbox_api/singbox_api_proto.dart';
import 'package:lithenet/repositories/proxy_repository.dart';

void main() {
  test('injects api service into sing-box config', () {
    final config = const JsonEncoder.withIndent('  ').convert({
      'log': {'level': 'info'},
      'inbounds': [
        {'type': 'mixed', 'tag': 'mixed-in'},
      ],
      'outbounds': [
        {'type': 'direct', 'tag': 'direct'},
      ],
    });

    final injected = const SingboxApiConfigInjector().inject(
      config,
      const SingboxApiEndpoint(port: 19090, secret: 'secret'),
    );
    final decoded = jsonDecode(injected) as Map<String, dynamic>;
    final services = decoded['services'] as List<dynamic>;
    final api = services.single as Map<String, dynamic>;

    expect(api['type'], 'api');
    expect(api['tag'], 'lithenet-api');
    expect(api['listen'], '127.0.0.1');
    expect(api['listen_port'], 19090);
    expect(api['secret'], 'secret');
    expect(decoded['inbounds'], isNotEmpty);
  });

  test('decodes started service status traffic fields', () {
    final writer = ProtoWriter()
      ..int64Field(3, 2)
      ..int64Field(4, 3)
      ..int64Field(5, 1)
      ..int64Field(6, 100)
      ..int64Field(7, 200)
      ..int64Field(8, 1024)
      ..int64Field(9, 2048);

    final status = decodeStatus(writer.takeBytes());

    expect(status.connectionsIn, 2);
    expect(status.connectionsOut, 3);
    expect(status.trafficAvailable, isTrue);
    expect(status.uplinkTotal, 1024);
    expect(status.downlinkTotal, 2048);
  });

  test('normalizes connection timestamps to unix seconds', () {
    final connection = ProtoWriter()
      ..stringField(1, 'conn-1')
      ..int64Field(12, 1760000000123456789)
      ..int64Field(13, 1760000060123456789);
    final event = ProtoWriter()
      ..int64Field(1, 1)
      ..stringField(2, 'conn-1')
      ..bytesField(3, connection.takeBytes())
      ..int64Field(6, 1760000060123);
    final response = ProtoWriter()..bytesField(1, event.takeBytes());

    final events = decodeConnectionEvents(response.takeBytes());
    final decoded = events.events.single;

    expect(decoded.connection?.createdAt, 1760000000);
    expect(decoded.connection?.closedAt, 1760000060);
    expect(decoded.closedAt, 1760000060);
  });

  test('generates tun proxy config for Windows TUN mode', () {
    final repository = SingboxProxyRepository()..setProxyMode(ProxyMode.tun);
    addTearDown(repository.dispose);

    final config = jsonDecode(repository.configJson) as Map<String, dynamic>;
    final inbounds = config['inbounds'] as List<dynamic>;
    final inbound = inbounds.single as Map<String, dynamic>;
    final route = config['route'] as Map<String, dynamic>;

    expect(inbound['type'], 'tun');
    expect(inbound['tag'], 'tun-in');
    expect(inbound['auto_route'], isTrue);
    expect(inbound['strict_route'], isTrue);
    expect(inbound['address'], ['172.19.0.1/30']);
    expect(inbound.containsKey('sniff'), isFalse);
    expect(route['auto_detect_interface'], isTrue);
    expect(route['rules'], [
      {'inbound': 'tun-in', 'action': 'sniff'},
    ]);
  });
}
