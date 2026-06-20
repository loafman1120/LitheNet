import 'dart:convert';

import 'singbox_api_models.dart';

class SingboxApiConfigInjector {
  const SingboxApiConfigInjector({
    this.tag = 'lithenet-api',
  });

  final String tag;

  String inject(String configJson, SingboxApiEndpoint endpoint) {
    final decoded = jsonDecode(configJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('sing-box config must be a JSON object');
    }
    final config = Map<String, dynamic>.from(decoded);
    final services = _services(config)
      ..removeWhere(
          (service) => service['type'] == 'api' || service['tag'] == tag)
      ..add(_apiService(endpoint));
    config['services'] = services;
    return const JsonEncoder.withIndent('  ').convert(config);
  }

  List<Map<String, dynamic>> _services(Map<String, dynamic> config) {
    final raw = config['services'];
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    if (raw is! List) {
      throw const FormatException('sing-box services must be a list');
    }
    return [
      for (final item in raw)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  Map<String, dynamic> _apiService(SingboxApiEndpoint endpoint) {
    return {
      'type': 'api',
      'tag': tag,
      'listen': endpoint.host,
      'listen_port': endpoint.port,
      'secret': endpoint.secret,
      'access_control_allow_origin': ['*'],
      'access_control_allow_private_network': true,
      if (endpoint.dashboardEnabled) 'dashboard': {'enabled': true},
    };
  }
}
