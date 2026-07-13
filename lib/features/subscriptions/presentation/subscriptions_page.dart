import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/widgets/empty_state.dart';
import 'widgets/add_subscription_sheet.dart';
import 'widgets/subscription_card.dart';

class SubscriptionsPage extends ConsumerStatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(subscriptionsControllerProvider);
    final subs = controller.subscriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            onPressed: controller.busy ? null : _updateAll,
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
      body:
          subs.isEmpty
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

    final controller = ref.read(subscriptionsControllerProvider);
    final added = await controller.addSubscription(url, name: result['name']);
    if (!mounted) return;
    if (!added) {
      _showError(controller.lastError ?? 'Subscription was not added.');
      return;
    }
    final error = controller.lastError;
    if (error != null && error.isNotEmpty) {
      _showError(error);
    }
  }

  Future<void> _handleMenu(String action, String id) async {
    final controller = ref.read(subscriptionsControllerProvider);
    switch (action) {
      case 'use':
        await controller.setActive(id);
      case 'update':
        await controller.updateSubscription(id);
      case 'rename':
        _showRenameDialog(id);
      case 'delete':
        _showDeleteConfirm(id);
    }
  }

  Future<void> _updateAll() async {
    final controller = ref.read(subscriptionsControllerProvider);
    final ids = controller.subscriptions.map((s) => s.id).toList();
    for (final id in ids) {
      await controller.updateSubscription(id);
    }
  }

  void _showRenameDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                    await ref
                        .read(subscriptionsControllerProvider)
                        .renameSubscription(id, name);
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
      builder:
          (_) => AlertDialog(
            title: const Text('Delete subscription?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(subscriptionsControllerProvider)
                      .removeSubscription(id);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
