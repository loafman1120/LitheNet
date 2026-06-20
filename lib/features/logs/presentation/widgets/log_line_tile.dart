import 'package:flutter/material.dart';

import '../../../../data/models/log_entry.dart';

class LogLineTile extends StatelessWidget {
  const LogLineTile({required this.entry, super.key});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.timeString,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Consolas',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _levelColor(entry.level, theme).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.level.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _levelColor(entry.level, theme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '[${entry.source}] ${entry.message}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Consolas',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(LogLevel level, ThemeData theme) {
    return switch (level) {
      LogLevel.error => theme.colorScheme.error,
      LogLevel.warning => const Color(0xffd97706),
      LogLevel.info => theme.colorScheme.primary,
      LogLevel.debug => theme.colorScheme.onSurfaceVariant,
      LogLevel.trace =>
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
    };
  }
}
