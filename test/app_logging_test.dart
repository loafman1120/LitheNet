import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/logging/app_logger.dart';
import 'package:lithenet/data/models/log_entry.dart';
import 'package:lithenet/features/logs/application/logs_notifier.dart';

void main() {
  test('application logger entries appear in the logs notifier', () async {
    AppLogger.clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(logsProvider);

    AppLogger.warning(
      'group subscription failed',
      source: 'libbox',
      error: StateError('deadline'),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(logsProvider);
    expect(state.entries, hasLength(1));
    expect(state.entries.single.level, LogLevel.warning);
    expect(state.entries.single.source, 'libbox');
    expect(state.entries.single.message, contains('deadline'));
  });

  test('unpausing catches up from the shared log buffer', () async {
    AppLogger.clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(logsProvider.notifier)..togglePause();

    AppLogger.info('logged while paused', source: 'core');
    await Future<void>.delayed(Duration.zero);
    expect(container.read(logsProvider).entries, isEmpty);

    notifier.togglePause();
    expect(
      container.read(logsProvider).entries.single.message,
      'logged while paused',
    );
  });
}
