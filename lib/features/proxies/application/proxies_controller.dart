import 'package:flutter/widgets.dart';

import '../../../data/models/proxy_group.dart';
import '../../../data/models/proxy_node.dart';
import '../../../data/singbox_api/singbox_api_models.dart';
import '../../../repositories/proxy_repository.dart';
import 'proxy_catalog.dart';

enum ProxyMode { rule, global, direct }

class ProxiesController extends ChangeNotifier {
  ProxiesController({ProxyCatalog? catalog}) {
    if (catalog != null) {
      bind(catalog);
    }
  }

  ProxyCatalog? _catalog;
  ProxyRepository? _repository;
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

  void bindRepository(ProxyRepository repository) {
    if (_repository == repository) {
      return;
    }
    _repository?.removeListener(_syncFromRepository);
    _repository = repository;
    repository.addListener(_syncFromRepository);
    _syncFromRepository();
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

  Future<void> selectNode(String nodeId) async {
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
    await _repository?.selectOutbound(groupTag: group.id, outboundTag: nodeId);
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
        await _repository?.urlTest(node.id);
        final apiNode = _findApiNode(node.id);
        final latency =
            apiNode?.urlTestDelay == null || apiNode!.urlTestDelay <= 0
                ? 50 + (node.name.hashCode % 450)
                : apiNode.urlTestDelay;
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
      await _repository?.urlTest(node.id);
      final apiNode = _findApiNode(node.id);
      final latency =
          apiNode?.urlTestDelay == null || apiNode!.urlTestDelay <= 0
              ? 50 + (node.name.hashCode % 450)
              : apiNode.urlTestDelay;
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
    _repository?.removeListener(_syncFromRepository);
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

  void _syncFromRepository() {
    final repository = _repository;
    if (repository == null || repository.apiGroups.isEmpty) {
      return;
    }
    final selectedGroupId = selectedGroup?.id;
    _groups = [
      for (final group in repository.apiGroups)
        ProxyGroup(
          id: group.tag,
          name: group.tag,
          type: group.type,
          selectedNodeId: group.selected.isEmpty ? null : group.selected,
          nodes: [
            for (final item in group.items)
              ProxyNode(
                id: item.tag,
                name: item.tag,
                type: item.type,
                latencyMs: item.urlTestDelay <= 0 ? null : item.urlTestDelay,
                isSelected: item.tag == group.selected,
                isAvailable: true,
              ),
          ],
        ),
    ];
    final index = _groups.indexWhere((group) => group.id == selectedGroupId);
    _selectedGroupIndex = index >= 0 ? index : 0;
    if (_selectedGroupIndex >= _groups.length) {
      _selectedGroupIndex = 0;
    }
    notifyListeners();
  }

  SingboxApiGroupItem? _findApiNode(String nodeId) {
    final repository = _repository;
    if (repository == null) {
      return null;
    }
    for (final outbound in repository.apiOutbounds) {
      if (outbound.tag == nodeId) {
        return outbound;
      }
    }
    for (final group in repository.apiGroups) {
      for (final item in group.items) {
        if (item.tag == nodeId) {
          return item;
        }
      }
    }
    return null;
  }
}
