import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.account_tree_outlined,
      title: 'Profiles',
      description: 'Proxy profiles and imported configurations will live here.',
    );
  }
}
