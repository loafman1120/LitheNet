import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_identity.dart';
import '../../app/app_providers.dart';
import '../../app/router.dart';
import '../../core/runtime/core_controller.dart';
import '../../core/runtime/core_models.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/ip_info.dart';
import 'data/ip_info_service.dart';
import 'presentation/widgets/connection_button.dart';
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
    final core = ref.watch(coreControllerProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                AppIdentity.displayName,
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
                CurrentProfileCard(core: core),
                if (core.message.isNotEmpty &&
                    (!core.available ||
                        core.lifecycle == CoreLifecycle.failed)) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  ConnectionErrorBanner(message: core.message),
                ],
                const SizedBox(height: AppSpacing.sectionGap),
                IpInfoCard(
                  ipInfo: _ipInfo,
                  loading: _ipLoading,
                  error: _ipError,
                  onRefresh: _fetchIpInfo,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Center(
                  child: ConnectionButton(
                    core: core,
                    onConnect: () => _connect(core),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                TrafficStatsCard(snapshot: core.traffic),
                const SizedBox(height: AppSpacing.sectionGap),
                QuickActionsGrid(
                  enabled: core.running && !core.busy,
                  onTestLatency: () => _testProxies(core),
                  onRefreshRuleSets: () => _refreshRuleSets(core),
                  onCloseConnections: () => _closeConnections(core),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connect(CoreController core) async {
    await core.start();
    if (!mounted || core.lifecycle != CoreLifecycle.failed) return;

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

  Future<void> _testProxies(CoreController core) async {
    final controller = ref.read(proxiesControllerProvider);
    await controller.testAllLatency();
    if (!mounted) return;
    _showMessage(
      controller.lastError ?? 'Proxy URLTest completed.',
      error: controller.lastError != null,
    );
  }

  Future<void> _refreshRuleSets(CoreController core) async {
    final count = await core.refreshRuleSets();
    if (!mounted) return;
    _showMessage(
      count == null
          ? core.message
          : count == 0
          ? 'No remote rule sets are configured.'
          : 'Requested refresh for $count rule set${count == 1 ? '' : 's'}.',
      error: count == null,
    );
  }

  Future<void> _closeConnections(CoreController core) async {
    final active = core.traffic.activeConnections;
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
    final count = await core.closeAllConnections();
    if (!mounted) return;
    _showMessage(
      count == null
          ? core.message
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
