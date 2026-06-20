import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format_bytes.dart';
import '../../data/models/ip_info.dart';
import '../../repositories/proxy_repository.dart';
import 'data/ip_info_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProxyRepository? _repository;
  IpInfo? _ipInfo;
  bool _ipLoading = false;
  String? _ipError;

  @override
  void initState() {
    super.initState();
    _fetchIpInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ProxyRepositoryScope.of(context);
    if (_repository == next) return;
    _repository?.removeListener(_onStateChanged);
    _repository = next..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _repository?.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchIpInfo() async {
    setState(() {
      _ipLoading = true;
      _ipError = null;
    });
    try {
      final info = await IpInfoService.instance.fetch();
      if (mounted) setState(() => _ipInfo = info);
    } catch (e) {
      if (mounted) setState(() => _ipError = e.toString());
    } finally {
      if (mounted) setState(() => _ipLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProxyRepositoryScope.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'LitheNet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                CurrentProfileCard(repository: repo),
                const SizedBox(height: AppSpacing.sectionGap),
                IpInfoCard(
                  ipInfo: _ipInfo,
                  loading: _ipLoading,
                  error: _ipError,
                  onRefresh: _fetchIpInfo,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Center(child: ConnectionButton(repository: repo)),
                const SizedBox(height: AppSpacing.sectionGap),
                TrafficStatsCard(snapshot: repo.traffic),
                const SizedBox(height: AppSpacing.sectionGap),
                QuickActionsGrid(repository: repo),
                if (repo.message.isNotEmpty &&
                    !repo.running &&
                    repo.status == 'Stopped') ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  ConnectionErrorBanner(message: repo.message),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentProfileCard extends StatelessWidget {
  const CurrentProfileCard({required this.repository, super.key});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: repository.running
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    repository.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: repository.running
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.itemGap),
            _InfoRow(
              icon: Icons.speed,
              label: 'Port',
              value: '${repository.mixedPort}',
            ),
            const SizedBox(height: AppSpacing.smallGap),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'Listen',
              value: repository.listenAddress,
            ),
          ],
        ),
      ),
    );
  }
}

class IpInfoCard extends StatelessWidget {
  const IpInfoCard({
    required this.ipInfo,
    required this.loading,
    required this.error,
    required this.onRefresh,
    super.key,
  });

  final IpInfo? ipInfo;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.public,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IP Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: loading ? null : onRefresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.itemGap),
            if (loading && ipInfo == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (error != null && ipInfo == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load IP info',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (ipInfo != null) ...[
              _InfoRow(
                icon: Icons.language,
                label: 'IP',
                value: ipInfo!.ip,
              ),
              const SizedBox(height: AppSpacing.smallGap),
              _InfoRow(
                icon: Icons.flag_outlined,
                label: 'Country',
                value: '${ipInfo!.flagEmoji} ${ipInfo!.country}',
              ),
              const SizedBox(height: AppSpacing.smallGap),
              _InfoRow(
                icon: Icons.location_city_outlined,
                label: 'City',
                value: ipInfo!.city,
              ),
              const SizedBox(height: AppSpacing.smallGap),
              _InfoRow(
                icon: Icons.business_outlined,
                label: 'ISP',
                value: ipInfo!.isp,
              ),
              const SizedBox(height: AppSpacing.smallGap),
              _InfoRow(
                icon: Icons.dns_outlined,
                label: 'AS',
                value: ipInfo!.asName,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({required this.repository, super.key});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = repository.running;
    final busy = repository.busy;

    return SizedBox(
      width: 200,
      height: 200,
      child: FilledButton(
        onPressed: busy
            ? null
            : running
                ? repository.stop
                : repository.start,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              running ? theme.colorScheme.error : theme.colorScheme.primary,
          disabledBackgroundColor:
              theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                running ? Icons.stop : Icons.power_settings_new,
                size: 48,
                color: busy ? theme.colorScheme.onSurfaceVariant : Colors.white,
              ),
            const SizedBox(height: 8),
            Text(
              busy
                  ? 'Please wait'
                  : running
                      ? 'Disconnect'
                      : 'Connect',
              style: theme.textTheme.titleMedium?.copyWith(
                color: busy ? theme.colorScheme.onSurfaceVariant : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrafficStatsCard extends StatelessWidget {
  const TrafficStatsCard({required this.snapshot, super.key});

  final dynamic snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.arrow_upward,
                label: 'Upload',
                value: formatSpeed(snapshot.uploadBytes),
                color: const Color(0xff7c3aed),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: _StatItem(
                icon: Icons.arrow_downward,
                label: 'Download',
                value: formatSpeed(snapshot.downloadBytes),
                color: const Color(0xff2563eb),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({required this.repository, super.key});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.speed,
                    label: 'Test Latency',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.smallGap),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.hub,
                    label: 'Change Node',
                    onTap: () => context.go(AppRoute.proxies.path),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smallGap),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.sync,
                    label: 'Update Sub',
                    onTap: () => context.go(AppRoute.subscriptions.path),
                  ),
                ),
                const SizedBox(width: AppSpacing.smallGap),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'View Logs',
                    onTap: () => context.go(AppRoute.logs.path),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionErrorBanner extends StatelessWidget {
  const ConnectionErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.error_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
        title: Text(
          'Connection Error',
          style: TextStyle(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onErrorContainer,
        ),
        onTap: () => context.go(AppRoute.logs.path),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
