import 'package:flutter/material.dart';

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
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _proxyRepository = widget.proxyRepository ?? SingboxProxyRepository();
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    _proxyRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProxyRepositoryScope(
      repository: _proxyRepository,
      child: MaterialApp.router(
        title: 'LitheNet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff2563eb),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          cardTheme: const CardThemeData(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
