import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/runtime/core_gateway.dart';
import '../data/models/app_settings.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/subscriptions/application/subscriptions_controller.dart';
import 'app_providers.dart';
import 'app_identity.dart';
import 'router.dart';

class LitheNetApp extends StatelessWidget {
  const LitheNetApp({
    super.key,
    this.coreGateway,
    this.settingsController,
    this.subscriptionsController,
  });

  final CoreGateway? coreGateway;
  final SettingsController? settingsController;
  final SubscriptionsController? subscriptionsController;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (coreGateway != null)
          coreGatewayProvider.overrideWithValue(coreGateway!),
        if (settingsController != null)
          settingsControllerProvider.overrideWith((ref) => settingsController!),
        if (subscriptionsController != null)
          subscriptionsControllerProvider.overrideWith((ref) {
            subscriptionsController!.bindProxyCatalog(
              ref.read(proxyCatalogProvider),
            );
            subscriptionsController!.bindCoreController(
              ref.read(coreControllerProvider),
            );
            return subscriptionsController!;
          }),
      ],
      child: const _LitheNetAppView(),
    );
  }
}

class _LitheNetAppView extends ConsumerStatefulWidget {
  const _LitheNetAppView();

  @override
  ConsumerState<_LitheNetAppView> createState() => _LitheNetAppViewState();
}

class _LitheNetAppViewState extends ConsumerState<_LitheNetAppView> {
  late final AppRouter _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    ref.read(subscriptionsControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).settings;

    return MaterialApp.router(
      title: AppIdentity.displayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeModeFor(settings.themeMode),
      routerConfig: _appRouter.router,
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
