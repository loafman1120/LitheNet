import 'package:flutter/material.dart';

import '../../app/app_identity.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/ip_info.dart';
import '../../repositories/proxy_repository.dart';
import 'data/ip_info_service.dart';
import 'presentation/widgets/connection_button.dart';
import 'presentation/widgets/connection_error_banner.dart';
import 'presentation/widgets/current_profile_card.dart';
import 'presentation/widgets/ip_info_card.dart';
import 'presentation/widgets/quick_actions_grid.dart';
import 'presentation/widgets/traffic_stats_card.dart';

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
                const QuickActionsGrid(),
                if (repo.message.isNotEmpty &&
                    !repo.running &&
                    repo.status == 'Stopped') ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  ConnectionErrorBanner(
                    message: repo.message,
                    onElevate: repo.canRequestTunElevation
                        ? repo.requestTunElevation
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
