import 'package:flutter/widgets.dart';

import '../../../data/models/proxy_group.dart';
import '../../../data/models/proxy_node.dart';
import '../../subscriptions/data/subscription_parser.dart';

class ProxyCatalogScope extends InheritedNotifier<ProxyCatalog> {
  const ProxyCatalogScope({
    required ProxyCatalog catalog,
    required super.child,
    super.key,
  }) : super(notifier: catalog);

  static ProxyCatalog of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ProxyCatalogScope>();
    assert(scope != null, 'ProxyCatalogScope was not found in the tree.');
    return scope!.notifier!;
  }
}

class ProxyCatalog extends ChangeNotifier {
  List<ProxyGroup> _groups = [];

  List<ProxyGroup> get groups => List.unmodifiable(_groups);

  void replaceFromProfile(ParsedProfile profile) {
    if (profile.nodes.isEmpty) {
      return;
    }

    final previousSelections = {
      for (final group in _groups) group.id: group.selectedNodeId,
    };
    final nodes = _mergeLatency(profile.nodes);
    final nextGroups = <ProxyGroup>[
      ProxyGroup(
        id: 'all',
        name: 'All',
        type: 'select',
        selectedNodeId: _restoreSelection(
          previousSelections['all'],
          nodes,
        ),
        nodes: _markSelected(nodes, previousSelections['all']),
      ),
    ];

    final grouped = <String, List<ProxyNode>>{};
    for (final node in nodes) {
      final groupName = node.metadata['group'] as String?;
      if (groupName == null || groupName.isEmpty) {
        continue;
      }
      grouped.putIfAbsent(groupName, () => []).add(node);
    }

    for (final entry in grouped.entries) {
      final id = _groupId(entry.key);
      final selected = _restoreSelection(previousSelections[id], entry.value);
      nextGroups.add(
        ProxyGroup(
          id: id,
          name: entry.key,
          type: 'select',
          selectedNodeId: selected,
          nodes: _markSelected(entry.value, selected),
        ),
      );
    }

    final directNode = const ProxyNode(
      id: 'direct',
      name: 'Direct',
      type: 'direct',
      metadata: {'source': 'builtin'},
    );
    nextGroups.add(
      ProxyGroup(
        id: 'direct',
        name: 'Direct',
        type: 'select',
        selectedNodeId: 'direct',
        nodes: [directNode],
      ),
    );

    _groups = nextGroups;
    notifyListeners();
  }

  void selectNode(String groupId, String nodeId) {
    _groups = [
      for (final group in _groups)
        if (group.id == groupId)
          group.copyWith(
            selectedNodeId: nodeId,
            nodes: _markSelected(group.nodes, nodeId),
          )
        else
          group,
    ];
    notifyListeners();
  }

  List<ProxyNode> _mergeLatency(List<ProxyNode> nodes) {
    final previous = <String, ProxyNode>{};
    for (final group in _groups) {
      for (final node in group.nodes) {
        previous[node.id] = node;
      }
    }
    return [
      for (final node in nodes)
        node.copyWith(latencyMs: previous[node.id]?.latencyMs),
    ];
  }

  String? _restoreSelection(String? previous, List<ProxyNode> nodes) {
    if (previous != null && nodes.any((node) => node.id == previous)) {
      return previous;
    }
    return nodes.isEmpty ? null : nodes.first.id;
  }

  List<ProxyNode> _markSelected(List<ProxyNode> nodes, String? selectedNodeId) {
    final selected = _restoreSelection(selectedNodeId, nodes);
    return [
      for (final node in nodes) node.copyWith(isSelected: node.id == selected),
    ];
  }

  String _groupId(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'group' : normalized;
  }
}
