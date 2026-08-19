import 'package:flutter/widgets.dart';

import '../../../data/models/proxy_group.dart';
import '../../../data/models/proxy_node.dart';
import '../../../core/runtime/core_controller.dart';
import 'proxy_catalog.dart';

enum ProxyMode { rule, global, direct }

class ProxiesController extends ChangeNotifier {
  ProxiesController({ProxyCatalog? catalog}) {
    if (catalog != null) {
      bind(catalog);
    }
  }

  ProxyCatalog? _catalog;
  CoreController? _core;
  ProxyMode _mode = ProxyMode.rule;
  List<ProxyGroup> _groups = [];
  int _selectedGroupIndex = 0;
  String _searchQuery = '';
  bool _sortAsc = true;
  bool _testing = false;
  String? _lastError;

  ProxyMode get mode => _mode;
  List<ProxyGroup> get groups => List.unmodifiable(_groups);
  int get selectedGroupIndex => _selectedGroupIndex;
  String get searchQuery => _searchQuery;
  bool get sortAsc => _sortAsc;
  bool get testing => _testing;
  String? get lastError => _lastError;

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

  void bindCore(CoreController core) {
    if (_core == core) {
      return;
    }
    _core?.removeListener(_syncFromCore);
    _core = core;
    core.addListener(_syncFromCore);
    _syncFromCore();
  }

  List<ProxyNode> get filteredNodes {
    final group = selectedGroup;
    if (group == null) return [];

    var nodes = group.nodes.where((n) => n.isAvailable).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      nodes = nodes
          .where(
            (n) =>
                n.name.toLowerCase().contains(q) ||
                n.type.toLowerCase().contains(q) ||
                (n.countryCode?.toLowerCase().contains(q) ?? false),
          )
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
    await _core?.selectOutbound(group.id, nodeId);
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
    if (_testing) return;
    _testing = true;
    _lastError = null;
    notifyListeners();

    try {
      final coreGroups = _core?.proxyGroups ?? const <ProxyGroup>[];
      final candidateGroups = coreGroups.any((group) => _isUrlTest(group.type))
          ? coreGroups
          : _groups;
      final nodeIds = {
        for (final group in candidateGroups.where(_isUrlTestGroup))
          for (final node in group.nodes)
            if (node.type.toLowerCase() != 'direct') node.id,
      };
      if (nodeIds.isEmpty) {
        final protocols = _groups
            .expand((group) => group.nodes)
            .map((node) => node.type)
            .where((type) => type.isNotEmpty)
            .toSet()
            .join(', ');
        _lastError = protocols.isEmpty
            ? 'Libbox has no testable URLTest nodes. Add a subscription first.'
            : 'Libbox has no testable URLTest nodes. '
                  'Supported nodes found: $protocols.';
        return;
      }
      final results = await Future.wait(
        nodeIds.map((nodeId) async {
          final latency = await _core?.testLatency(nodeId);
          return MapEntry(nodeId, latency);
        }),
      );
      final latencies = Map<String, int?>.fromEntries(results);
      if (latencies.values.every((latency) => latency == null)) {
        _lastError = _core?.message ?? 'Latency test returned no results.';
      }

      // The core can publish a fresh group snapshot while tests are in flight.
      // Merge by node ID into the latest snapshot instead of overwriting it.
      _groups = [
        for (final group in _groups)
          group.copyWith(
            nodes: [
              for (final node in group.nodes)
                latencies[node.id] == null
                    ? node
                    : node.copyWith(latencyMs: latencies[node.id]),
            ],
          ),
      ];
    } finally {
      _testing = false;
      notifyListeners();
    }
  }

  Future<void> testSingleLatency(String nodeId) async {
    _lastError = null;
    final coreGroups = _core?.proxyGroups ?? const <ProxyGroup>[];
    final candidateGroups = coreGroups.any(_isUrlTestGroup)
        ? coreGroups
        : _groups;
    final testable = candidateGroups.any(
      (group) =>
          _isUrlTestGroup(group) &&
          group.nodes.any(
            (node) => node.id == nodeId && node.type.toLowerCase() != 'direct',
          ),
    );
    if (!testable) {
      _lastError = 'This node is not part of a Libbox URLTest group.';
      notifyListeners();
      return;
    }
    for (var gi = 0; gi < _groups.length; gi++) {
      final group = _groups[gi];
      final idx = group.nodes.indexWhere((n) => n.id == nodeId);
      if (idx < 0) continue;

      final node = group.nodes[idx];
      final latency = await _core?.testLatency(node.id);
      if (latency == null) {
        _lastError = _core?.message ?? 'Latency test returned no result.';
      }
      final updated = List<ProxyNode>.from(group.nodes);
      updated[idx] = node.copyWith(latencyMs: latency);
      _groups[gi] = group.copyWith(nodes: updated);
      notifyListeners();
      return;
    }
  }

  bool _isUrlTest(String type) =>
      type.toLowerCase().replaceAll(RegExp(r'[-_]'), '') == 'urltest';

  bool _isUrlTestGroup(ProxyGroup group) => _isUrlTest(group.type);

  @override
  void dispose() {
    _catalog?.removeListener(_syncFromCatalog);
    _core?.removeListener(_syncFromCore);
    super.dispose();
  }

  void _syncFromCatalog() {
    final catalog = _catalog;
    if (catalog == null) {
      return;
    }
    final selectedGroupId = selectedGroup?.id;
    _groups = List<ProxyGroup>.of(catalog.groups);
    final index = _groups.indexWhere((group) => group.id == selectedGroupId);
    _selectedGroupIndex = index >= 0 ? index : 0;
    if (_selectedGroupIndex >= _groups.length) {
      _selectedGroupIndex = 0;
    }
    notifyListeners();
  }

  void _syncFromCore() {
    final core = _core;
    if (core == null || core.proxyGroups.isEmpty) {
      return;
    }
    final selectedGroupId = selectedGroup?.id;
    _groups = List<ProxyGroup>.of(core.proxyGroups);
    final index = _groups.indexWhere((group) => group.id == selectedGroupId);
    _selectedGroupIndex = index >= 0 ? index : 0;
    if (_selectedGroupIndex >= _groups.length) {
      _selectedGroupIndex = 0;
    }
    notifyListeners();
  }
}
