import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/models/app_settings.dart';
import '../data/storage/app_storage_paths.dart';
import '../features/proxies/application/proxy_catalog.dart';
import '../features/settings/application/settings_controller.dart';
import '../repositories/proxy_repository.dart';
import 'router.dart';

class LitheNetApp extends StatefulWidget {
  const LitheNetApp({
    super.key,
    this.proxyRepository,
    this.settingsController,
    this.storagePaths,
  });

  final ProxyRepository? proxyRepository;
  final SettingsController? settingsController;
  final AppStoragePaths? storagePaths;

  @override
  State<LitheNetApp> createState() => _LitheNetAppState();
}

class _LitheNetAppState extends State<LitheNetApp> {
  late final ProxyRepository _proxyRepository;
  late final ProxyCatalog _proxyCatalog;
  late final SettingsController _settingsController;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _settingsController = widget.settingsController ?? SettingsController();
    _proxyRepository = widget.proxyRepository ??
        SingboxProxyRepository(
          initialSettings: _settingsController.settings,
          storagePaths: widget.storagePaths,
        );
    _proxyCatalog = ProxyCatalog();
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    _proxyRepository.dispose();
    _proxyCatalog.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, _) {
        return SettingsControllerScope(
          controller: _settingsController,
          child: ProxyCatalogScope(
            catalog: _proxyCatalog,
            child: ProxyRepositoryScope(
              repository: _proxyRepository,
              child: MaterialApp.router(
                title: 'LitheNet',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode:
                    _themeModeFor(_settingsController.settings.themeMode),
                routerConfig: _appRouter.router,
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeMode _themeModeFor(ThemeModeOption mode) {
    return switch (mode) {
      ThemeModeOption.system => ThemeMode.system,
      ThemeModeOption.light => ThemeMode.light,
      ThemeModeOption.dark => ThemeMode.dark,
    };
  }
}
