import 'package:flutter/widgets.dart';

import '../../../core/runtime/core_controller.dart';
import '../../../core/runtime/core_models.dart';

enum ConnectionSortBy { destination, outbound, network, traffic }

class ConnectionsController extends ChangeNotifier {
  CoreController? _core;
  String _searchQuery = '';
  ConnectionSortBy _sortBy = ConnectionSortBy.traffic;
  bool _sortAsc = false;
  final Set<String> _closing = {};
  bool _closingAll = false;
  String? _lastError;

  String get searchQuery => _searchQuery;
  ConnectionSortBy get sortBy => _sortBy;
  bool get sortAsc => _sortAsc;
  bool get closingAll => _closingAll;
  String? get lastError => _lastError;
  bool isClosing(String id) => _closing.contains(id);

  List<CoreConnection> get filteredConnections {
    var list = _core?.connections ?? [];

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (c) =>
                c.destination.toLowerCase().contains(q) ||
                c.outbound.toLowerCase().contains(q) ||
                c.network.toLowerCase().contains(q) ||
                c.protocol.toLowerCase().contains(q) ||
                c.domain.toLowerCase().contains(q),
          )
          .toList();
    }

    list = List.of(list)..sort(_compare);

    return list;
  }

  int get activeCount => _core?.connections.length ?? 0;

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

  void bind(CoreController core) {
    if (_core == core) return;
    _core?.removeListener(_syncFromCore);
    _core = core..addListener(_syncFromCore);
    _syncFromCore();
  }

  Future<bool> close(String connectionId) async {
    final core = _core;
    if (core == null || _closing.contains(connectionId)) return false;
    _lastError = null;
    _closing.add(connectionId);
    notifyListeners();
    try {
      final closed = await core.closeConnection(connectionId);
      if (!closed) _lastError = core.message;
      return closed;
    } finally {
      _closing.remove(connectionId);
      notifyListeners();
    }
  }

  Future<int?> closeAll() async {
    final core = _core;
    if (core == null || _closingAll) return null;
    _lastError = null;
    _closingAll = true;
    notifyListeners();
    try {
      final count = await core.closeAllConnections();
      if (count == null) _lastError = core.message;
      return count;
    } finally {
      _closingAll = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _core?.removeListener(_syncFromCore);
    super.dispose();
  }

  void _syncFromCore() {
    notifyListeners();
  }

  int _compare(CoreConnection a, CoreConnection b) {
    final result = switch (_sortBy) {
      ConnectionSortBy.destination => a.destination.compareTo(b.destination),
      ConnectionSortBy.outbound => a.outbound.compareTo(b.outbound),
      ConnectionSortBy.network => a.network.compareTo(b.network),
      ConnectionSortBy.traffic => (a.uplinkTotal + a.downlinkTotal).compareTo(
        b.uplinkTotal + b.downlinkTotal,
      ),
    };
    return _sortAsc ? result : -result;
  }
}
