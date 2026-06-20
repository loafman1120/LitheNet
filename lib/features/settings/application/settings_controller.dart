import 'package:flutter/widgets.dart';

import '../../../data/models/app_settings.dart';

class SettingsController extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  void updateSettings(AppSettings Function(AppSettings) updater) {
    _settings = updater(_settings);
    notifyListeners();
  }

  void setThemeMode(ThemeModeOption mode) {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }

  void setStartOnBoot(bool value) {
    _settings = _settings.copyWith(startOnBoot: value);
    notifyListeners();
  }

  void setNotifications(bool value) {
    _settings = _settings.copyWith(enableNotifications: value);
    notifyListeners();
  }

  void setMixedPort(int port) {
    _settings = _settings.copyWith(mixedPort: port);
    notifyListeners();
  }

  void setIPv6(bool value) {
    _settings = _settings.copyWith(ipv6: value);
    notifyListeners();
  }

  void setSystemProxy(bool value) {
    _settings = _settings.copyWith(systemProxy: value);
    notifyListeners();
  }
}
