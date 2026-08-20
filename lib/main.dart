import 'dart:async';
import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import 'app/lithenet_app.dart';
import 'core/logging/app_logger.dart';
import 'data/storage/app_storage_paths.dart';
import 'data/storage/json_file_store.dart';
import 'features/settings/data/settings_store.dart';
import 'features/subscriptions/data/profile_store.dart';
import 'features/subscriptions/data/subscription_list_store.dart';

export 'app/lithenet_app.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      // Binding initialization and runApp must happen in the same zone.
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogger.error(
          'Uncaught Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogger.fatal(
          'Uncaught asynchronous platform error',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };

      AppLogger.info('Target initialization started');
      final paths = await AppStoragePaths.resolve();
      final settingsStore = SettingsStore(JsonFileStore(paths.settingsFile));
      final settings = await settingsStore.load();
      final profileStore = FileProfileStore(paths.profilesDirectory);

      AppLogger.info('Target initialization completed');
      runApp(
        LitheNetApp(
          initialSettings: settings,
          settingsStore: settingsStore,
          subscriptionListStore: FileSubscriptionListStore(
            JsonFileStore(paths.subscriptionsFile),
          ),
          profileStore: profileStore,
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.fatal(
        'Uncaught error in application zone',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
