import 'package:material_ui/material_ui.dart';

import '../../../../core/runtime/core_controller.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({
    required this.core,
    this.onConnect,
    this.onDisconnect,
    super.key,
  });

  final CoreController core;
  final Future<void> Function()? onConnect;
  final Future<void> Function()? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = core.running;
    final busy = core.busy;

    return SizedBox(
      width: 200,
      height: 200,
      child: FilledButton(
        onPressed: busy || !core.available
            ? null
            : running
            ? onDisconnect ?? core.stop
            : onConnect ?? core.start,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: running
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          disabledBackgroundColor: theme.colorScheme.onSurfaceVariant
              .withValues(alpha: 0.12),
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
