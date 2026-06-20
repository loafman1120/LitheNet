import 'dart:convert';
import 'dart:io';

import '../../../data/models/ip_info.dart';

class IpInfoService {
  IpInfoService._();

  static final IpInfoService instance = IpInfoService._();

  static const _endpoint = 'http://ip-api.com/json/?fields=query,country,countryCode,city,isp,org,as';

  Future<IpInfo> fetch() async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(_endpoint);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return IpInfo.fromJson(json);
    } finally {
      client.close();
    }
  }
}
