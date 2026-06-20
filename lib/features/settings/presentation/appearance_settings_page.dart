import 'package:flutter/material.dart';

import '../../../data/models/app_settings.dart';
import '../application/settings_controller.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        children: ThemeModeOption.values.map((mode) {
          return ListTile(
            leading: Icon(
              controller.settings.themeMode == mode
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            title: Text(mode.label),
            onTap: () => controller.setThemeMode(mode),
          );
        }).toList(),
      ),
    );
  }
}
