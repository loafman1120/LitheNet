import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.rule_outlined,
      title: 'Rules',
      description: 'Routing rules, rule sets, and DNS policies will live here.',
    );
  }
}
