import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppStoragePaths {
  const AppStoragePaths._(this.root);

  final Directory root;

  File get settingsFile =>
      File('${root.path}${Platform.pathSeparator}settings.json');

  Directory get profilesDirectory =>
      Directory('${root.path}${Platform.pathSeparator}profiles');

  Directory get coreDirectory =>
      Directory('${root.path}${Platform.pathSeparator}core');

  static Future<AppStoragePaths> resolve() async {
    final base = await getApplicationSupportDirectory();
    final root = Directory('${base.path}${Platform.pathSeparator}LitheNet');
    final paths = AppStoragePaths._(root);
    await paths.ensureCreated();
    return paths;
  }

  static Future<AppStoragePaths> fromRoot(Directory root) async {
    final paths = AppStoragePaths._(root);
    await paths.ensureCreated();
    return paths;
  }

  Future<void> ensureCreated() async {
    await root.create(recursive: true);
    await coreDirectory.create(recursive: true);
    await profilesDirectory.create(recursive: true);
  }
}
