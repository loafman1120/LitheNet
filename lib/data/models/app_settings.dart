import 'package:flutter/foundation.dart';

enum ThemeModeOption {
  system,
  light,
  dark;

  String get label => switch (this) {
        ThemeModeOption.system => 'System',
        ThemeModeOption.light => 'Light',
        ThemeModeOption.dark => 'Dark',
      };
}

enum ProxyMode {
  mixed,
  tun;

  String get label => switch (this) {
        ProxyMode.mixed => 'System proxy',
        ProxyMode.tun => 'TUN',
      };
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModeOption.system,
    this.startOnBoot = false,
    this.enableNotifications = true,
    this.listenAddress = '127.0.0.1',
    this.mixedPort = 2080,
    this.proxyMode = ProxyMode.mixed,
    this.ipv6 = false,
    this.systemProxy = true,
    this.perAppProxy = false,
  });

  final ThemeModeOption themeMode;
  final bool startOnBoot;
  final bool enableNotifications;
  final String listenAddress;
  final int mixedPort;
  final ProxyMode proxyMode;
  final bool ipv6;
  final bool systemProxy;
  final bool perAppProxy;

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    bool? startOnBoot,
    bool? enableNotifications,
    String? listenAddress,
    int? mixedPort,
    ProxyMode? proxyMode,
    bool? ipv6,
    bool? systemProxy,
    bool? perAppProxy,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      startOnBoot: startOnBoot ?? this.startOnBoot,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      listenAddress: listenAddress ?? this.listenAddress,
      mixedPort: mixedPort ?? this.mixedPort,
      proxyMode: proxyMode ?? this.proxyMode,
      ipv6: ipv6 ?? this.ipv6,
      systemProxy: systemProxy ?? this.systemProxy,
      perAppProxy: perAppProxy ?? this.perAppProxy,
    );
  }
}
