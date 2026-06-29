import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/data/models/app_settings.dart';
import 'package:lithenet/data/storage/app_storage_paths.dart';
import 'package:lithenet/data/storage/json_file_store.dart';
import 'package:lithenet/features/settings/application/settings_controller.dart';
import 'package:lithenet/features/settings/data/settings_store.dart';

void main() {
  test('AppStoragePaths creates settings, profile, and core locations',
      () async {
    final directory = await Directory.systemTemp.createTemp('lithenet_paths');
    addTearDown(() => directory.delete(recursive: true));

    final paths = await AppStoragePaths.fromRoot(directory);

    expect(paths.settingsFile.path,
        '${directory.path}${Platform.pathSeparator}settings.json');
    expect(await paths.profilesDirectory.exists(), isTrue);
    expect(await paths.coreDirectory.exists(), isTrue);
  });

  test('AppSettings round trips through JSON with enum values', () {
    const settings = AppSettings(
      themeMode: ThemeModeOption.dark,
      startOnBoot: true,
      enableNotifications: false,
      listenAddress: '0.0.0.0',
      mixedPort: 7890,
      proxyMode: ProxyMode.tun,
      ipv6: true,
      systemProxy: false,
      perAppProxy: true,
    );

    final restored = AppSettings.fromJson(settings.toJson());

    expect(restored.themeMode, ThemeModeOption.dark);
    expect(restored.startOnBoot, isTrue);
    expect(restored.enableNotifications, isFalse);
    expect(restored.listenAddress, '0.0.0.0');
    expect(restored.mixedPort, 7890);
    expect(restored.proxyMode, ProxyMode.tun);
    expect(restored.ipv6, isTrue);
    expect(restored.systemProxy, isFalse);
    expect(restored.perAppProxy, isTrue);
  });

  test('SettingsStore saves and loads settings.json', () async {
    final directory =
        await Directory.systemTemp.createTemp('lithenet_settings');
    addTearDown(() => directory.delete(recursive: true));

    final store = SettingsStore(
      JsonFileStore(
          File('${directory.path}${Platform.pathSeparator}settings.json')),
    );

    await store.save(
      const AppSettings(
        themeMode: ThemeModeOption.light,
        mixedPort: 9090,
        proxyMode: ProxyMode.tun,
      ),
    );

    final restored = await store.load();

    expect(restored.themeMode, ThemeModeOption.light);
    expect(restored.mixedPort, 9090);
    expect(restored.proxyMode, ProxyMode.tun);
  });

  test('SettingsController persists mutations', () async {
    final store = MemorySettingsStore();
    final controller = SettingsController(store: store);
    addTearDown(controller.dispose);

    controller
      ..setThemeMode(ThemeModeOption.dark)
      ..setMixedPort(8088);

    await Future<void>.delayed(Duration.zero);

    final restored = await store.load();
    expect(restored.themeMode, ThemeModeOption.dark);
    expect(restored.mixedPort, 8088);
    expect(controller.lastError, isNull);
  });
}
