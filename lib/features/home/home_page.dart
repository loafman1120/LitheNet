import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_identity.dart';
import '../../app/app_providers.dart';
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
                const SizedBox(height: AppSpacing.sectionGap),
                IpInfoCard(
                  ipInfo: _ipInfo,
                  loading: _ipLoading,
                  error: _ipError,
                  onRefresh: _fetchIpInfo,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Center(child: ConnectionButton(core: core)),
                const SizedBox(height: AppSpacing.sectionGap),
                TrafficStatsCard(snapshot: core.traffic),
                const SizedBox(height: AppSpacing.sectionGap),
                const QuickActionsGrid(),
                if (core.message.isNotEmpty && !core.available) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  ConnectionErrorBanner(message: core.message),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
