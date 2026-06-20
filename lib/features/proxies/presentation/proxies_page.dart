import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/proxies_controller.dart';
import '../application/proxy_catalog.dart';
import 'widgets/mode_selector.dart';
import 'widgets/proxy_group_tabs.dart';
import 'widgets/proxy_node_detail_sheet.dart';
import 'widgets/proxy_node_tile.dart';

class ProxiesPage extends StatefulWidget {
  const ProxiesPage({super.key});

  @override
  State<ProxiesPage> createState() => _ProxiesPageState();
}

class _ProxiesPageState extends State<ProxiesPage> {
  late final ProxiesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProxiesController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.bind(ProxyCatalogScope.of(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final nodes = _controller.filteredNodes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Proxies'),
            actions: [
              IconButton(
                onPressed: _showSearch,
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: _controller.toggleSortOrder,
                icon: Icon(
                  _controller.sortAsc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ModeSelector(
                  mode: _controller.mode,
                  onChanged: _controller.setMode,
                ),
              ),
              ProxyGroupTabs(
                groups: _controller.groups,
                selectedIndex: _controller.selectedGroupIndex,
                onSelected: _controller.selectGroup,
              ),
              const SizedBox(height: AppSpacing.smallGap),
              Expanded(
                child: nodes.isEmpty
                    ? const EmptyState(
                        icon: Icons.hub_outlined,
                        title: 'No nodes available',
                        description: 'Add a subscription to get proxy nodes.',
                      )
                    : ListView.builder(
                        itemCount: nodes.length,
                        itemBuilder: (context, index) {
                          final node = nodes[index];
                          return ProxyNodeTile(
                            node: node,
                            onTap: () => _controller.selectNode(node.id),
                            onLongPress: () => _showDetail(node),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _controller.testing ? null : _controller.testAllLatency,
            child: _controller.testing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.speed),
          ),
        );
      },
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search nodes'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Name, type, or region...',
          ),
          onChanged: _controller.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.setSearchQuery('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showDetail(dynamic node) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ProxyNodeDetailSheet(node: node),
    );
  }
}
