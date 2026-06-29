import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../data/models/app_settings.dart';
import '../data/settings_store.dart';

class SettingsControllerScope extends InheritedNotifier<SettingsController> {
  const SettingsControllerScope({
    required SettingsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SettingsControllerScope>();
    assert(scope != null, 'SettingsControllerScope was not found.');
    return scope!.notifier!;
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController({
    AppSettings initialSettings = const AppSettings(),
    AppSettingsStore? store,
  })  : _settings = initialSettings,
        _store = store ?? MemorySettingsStore(initialSettings);

  final AppSettingsStore _store;
  AppSettings _settings;
  bool _saving = false;
  Object? _lastError;
  bool _saveInFlight = false;
  bool _saveAgain = false;

  AppSettings get settings => _settings;
  bool get saving => _saving;
  Object? get lastError => _lastError;

  void updateSettings(AppSettings Function(AppSettings) updater) {
    _setSettings(updater(_settings));
  }

  void setThemeMode(ThemeModeOption mode) {
    _setSettings(_settings.copyWith(themeMode: mode));
  }

  void setStartOnBoot(bool value) {
    _setSettings(_settings.copyWith(startOnBoot: value));
  }

  void setNotifications(bool value) {
    _setSettings(_settings.copyWith(enableNotifications: value));
  }

  void setMixedPort(int port) {
    _setSettings(_settings.copyWith(mixedPort: port));
  }

  void setProxyMode(ProxyMode mode) {
    _setSettings(_settings.copyWith(proxyMode: mode));
  }

  void setIPv6(bool value) {
    _setSettings(_settings.copyWith(ipv6: value));
  }

  void setSystemProxy(bool value) {
    _setSettings(_settings.copyWith(systemProxy: value));
  }

  void _setSettings(AppSettings settings) {
    _settings = settings;
    _lastError = null;
    notifyListeners();
    unawaited(_saveLatest());
  }

  Future<void> _saveLatest() async {
    if (_saveInFlight) {
      _saveAgain = true;
      return;
    }

    _saveInFlight = true;
    _setSaving(true);
    do {
      _saveAgain = false;
      final settings = _settings;
      try {
        await _store.save(settings);
        _lastError = null;
      } catch (error) {
        _lastError = error;
      }
    } while (_saveAgain);

    _saveInFlight = false;
    _setSaving(false);
  }

  void _setSaving(bool value) {
    if (_saving == value) {
      return;
    }
    _saving = value;
    notifyListeners();
  }
}
