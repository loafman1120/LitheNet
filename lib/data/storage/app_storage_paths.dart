import 'dart:io';

import '../../app/app_identity.dart';

class AppStoragePaths {
  const AppStoragePaths._(this.root);

  final Directory root;

  File get settingsFile =>
      File('${root.path}${Platform.pathSeparator}settings.json');

  File get subscriptionsFile =>
      File('${root.path}${Platform.pathSeparator}subscriptions.json');

  Directory get profilesDirectory =>
      Directory('${root.path}${Platform.pathSeparator}profiles');

  Directory get coreDirectory =>
      Directory('${root.path}${Platform.pathSeparator}core');

  static Future<AppStoragePaths> resolve() async {
    final root = Directory(_defaultRootPath());
    final paths = AppStoragePaths._(root);
    await paths.ensureCreated();
    await paths._migrateLegacyDirectories();
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

  Future<void> _migrateLegacyDirectories() async {
    for (final legacy in _legacyRoots()) {
      if (!await legacy.exists() || legacy.path == root.path) {
        continue;
      }

      await _copyFileIfMissing(
        File('${legacy.path}${Platform.pathSeparator}settings.json'),
        settingsFile,
      );
      await _copyFileIfMissing(
        File('${legacy.path}${Platform.pathSeparator}subscriptions.json'),
        subscriptionsFile,
      );
      await _copyDirectoryContentsIfMissing(
        Directory('${legacy.path}${Platform.pathSeparator}profiles'),
        profilesDirectory,
      );
      await _copyDirectoryContentsIfMissing(
        Directory('${legacy.path}${Platform.pathSeparator}core'),
        coreDirectory,
      );
    }
  }

  Future<void> _copyFileIfMissing(File source, File destination) async {
    if (!await source.exists() || await destination.exists()) {
      return;
    }
    await destination.parent.create(recursive: true);
    await source.copy(destination.path);
  }

  Future<void> _copyDirectoryContentsIfMissing(
    Directory source,
    Directory destination,
  ) async {
    if (!await source.exists()) {
      return;
    }
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      final relative = entity.path.substring(source.path.length + 1);
      final target = File('${destination.path}${Platform.pathSeparator}'
          '${relative.replaceAll(RegExp(r'[\\/]'), Platform.pathSeparator)}');
      if (await target.exists()) {
        continue;
      }
      await target.parent.create(recursive: true);
      await entity.copy(target.path);
    }
  }

  static String _defaultRootPath() {
    final separator = Platform.pathSeparator;
    if (Platform.isWindows) {
      final roaming = Platform.environment['APPDATA'];
      if (roaming != null && roaming.trim().isNotEmpty) {
        return '$roaming$separator${AppIdentity.displayName}';
      }
    }
    if (Platform.isMacOS) {
      final home = _homeDirectoryPath();
      if (home != null) {
        return '$home${separator}Library${separator}Application Support'
            '$separator${AppIdentity.displayName}';
      }
    }
    if (Platform.isLinux) {
      final dataHome = Platform.environment['XDG_DATA_HOME'];
      if (dataHome != null && dataHome.trim().isNotEmpty) {
        return '$dataHome$separator${AppIdentity.displayName}';
      }
      final home = _homeDirectoryPath();
      if (home != null) {
        return '$home$separator.local${separator}share'
            '$separator${AppIdentity.displayName}';
      }
    }

    final base = _applicationSupportDirectoryFallback();
    return '${base.path}$separator${AppIdentity.displayName}';
  }

  static Directory _applicationSupportDirectoryFallback() {
    try {
      final home = _homeDirectoryPath() ?? Directory.current.path;
      return Directory('$home${Platform.pathSeparator}.lithe');
    } catch (_) {
      return Directory.current;
    }
  }

  List<Directory> _legacyRoots() {
    final separator = Platform.pathSeparator;
    final roots = <Directory>[];
    if (Platform.isWindows) {
      final roaming = Platform.environment['APPDATA'];
      if (roaming != null && roaming.trim().isNotEmpty) {
        roots
          ..add(Directory('$roaming${separator}LitheNet'))
          ..add(Directory('$roaming${separator}com.example'
              '${separator}lithenet${separator}LitheNet'));
      }
    }

    final home = _homeDirectoryPath();
    if (home != null) {
      roots
        ..add(Directory('$home$separator.lithenet'))
        ..add(Directory('$home$separator.lithenet'
            '$separator${AppIdentity.legacyDisplayName}'));
    }

    return roots;
  }

  static String? _homeDirectoryPath() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.trim().isEmpty) {
      return null;
    }
    return home;
  }
}
