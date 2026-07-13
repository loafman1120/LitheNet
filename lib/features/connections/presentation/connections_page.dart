import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/connections_controller.dart';
import 'widgets/connection_tile.dart';

class ConnectionsPage extends ConsumerWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(connectionsControllerProvider);
    final connections = controller.filteredConnections;

    return Scaffold(
      appBar: AppBar(title: Text('Connections (${controller.activeCount})')),
      body: Column(
        children: [
          _ConnectionsToolbar(
            searchQuery: controller.searchQuery,
            sortBy: controller.sortBy,
            sortAsc: controller.sortAsc,
            onSearchChanged: controller.setSearchQuery,
            onSortChanged: controller.setSortBy,
          ),
          Expanded(
            child:
                connections.isEmpty
                    ? const EmptyState(
                      icon: Icons.cable_outlined,
                      title: 'No connections',
                      description:
                          'Active connections will appear here when the proxy is running.',
                    )
                    : ListView.builder(
                      itemCount: connections.length,
                      itemBuilder: (context, index) {
                        return ConnectionTile(connection: connections[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsToolbar extends StatelessWidget {
  const _ConnectionsToolbar({
    required this.searchQuery,
    required this.sortBy,
    required this.sortAsc,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  final String searchQuery;
  final ConnectionSortBy sortBy;
  final bool sortAsc;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ConnectionSortBy> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search connections...',
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<ConnectionSortBy>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 20),
                const SizedBox(width: 2),
                Icon(
                  sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                ),
              ],
            ),
            tooltip: 'Sort by',
            onSelected: onSortChanged,
            itemBuilder:
                (context) => [
                  _sortItem(ConnectionSortBy.traffic, 'Traffic'),
                  _sortItem(ConnectionSortBy.destination, 'Destination'),
                  _sortItem(ConnectionSortBy.outbound, 'Outbound'),
                  _sortItem(ConnectionSortBy.network, 'Network'),
                ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<ConnectionSortBy> _sortItem(
    ConnectionSortBy value,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          if (sortBy == value)
            Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
        ],
      ),
    );
  }
}
