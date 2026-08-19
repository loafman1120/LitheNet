// Legacy node conversion helpers are retained only for reading old cached
// profiles; new subscriptions are accepted as complete sing-box JSON.
// ignore_for_file: unused_element

import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../../../data/models/proxy_node.dart';
import '../../../data/models/subscription.dart';
import 'subscription_errors.dart';
import 'subscription_fetcher.dart';

abstract class SubscriptionParser {
  Future<ParsedProfile> parse(FetchResult result, Subscription subscription);
}

class ParsedProfile {
  const ParsedProfile({
    required this.id,
    required this.subscriptionId,
    required this.title,
    required this.format,
    required this.rawHash,
    required this.nodeCount,
    required this.nodes,
    required this.groups,
    required this.rawText,
    required this.createdAt,
  });

  final String id;
  final String subscriptionId;
  final String title;
  final SubscriptionFormat format;
  final String rawHash;
  final int nodeCount;
  final List<ProxyNode> nodes;
  final List<String> groups;
  final String rawText;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subscriptionId': subscriptionId,
    'title': title,
    'format': format.name,
    'rawHash': rawHash,
    'nodeCount': nodeCount,
    'nodes': nodes.map((node) => node.toJson()).toList(),
    'groups': groups,
    'rawText': rawText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ParsedProfile.fromJson(Map<String, dynamic> json) {
    return ParsedProfile(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      title: json['title'] as String? ?? 'Subscription',
      format: SubscriptionFormat.values.byName(
        json['format'] as String? ?? SubscriptionFormat.unknown.name,
      ),
      rawHash: json['rawHash'] as String? ?? '',
      nodeCount: json['nodeCount'] as int? ?? 0,
      nodes: [
        for (final item in json['nodes'] as List? ?? const [])
          if (item is Map) ProxyNode.fromJson(Map<String, dynamic>.from(item)),
      ],
      groups: [
        for (final item in json['groups'] as List? ?? const [])
          if (item is String) item,
      ],
      rawText: json['rawText'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class AutoSubscriptionParser implements SubscriptionParser {
  const AutoSubscriptionParser();

  @override
  Future<ParsedProfile> parse(
    FetchResult result,
    Subscription subscription,
  ) async {
    final rawText = utf8.decode(result.bodyBytes, allowMalformed: true).trim();
    if (rawText.isEmpty) {
      throw const SubscriptionException(
        SubscriptionErrorCodes.parse,
        'Subscription body is empty.',
      );
    }

    final format = _detectFormat(rawText, subscription.formatHint);
    if (format == SubscriptionFormat.unknown) {
      throw const SubscriptionException(
        SubscriptionErrorCodes.format,
        'Subscription format is not recognized.',
      );
    }

    if (format != SubscriptionFormat.singBoxJson) {
      throw const SubscriptionException(
        SubscriptionErrorCodes.format,
        'Only complete sing-box JSON subscriptions are supported.',
      );
    }

    final now = DateTime.now();
    final nodes = const <ProxyNode>[];
    return ParsedProfile(
      id: 'profile_${now.microsecondsSinceEpoch}',
      subscriptionId: subscription.id,
      title: subscription.name,
      format: format,
      rawHash: _contentHash(rawText),
      nodeCount: nodes.length,
      nodes: nodes,
      groups: _groupsFor(nodes),
      rawText: rawText,
      createdAt: now,
    );
  }

  SubscriptionFormat _detectFormat(String text, SubscriptionFormat formatHint) {
    if (formatHint != SubscriptionFormat.auto) {
      return formatHint;
    }
    final lower = text.toLowerCase();
    if (lower.startsWith('{') &&
        (lower.contains('"inbounds"') || lower.contains('"outbounds"'))) {
      return SubscriptionFormat.singBoxJson;
    }
    if (lower.contains('proxies:') ||
        lower.contains('proxy-providers:') ||
        lower.contains('rules:')) {
      return SubscriptionFormat.clashYaml;
    }
    if (lower.contains('#!managed-config') ||
        lower.contains('[proxy]') ||
        lower.contains('[rule]')) {
      return SubscriptionFormat.surgeConf;
    }
    if (lower.contains('server_remote') ||
        lower.contains('filter_remote') ||
        lower.contains('rewrite_remote')) {
      return SubscriptionFormat.quantumultX;
    }
    if (_looksLikeBase64Subscription(text)) {
      return SubscriptionFormat.v2rayBase64;
    }
    return SubscriptionFormat.unknown;
  }

  bool _looksLikeBase64Subscription(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), '');
    if (compact.length < 16 || compact.length % 4 != 0) {
      return false;
    }
    try {
      final decoded = utf8.decode(base64.decode(compact), allowMalformed: true);
      return decoded.contains('vmess://') ||
          decoded.contains('vless://') ||
          decoded.contains('trojan://') ||
          decoded.contains('ss://');
    } catch (_) {
      return false;
    }
  }

  List<ProxyNode> _parseClashNodes(String text) {
    final document = loadYaml(text);
    if (document is! YamlMap || document['proxies'] is! YamlList) {
      return const [];
    }
    return _dedupe([
      for (final item in document['proxies'] as YamlList)
        if (item is YamlMap && item['name'] != null && item['type'] != null)
          _node(
            name: item['name'].toString(),
            type: item['type'].toString(),
            group: _inferGroup(item['name'].toString()),
            config: _plainMap(item),
          ),
    ]);
  }

  Map<String, dynamic> _plainMap(Map value) => {
    for (final entry in value.entries)
      entry.key.toString(): switch (entry.value) {
        Map nested => _plainMap(nested),
        List nested => [
          for (final item in nested) item is Map ? _plainMap(item) : item,
        ],
        final scalar => scalar,
      },
  };

  List<ProxyNode> _parseSingBoxNodes(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) {
        return const [];
      }
      final outbounds = decoded['outbounds'];
      if (outbounds is! List) {
        return const [];
      }
      return _dedupe([
        for (final item in outbounds)
          if (item is Map &&
              item['type'] != 'direct' &&
              item['type'] != 'block')
            _node(
              name: (item['tag'] as String?) ?? 'Proxy',
              type: (item['type'] as String?) ?? 'unknown',
              group: _inferGroup((item['tag'] as String?) ?? ''),
              config: Map<String, dynamic>.from(item),
            ),
      ]);
    } catch (_) {
      return const [];
    }
  }

  List<ProxyNode> _parseV2RayNodes(String text) {
    final body = _decodeV2RayBody(text);
    final links = RegExp(
      r'(vmess|vless|trojan|ss)://[^\s]+',
    ).allMatches(body).map((match) => match.group(0)!).toList();
    return _dedupe([for (final link in links) _parseProxyLink(link)]);
  }

  List<ProxyNode> _parseSurgeNodes(String text) {
    var inProxySection = false;
    final nodes = <ProxyNode>[];
    for (final line in const LineSplitter().convert(text)) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[')) {
        inProxySection = trimmed.toLowerCase() == '[proxy]';
        continue;
      }
      if (!inProxySection ||
          trimmed.isEmpty ||
          trimmed.startsWith('#') ||
          trimmed.startsWith(';')) {
        continue;
      }
      final index = trimmed.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = trimmed.substring(0, index).trim();
      final config = trimmed.substring(index + 1).trim();
      final type = config.split(',').first.trim();
      nodes.add(_node(name: name, type: type, group: _inferGroup(name)));
    }
    return _dedupe(nodes);
  }

  List<ProxyNode> _parseQuantumultXNodes(String text) {
    final nodes = <ProxyNode>[];
    for (final line in const LineSplitter().convert(text)) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('server=')) {
        continue;
      }
      final content = trimmed.substring('server='.length);
      final parts = content.split(',');
      if (parts.isEmpty) {
        continue;
      }
      final type = parts.first.trim();
      final tag = parts
          .map((part) => part.trim())
          .firstWhere(
            (part) => part.toLowerCase().startsWith('tag='),
            orElse: () => '',
          )
          .replaceFirst(RegExp(r'tag=', caseSensitive: false), '');
      final name = tag.isEmpty ? type : tag;
      nodes.add(_node(name: name, type: type, group: _inferGroup(name)));
    }
    return _dedupe(nodes);
  }

  ProxyNode _parseProxyLink(String link) {
    final uri = Uri.tryParse(link);
    final type = uri?.scheme ?? link.split('://').first;
    final fragment = uri?.fragment;
    final name = fragment == null || fragment.isEmpty
        ? '${type.toUpperCase()} Node'
        : Uri.decodeComponent(fragment);
    final normalizedType = type.toLowerCase();
    final query = uri?.queryParameters ?? const <String, String>{};
    final config = <String, dynamic>{
      if (uri != null && uri.host.isNotEmpty) 'server': uri.host,
      if (uri != null && uri.port > 0) 'port': uri.port,
    };
    final userInfo = uri == null ? '' : Uri.decodeComponent(uri.userInfo);
    final userParts = userInfo.split(':');
    switch (normalizedType) {
      case 'vless':
        if (userInfo.isNotEmpty) config['uuid'] = userParts.first;
        if (query['flow'] != null) config['flow'] = query['flow'];
        config['tls'] = _linkUsesTls(query);
        if (query['sni'] != null) config['sni'] = query['sni'];
        if (query['security']?.toLowerCase() == 'reality' &&
            query['pbk'] != null) {
          config['reality'] = {
            'public_key': query['pbk'],
            'short_id': query['sid'] ?? '',
          };
          if (query['fp'] != null) config['fingerprint'] = query['fp'];
        }
      case 'trojan':
        if (userInfo.isNotEmpty) config['password'] = userParts.first;
        config['tls'] = true;
        if (query['sni'] != null) config['sni'] = query['sni'];
      case 'ss':
        if (userInfo.isNotEmpty) {
          final credentials = userInfo.split(':');
          if (credentials.length > 1) {
            config['cipher'] = credentials.first;
            config['password'] = credentials.sublist(1).join(':');
          }
        }
    }
    final transport = query['type']?.toLowerCase();
    if (transport == 'ws' || transport == 'websocket') {
      final transportHost = query['host'] ?? query['peer'] ?? query['sni'];
      final transportConfig = <String, dynamic>{
        'type': 'web-socket',
        'path': query['path'] ?? '/',
      };
      if (transportHost != null) transportConfig['host'] = transportHost;
      config['transport'] = transportConfig;
    }
    return _node(
      name: name,
      type: type,
      group: _inferGroup(name),
      config: config.isEmpty ? null : config,
    );
  }

  bool _linkUsesTls(Map<String, String> query) {
    final security = query['security']?.toLowerCase();
    return security == 'tls' || security == 'reality';
  }

  String _decodeV2RayBody(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), '');
    try {
      return utf8.decode(base64.decode(compact), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  ProxyNode _node({
    required String name,
    required String type,
    String? group,
    Map<String, dynamic>? config,
  }) {
    final normalizedName = name.trim();
    final normalizedType = type.trim().toLowerCase();
    return ProxyNode(
      id: _nodeId('$normalizedType-$normalizedName'),
      name: normalizedName,
      type: normalizedType,
      countryCode: _inferCountryCode(normalizedName),
      metadata: {'group': ?group, 'config': ?config},
    );
  }

  List<ProxyNode> _dedupe(List<ProxyNode> nodes) {
    final seen = <String>{};
    final result = <ProxyNode>[];
    for (final node in nodes) {
      if (seen.add(node.id)) {
        result.add(node);
      }
    }
    return result;
  }

  List<String> _groupsFor(List<ProxyNode> nodes) {
    return {
      for (final node in nodes)
        if (node.metadata['group'] is String) node.metadata['group'] as String,
    }.toList();
  }

  String? _inferGroup(String name) {
    final code = _inferCountryCode(name);
    if (code != null) {
      return code;
    }
    return null;
  }

  String? _inferCountryCode(String name) {
    final upper = name.toUpperCase();
    const patterns = {
      'HK': ['HK', 'HONG KONG', '香港'],
      'JP': ['JP', 'JAPAN', 'TOKYO', '日本', '东京'],
      'SG': ['SG', 'SINGAPORE', '新加坡'],
      'US': ['US', 'USA', 'UNITED STATES', 'AMERICA', '美国'],
      'TW': ['TW', 'TAIWAN', '台湾'],
      'KR': ['KR', 'KOREA', '韩国'],
      'DE': ['DE', 'GERMANY', '德国'],
    };
    for (final entry in patterns.entries) {
      if (entry.value.any(upper.contains)) {
        return entry.key;
      }
    }
    return null;
  }

  String _nodeId(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return 'node-${_contentHash(value)}';
  }

  String _contentHash(String text) {
    var hash = 0xcbf29ce484222325;
    for (final unit in utf8.encode(text)) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
