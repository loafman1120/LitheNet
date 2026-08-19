import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/logging/app_logger.dart';
import 'package:lithenet/data/models/log_entry.dart';
import 'package:lithenet/features/logs/application/logs_controller.dart';

void main() {
  test('application logger entries appear in the logs controller', () async {
    AppLogger.clear();
    final controller = LogsController();
    addTearDown(controller.dispose);

    AppLogger.warning(
      'group subscription failed',
      source: 'libbox',
      error: StateError('deadline'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.level, LogLevel.warning);
    expect(controller.entries.single.source, 'libbox');
    expect(controller.entries.single.message, contains('deadline'));
  });

  test('unpausing catches up from the shared log buffer', () async {
    AppLogger.clear();
    final controller = LogsController()..togglePause();
    addTearDown(controller.dispose);

    AppLogger.info('logged while paused', source: 'core');
    await Future<void>.delayed(Duration.zero);
    expect(controller.entries, isEmpty);

    controller.togglePause();
    expect(controller.entries.single.message, 'logged while paused');
  });
}
