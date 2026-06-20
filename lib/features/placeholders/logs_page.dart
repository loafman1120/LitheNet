import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.receipt_long_outlined,
      title: 'Logs',
      description: 'Runtime logs and connection events will appear here.',
    );
  }
}
