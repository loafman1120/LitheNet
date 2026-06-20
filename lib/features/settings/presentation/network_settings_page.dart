import 'package:flutter/material.dart';

import '../application/settings_controller.dart';

class NetworkSettingsPage extends StatelessWidget {
  const NetworkSettingsPage({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Mixed port'),
            subtitle: Text('${controller.settings.mixedPort}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('IPv6'),
            value: controller.settings.ipv6,
            onChanged: controller.setIPv6,
          ),
          SwitchListTile(
            title: const Text('System proxy'),
            subtitle: const Text('Set as system HTTP proxy'),
            value: controller.settings.systemProxy,
            onChanged: controller.setSystemProxy,
          ),
        ],
      ),
    );
  }
}
