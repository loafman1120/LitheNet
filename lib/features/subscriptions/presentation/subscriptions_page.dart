import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../application/subscriptions_controller.dart';
import 'widgets/add_subscription_sheet.dart';
import 'widgets/subscription_card.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  late SubscriptionsController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = SubscriptionsControllerScope.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final subs = _controller.subscriptions;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscriptions'),
            actions: [
              IconButton(
                onPressed: _controller.busy ? null : _updateAll,
                icon: const Icon(Icons.sync),
                tooltip: 'Update all',
              ),
              IconButton(
                onPressed: _showAddSheet,
                icon: const Icon(Icons.add),
                tooltip: 'Add subscription',
              ),
            ],
          ),
          body: subs.isEmpty
              ? EmptyState(
                  icon: Icons.rss_feed_outlined,
                  title: 'No subscriptions',
                  description: 'Add a subscription URL to get started.',
                  action: FilledButton.icon(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subscription'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SubscriptionCard(
                        subscription: sub,
                        onTap: () {},
                        onMenuSelected: (action) => _handleMenu(action, sub.id),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _showAddSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddSubscriptionSheet(),
    );

    if (result == null) return;
    final url = result['url'];
    if (url == null || url.isEmpty) return;

    final added = await _controller.addSubscription(url, name: result['name']);
    if (!mounted) return;
    if (!added) {
      _showError(_controller.lastError ?? 'Subscription was not added.');
      return;
    }
    final error = _controller.lastError;
    if (error != null && error.isNotEmpty) {
      _showError(error);
    }
  }

  Future<void> _handleMenu(String action, String id) async {
    switch (action) {
      case 'use':
        await _controller.setActive(id);
      case 'update':
        await _controller.updateSubscription(id);
      case 'rename':
        _showRenameDialog(id);
      case 'delete':
        _showDeleteConfirm(id);
    }
  }

  Future<void> _updateAll() async {
    final ids = _controller.subscriptions.map((s) => s.id).toList();
    for (final id in ids) {
      await _controller.updateSubscription(id);
    }
  }

  void _showRenameDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await _controller.renameSubscription(id, name);
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete subscription?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await _controller.removeSubscription(id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
