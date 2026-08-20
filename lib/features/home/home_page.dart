import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/runtime/core_notifier.dart';
import '../../core/runtime/core_models.dart';
import '../../data/models/ip_info.dart';
import '../../core/widgets/target_page_layout.dart';
import '../proxies/application/proxies_notifier.dart';
import 'data/ip_info_service.dart';
import 'presentation/widgets/connection_error_banner.dart';
import 'presentation/widgets/current_profile_card.dart';
import 'presentation/widgets/ip_info_card.dart';
import 'presentation/widgets/quick_actions_grid.dart';
import 'presentation/widgets/traffic_stats_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  IpInfo? _ipInfo;
  bool _ipLoading = false;
  String? _ipError;

  @override
  void initState() {
    super.initState();
    _fetchIpInfo();
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
    final core = ref.watch(coreProvider);
    final theme = Theme.of(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TargetPageHeader(
                      title: 'Dashboard',
                      subtitle:
                          'Monitor your local network service and runtime health.',
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  core.running
                                      ? Icons.check_circle
                                      : Icons.circle,
                                  size: 18,
                                  color: core.running
                                      ? Colors.green
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  core.status,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: core.running
                                        ? Colors.green
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              core.running
                                  ? 'Service is running'
                                  : 'Service is stopped',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              core.available
                                  ? (core.running
                                        ? 'Traffic is being routed through the active profile.'
                                        : 'Start the service to begin routing traffic.')
                                  : 'The local core is unavailable on this platform.',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: core.busy || !core.available
                                  ? null
                                  : () => core.running
                                        ? ref
                                              .read(coreProvider.notifier)
                                              .stop()
                                        : _connect(),
                              child: Text(
                                core.busy
                                    ? 'Working…'
                                    : core.running
                                    ? 'Stop'
                                    : 'Start',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (core.message.isNotEmpty &&
                        (!core.available ||
                            core.lifecycle == CoreLifecycle.failed)) ...[
                      const SizedBox(height: 16),
                      ConnectionErrorBanner(message: core.message),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: wide ? 472 : double.infinity,
                          child: CurrentProfileCard(core: core),
                        ),
                        SizedBox(
                          width: wide ? 472 : double.infinity,
                          child: IpInfoCard(
                            ipInfo: _ipInfo,
                            loading: _ipLoading,
                            error: _ipError,
                            onRefresh: _fetchIpInfo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TrafficStatsCard(snapshot: core.traffic),
                    const SizedBox(height: 18),
                    QuickActionsGrid(
                      enabled: core.running && !core.busy,
                      onTestLatency: _testProxies,
                      onRefreshRuleSets: _refreshRuleSets,
                      onCloseConnections: _closeConnections,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _connect() async {
    final notifier = ref.read(coreProvider.notifier);
    await notifier.start();
    if (!mounted) return;

    final core = ref.read(coreProvider);
    if (core.lifecycle != CoreLifecycle.failed) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          content: Text(core.message),
          action: SnackBarAction(
            label: 'View logs',
            onPressed: () {
              if (mounted) context.go(AppRoute.logs.path);
            },
          ),
        ),
      );
  }

  Future<void> _testProxies() async {
    final notifier = ref.read(proxiesProvider.notifier);
    await notifier.testAllLatency();
    if (!mounted) return;
    final error = ref.read(proxiesProvider).lastError;
    _showMessage(error ?? 'Proxy URLTest completed.', error: error != null);
  }

  Future<void> _refreshRuleSets() async {
    final count = await ref.read(coreProvider.notifier).refreshRuleSets();
    if (!mounted) return;
    final message = ref.read(coreProvider).message;
    _showMessage(
      count == null
          ? message
          : count == 0
          ? 'No remote rule sets are configured.'
          : 'Requested refresh for $count rule set${count == 1 ? '' : 's'}.',
      error: count == null,
    );
  }

  Future<void> _closeConnections() async {
    final active = ref.read(coreProvider).traffic.activeConnections;
    if (active == 0) {
      _showMessage('There are no active connections.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close all connections?'),
        content: Text(
          '$active active connection${active == 1 ? '' : 's'} will be interrupted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Close all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final count = await ref.read(coreProvider.notifier).closeAllConnections();
    if (!mounted) return;
    final message = ref.read(coreProvider).message;
    _showMessage(
      count == null
          ? message
          : 'Closed $count active connection${count == 1 ? '' : 's'}.',
      error: count == null,
    );
  }

  void _showMessage(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }
}
