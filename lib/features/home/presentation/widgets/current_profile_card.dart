import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/app_settings.dart';
import '../../../../repositories/proxy_repository.dart';
import 'home_info_row.dart';

class CurrentProfileCard extends StatelessWidget {
  const CurrentProfileCard({required this.repository, super.key});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTun = repository.proxyMode == ProxyMode.tun;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rss_feed,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repository.running ? 'Connected' : 'No active profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusPill(repository: repository),
              ],
            ),
            const SizedBox(height: AppSpacing.itemGap),
            HomeInfoRow(
              icon: isTun ? Icons.alt_route : Icons.speed,
              label: 'Mode',
              value: repository.proxyMode.label,
            ),
            const SizedBox(height: AppSpacing.smallGap),
            HomeInfoRow(
              icon: isTun
                  ? Icons.admin_panel_settings_outlined
                  : Icons.place_outlined,
              label: isTun ? 'Privilege' : 'Listen',
              value: isTun
                  ? 'Elevate on demand'
                  : '${repository.listenAddress}:${repository.mixedPort}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.repository});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = repository.running;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: running
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        repository.status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: running ? Colors.green.shade700 : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
