import 'package:flutter/widgets.dart';

import '../../../data/models/proxy_group.dart';
import '../../../data/models/proxy_node.dart';
import 'proxy_catalog.dart';

enum ProxyMode { rule, global, direct }

class ProxiesController extends ChangeNotifier {
  ProxiesController({ProxyCatalog? catalog}) {
    if (catalog != null) {
      bind(catalog);
    }
  }

  ProxyCatalog? _catalog;
  ProxyMode _mode = ProxyMode.rule;
  List<ProxyGroup> _groups = [];
  int _selectedGroupIndex = 0;
  String _searchQuery = '';
  bool _sortAsc = true;
  bool _testing = false;

  ProxyMode get mode => _mode;
  List<ProxyGroup> get groups => List.unmodifiable(_groups);
  int get selectedGroupIndex => _selectedGroupIndex;
  String get searchQuery => _searchQuery;
  bool get sortAsc => _sortAsc;
  bool get testing => _testing;

  ProxyGroup? get selectedGroup =>
      _groups.isEmpty ? null : _groups[_selectedGroupIndex];

  void bind(ProxyCatalog catalog) {
    if (_catalog == catalog) {
      return;
    }
    _catalog?.removeListener(_syncFromCatalog);
    _catalog = catalog..addListener(_syncFromCatalog);
    _syncFromCatalog();
  }

  List<ProxyNode> get filteredNodes {
    final group = selectedGroup;
    if (group == null) return [];

    var nodes = group.nodes.where((n) => n.isAvailable).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      nodes = nodes
          .where((n) =>
              n.name.toLowerCase().contains(q) ||
              n.type.toLowerCase().contains(q) ||
              (n.countryCode?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    nodes.sort((a, b) {
      final la = a.latencyMs ?? 99999;
      final lb = b.latencyMs ?? 99999;
      return _sortAsc ? la.compareTo(lb) : lb.compareTo(la);
    });

    return nodes;
  }

  void setMode(ProxyMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void selectGroup(int index) {
    if (index >= 0 && index < _groups.length) {
      _selectedGroupIndex = index;
      notifyListeners();
    }
  }

  void selectNode(String nodeId) {
    if (_groups.isEmpty) return;
    final group = _groups[_selectedGroupIndex];
    _catalog?.selectNode(group.id, nodeId);
    _groups[_selectedGroupIndex] = group.copyWith(
      selectedNodeId: nodeId,
      nodes: [
        for (final node in group.nodes)
          node.copyWith(isSelected: node.id == nodeId),
      ],
    );
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAsc = !_sortAsc;
    notifyListeners();
  }

  Future<void> testAllLatency() async {
    _testing = true;
    notifyListeners();

    for (var gi = 0; gi < _groups.length; gi++) {
      final group = _groups[gi];
      final updatedNodes = <ProxyNode>[];
      for (final node in group.nodes) {
        await Future.delayed(const Duration(milliseconds: 50));
        final latency = 50 + (node.name.hashCode % 450);
        updatedNodes.add(node.copyWith(latencyMs: latency));
      }
      _groups[gi] = group.copyWith(nodes: updatedNodes);
    }

    _testing = false;
    notifyListeners();
  }

  Future<void> testSingleLatency(String nodeId) async {
    for (var gi = 0; gi < _groups.length; gi++) {
      final group = _groups[gi];
      final idx = group.nodes.indexWhere((n) => n.id == nodeId);
      if (idx < 0) continue;

      final node = group.nodes[idx];
      await Future.delayed(const Duration(milliseconds: 100));
      final latency = 50 + (node.name.hashCode % 450);
      final updated = List<ProxyNode>.from(group.nodes);
      updated[idx] = node.copyWith(latencyMs: latency);
      _groups[gi] = group.copyWith(nodes: updated);
      notifyListeners();
      return;
    }
  }

  @override
  void dispose() {
    _catalog?.removeListener(_syncFromCatalog);
    super.dispose();
  }

  void _syncFromCatalog() {
    final catalog = _catalog;
    if (catalog == null) {
      return;
    }
    final selectedGroupId = selectedGroup?.id;
    _groups = catalog.groups;
    final index = _groups.indexWhere((group) => group.id == selectedGroupId);
    _selectedGroupIndex = index >= 0 ? index : 0;
    if (_selectedGroupIndex >= _groups.length) {
      _selectedGroupIndex = 0;
    }
    notifyListeners();
  }

  void loadDemoGroups() {
    _groups = [
      ProxyGroup(
        id: 'auto',
        name: 'Auto',
        type: 'url-test',
        nodes: [
          const ProxyNode(
            id: 'n1',
            name: 'Hong Kong 01',
            type: 'ss',
            countryCode: 'HK',
            latencyMs: 45,
          ),
          const ProxyNode(
            id: 'n2',
            name: 'Tokyo 01',
            type: 'vmess',
            countryCode: 'JP',
            latencyMs: 89,
          ),
          const ProxyNode(
            id: 'n3',
            name: 'Singapore 01',
            type: 'trojan',
            countryCode: 'SG',
            latencyMs: 120,
          ),
          const ProxyNode(
            id: 'n4',
            name: 'US West 01',
            type: 'ss',
            countryCode: 'US',
            latencyMs: 200,
          ),
          const ProxyNode(
            id: 'n5',
            name: 'Germany 01',
            type: 'vmess',
            countryCode: 'DE',
            latencyMs: 280,
          ),
        ],
      ),
      ProxyGroup(
        id: 'proxy',
        name: 'Proxy',
        type: 'select',
        selectedNodeId: 'n1',
        nodes: [
          const ProxyNode(
            id: 'n1',
            name: 'Hong Kong 01',
            type: 'ss',
            countryCode: 'HK',
            latencyMs: 45,
          ),
          const ProxyNode(
            id: 'n2',
            name: 'Tokyo 01',
            type: 'vmess',
            countryCode: 'JP',
            latencyMs: 89,
          ),
          const ProxyNode(
            id: 'n3',
            name: 'Singapore 01',
            type: 'trojan',
            countryCode: 'SG',
            latencyMs: 120,
          ),
        ],
      ),
      ProxyGroup(
        id: 'direct',
        name: 'Direct',
        type: 'select',
        selectedNodeId: 'd1',
        nodes: [
          const ProxyNode(
            id: 'd1',
            name: 'Direct',
            type: 'direct',
          ),
        ],
      ),
    ];
    notifyListeners();
  }
}
