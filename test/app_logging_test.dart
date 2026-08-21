import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target/core/logging/app_logger.dart';
import 'package:target/data/models/log_entry.dart';
import 'package:target/features/logs/application/logs_notifier.dart';

void main() {
  test(
    'application logger persists entries and stack traces to disk',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'target_logging_test_',
      );
      addTearDown(() async {
        AppLogger.shutdownFileLogging();
        await temporaryDirectory.delete(recursive: true);
      });
      AppLogger.clear();

      await AppLogger.initialize(temporaryDirectory);
      AppLogger.error(
        'libboxd installation failed',
        source: 'libboxd',
        error: StateError('exit code 1'),
        stackTrace: StackTrace.fromString('service stack'),
      );

      final logFile = File(AppLogger.logFilePath!);
      expect(await logFile.exists(), isTrue);
      final contents = await logFile.readAsString();
      expect(contents, contains('[ERROR  ] [libboxd]'));
      expect(contents, contains('libboxd installation failed'));
      expect(contents, contains('exit code 1'));
      expect(contents, contains('service stack'));
    },
  );

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
