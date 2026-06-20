import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/singbox_api/singbox_api_config.dart';
import 'package:lithenet/data/singbox_api/singbox_api_models.dart';
import 'package:lithenet/data/singbox_api/singbox_api_proto.dart';

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
}
