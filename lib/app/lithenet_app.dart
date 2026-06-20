import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/proxies/application/proxy_catalog.dart';
import '../repositories/proxy_repository.dart';
import 'router.dart';

class LitheNetApp extends StatefulWidget {
  const LitheNetApp({
    super.key,
    this.proxyRepository,
  });

  final ProxyRepository? proxyRepository;

  @override
  State<LitheNetApp> createState() => _LitheNetAppState();
}

class _LitheNetAppState extends State<LitheNetApp> {
  late final ProxyRepository _proxyRepository;
  late final ProxyCatalog _proxyCatalog;
  late final AppRouter _appRouter;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _proxyRepository = widget.proxyRepository ?? SingboxProxyRepository();
    _proxyCatalog = ProxyCatalog();
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    _proxyRepository.dispose();
    _proxyCatalog.dispose();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return ProxyCatalogScope(
      catalog: _proxyCatalog,
      child: ProxyRepositoryScope(
        repository: _proxyRepository,
        child: MaterialApp.router(
          title: 'LitheNet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeMode,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
