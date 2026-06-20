import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.settings_outlined,
      title: 'Settings',
      description: 'Application preferences and core paths will live here.',
    );
  }
}
