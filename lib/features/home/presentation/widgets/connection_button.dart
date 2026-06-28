import 'package:flutter/material.dart';

import '../../../../repositories/proxy_repository.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({required this.repository, super.key});

  final ProxyRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = repository.running;
    final busy = repository.busy;

    return SizedBox(
      width: 200,
      height: 200,
      child: FilledButton(
        onPressed: busy
            ? null
            : running
                ? repository.stop
                : repository.start,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              running ? theme.colorScheme.error : theme.colorScheme.primary,
          disabledBackgroundColor:
              theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                running ? Icons.stop : Icons.power_settings_new,
                size: 48,
                color: Colors.white,
              ),
            const SizedBox(height: 8),
            Text(
              busy
                  ? 'Please wait'
                  : running
                      ? 'Disconnect'
                      : 'Connect',
              style: theme.textTheme.titleMedium?.copyWith(
                color: busy ? theme.colorScheme.onSurfaceVariant : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
