import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../repositories/proxy_repository.dart';
import '../application/connections_controller.dart';
import 'widgets/connection_tile.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  late final ConnectionsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConnectionsController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.bind(ProxyRepositoryScope.of(context));
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
        final connections = _controller.filteredConnections;

        return Scaffold(
          appBar: AppBar(
            title: Text('Connections (${_controller.activeCount})'),
          ),
          body: Column(
            children: [
              _ConnectionsToolbar(
                searchQuery: _controller.searchQuery,
                sortBy: _controller.sortBy,
                sortAsc: _controller.sortAsc,
                onSearchChanged: _controller.setSearchQuery,
                onSortChanged: _controller.setSortBy,
              ),
              Expanded(
                child: connections.isEmpty
                    ? const EmptyState(
                        icon: Icons.cable_outlined,
                        title: 'No connections',
                        description:
                            'Active connections will appear here when the proxy is running.',
                      )
                    : ListView.builder(
                        itemCount: connections.length,
                        itemBuilder: (context, index) {
                          return ConnectionTile(
                            connection: connections[index],
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
            itemBuilder: (context) => [
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
            Icon(
              sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
            ),
        ],
      ),
    );
  }
}
