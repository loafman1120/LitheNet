import 'package:flutter/material.dart';

import '../application/settings_controller.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Start on boot'),
            subtitle: const Text('Launch proxy automatically'),
            value: controller.settings.startOnBoot,
            onChanged: controller.setStartOnBoot,
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Show connection status notifications'),
            value: controller.settings.enableNotifications,
            onChanged: controller.setNotifications,
          ),
        ],
      ),
    );
  }
}
