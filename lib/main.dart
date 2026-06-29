import 'package:flutter/material.dart';

import 'app/lithenet_app.dart';
import 'data/storage/app_storage_paths.dart';
import 'data/storage/json_file_store.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_store.dart';

export 'app/lithenet_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final paths = await AppStoragePaths.resolve();
  final settingsStore = SettingsStore(JsonFileStore(paths.settingsFile));
  final settings = await settingsStore.load();
  final settingsController = SettingsController(
    initialSettings: settings,
    store: settingsStore,
  );

  runApp(
    LitheNetApp(
      settingsController: settingsController,
      storagePaths: paths,
    ),
  );
}
