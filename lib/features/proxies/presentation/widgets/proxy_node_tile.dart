import 'package:flutter/material.dart';

import '../../../../data/models/proxy_node.dart';
import 'proxy_latency_chip.dart';

class ProxyNodeTile extends StatelessWidget {
  const ProxyNodeTile({
    required this.node,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final ProxyNode node;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _CountryFlag(countryCode: node.countryCode, type: node.type),
      title: Text(
        node.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${node.typeLabel}${node.countryCode != null ? ' · ${node.countryCode}' : ''}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProxyLatencyChip(latencyMs: node.latencyMs),
          if (node.isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({this.countryCode, required this.type});

  final String? countryCode;
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = countryCode;

    if (code != null && code.length == 2) {
      return Text(
        _flagEmoji(code),
        style: const TextStyle(fontSize: 24),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _typeIcon(type),
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _flagEmoji(String countryCode) {
    final upper = countryCode.toUpperCase();
    final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  IconData _typeIcon(String type) {
    return switch (type.toLowerCase()) {
      'ss' || 'ssr' || 'shadowsocks' => Icons.shield_outlined,
      'vmess' || 'vless' => Icons.cloud_outlined,
      'trojan' => Icons.security_outlined,
      'direct' => Icons.arrow_forward_outlined,
      _ => Icons.dns_outlined,
    };
  }
}
