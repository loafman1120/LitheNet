import 'package:flutter/widgets.dart';

import '../../../data/singbox_api/singbox_api_models.dart';
import '../../../repositories/proxy_repository.dart';

enum ConnectionSortBy { destination, outbound, network, traffic }

class ConnectionsController extends ChangeNotifier {
  ProxyRepository? _repository;
  String _searchQuery = '';
  ConnectionSortBy _sortBy = ConnectionSortBy.traffic;
  bool _sortAsc = false;

  String get searchQuery => _searchQuery;
  ConnectionSortBy get sortBy => _sortBy;
  bool get sortAsc => _sortAsc;

  List<SingboxApiConnection> get filteredConnections {
    var list = _repository?.connections ?? [];

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.destination.toLowerCase().contains(q) ||
              c.outbound.toLowerCase().contains(q) ||
              c.network.toLowerCase().contains(q) ||
              c.protocol.toLowerCase().contains(q) ||
              c.domain.toLowerCase().contains(q))
          .toList();
    }

    list = List.of(list)..sort(_compare);

    return list;
  }

  int get activeCount => _repository?.connections.length ?? 0;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(ConnectionSortBy sortBy) {
    if (_sortBy == sortBy) {
      _sortAsc = !_sortAsc;
    } else {
      _sortBy = sortBy;
      _sortAsc = false;
    }
    notifyListeners();
  }

  void bind(ProxyRepository repository) {
    if (_repository == repository) return;
    _repository?.removeListener(_syncFromRepository);
    _repository = repository..addListener(_syncFromRepository);
    _syncFromRepository();
  }

  @override
  void dispose() {
    _repository?.removeListener(_syncFromRepository);
    super.dispose();
  }

  void _syncFromRepository() {
    notifyListeners();
  }

  int _compare(SingboxApiConnection a, SingboxApiConnection b) {
    final result = switch (_sortBy) {
      ConnectionSortBy.destination => a.destination.compareTo(b.destination),
      ConnectionSortBy.outbound => a.outbound.compareTo(b.outbound),
      ConnectionSortBy.network => a.network.compareTo(b.network),
      ConnectionSortBy.traffic => (a.uplinkTotal + a.downlinkTotal)
          .compareTo(b.uplinkTotal + b.downlinkTotal),
    };
    return _sortAsc ? result : -result;
  }
}
