import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../repositories/proxy_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _listenController;
  late final TextEditingController _portController;
  late final TextEditingController _configController;
  ProxyRepository? _repository;

  @override
  void initState() {
    super.initState();
    _listenController = TextEditingController();
    _portController = TextEditingController();
    _configController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRepository = ProxyRepositoryScope.of(context);
    if (_repository == nextRepository) {
      return;
    }
    _repository?.removeListener(_syncControllers);
    _repository = nextRepository..addListener(_syncControllers);
    _syncControllers();
  }

  @override
  void dispose() {
    _repository?.removeListener(_syncControllers);
    _listenController.dispose();
    _portController.dispose();
    _configController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ProxyRepositoryScope.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader(repository: repository)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.crossAxisExtent >= 980;
                    if (wide) {
                      return SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _buildLeftColumn(repository),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRightColumn(repository)),
                          ],
                        ),
                      );
                    }

                    return SliverList.list(
                      children: [
                        _buildLeftColumn(repository),
                        const SizedBox(height: 16),
                        _buildRightColumn(repository),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftColumn(ProxyRepository repository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CurrentConfigCard(
          repository: repository,
          listenController: _listenController,
          portController: _portController,
        ),
        const SizedBox(height: 16),
        ConnectionCard(repository: repository),
        const SizedBox(height: 16),
        TrafficStatsCard(snapshot: repository.traffic),
      ],
    );
  }

  Widget _buildRightColumn(ProxyRepository repository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuickActionsCard(
          repository: repository,
          onOpenLogs: () => context.go(AppRoute.logs.path),
        ),
        const SizedBox(height: 16),
        ConfigEditorCard(
          controller: _configController,
          enabled: !repository.busy,
          onChanged: repository.updateConfig,
        ),
      ],
    );
  }

  void _syncControllers() {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _setTextIfNeeded(_listenController, repository.listenAddress);
    _setTextIfNeeded(_portController, repository.mixedPort.toString());
    _setTextIfNeeded(_configController, repository.configJson);
  }

  void _setTextIfNeeded(TextEditingController controller, String text) {
    if (controller.text == text) {
      return;
    }
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.repository});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LitheNet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  repository.versionLine,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          StatusChip(repository: repository),
        ],
      ),
    );
  }
}

class CurrentConfigCard extends StatelessWidget {
  const CurrentConfigCard({
    required this.repository,
    required this.listenController,
    required this.portController,
    super.key,
  });

  final ProxyRepository repository;
  final TextEditingController listenController;
  final TextEditingController portController;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Current Config',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoRow(
            label: 'Core',
            value: repository.coreLoaded ? 'Loaded' : 'Bundled plugin',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Mode',
            value: 'Mixed proxy -> direct outbound',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: listenController,
            enabled: !repository.running && !repository.busy,
            decoration: const InputDecoration(labelText: 'Listen address'),
            onSubmitted: (_) => _updateEndpoint(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: portController,
            enabled: !repository.running && !repository.busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Mixed port'),
            onSubmitted: (_) => _updateEndpoint(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed:
                repository.running || repository.busy ? null : _updateEndpoint,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Apply Endpoint'),
          ),
        ],
      ),
    );
  }

  void _updateEndpoint() {
    repository.updateEndpoint(
      listenAddress: listenController.text,
      mixedPort: int.tryParse(portController.text.trim()) ?? 2080,
    );
  }
}

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    required this.repository,
    super.key,
  });

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Connection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: repository.busy
                ? null
                : repository.running
                    ? repository.stop
                    : repository.start,
            icon: Icon(repository.running ? Icons.stop : Icons.play_arrow),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(repository.running ? 'Disconnect' : 'Connect'),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            repository.message,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class TrafficStatsCard extends StatelessWidget {
  const TrafficStatsCard({
    required this.snapshot,
    super.key,
  });

  final TrafficSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Traffic Stats',
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Upload',
              value: _formatBytes(snapshot.uploadBytes),
              icon: Icons.upload,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              label: 'Download',
              value: _formatBytes(snapshot.downloadBytes),
              icon: Icons.download,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              label: 'Active',
              value: snapshot.activeConnections.toString(),
              icon: Icons.hub_outlined,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    required this.repository,
    required this.onOpenLogs,
    super.key,
  });

  final ProxyRepository repository;
  final VoidCallback onOpenLogs;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quick Actions',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ActionButton(
            icon: Icons.memory,
            label: 'Load Core',
            onPressed:
                repository.busy || repository.running || repository.coreLoaded
                    ? null
                    : repository.loadCore,
          ),
          _ActionButton(
            icon: Icons.fact_check_outlined,
            label: 'Validate',
            onPressed: repository.busy ? null : repository.validateConfig,
          ),
          _ActionButton(
            icon: Icons.refresh,
            label: 'Direct Config',
            onPressed: repository.busy || repository.running
                ? null
                : repository.resetDirectConfig,
          ),
          _ActionButton(
            icon: Icons.sync,
            label: 'Reload',
            onPressed: repository.busy || !repository.running
                ? null
                : repository.reload,
          ),
          _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'View Logs',
            onPressed: onOpenLogs,
          ),
        ],
      ),
    );
  }
}

class ConfigEditorCard extends StatelessWidget {
  const ConfigEditorCard({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'sing-box Config',
      child: SizedBox(
        height: 420,
        child: TextField(
          controller: controller,
          enabled: enabled,
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(
            fontFamily: 'Consolas',
            fontSize: 13,
            height: 1.35,
          ),
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            labelText: 'JSON',
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.repository,
    super.key,
  });

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        repository.running ? Colors.green.shade700 : Colors.grey.shade700;

    return Chip(
      avatar: Icon(
        repository.running
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: statusColor,
        size: 18,
      ),
      label: Text(repository.status),
      side: BorderSide(color: statusColor.withValues(alpha: 0.35)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
