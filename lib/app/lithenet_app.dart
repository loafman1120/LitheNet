import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/runtime/core_gateway.dart';
import '../core/runtime/core_notifier.dart';
import '../data/models/app_settings.dart';
import '../features/settings/application/settings_notifier.dart';
import '../features/settings/data/settings_store.dart';
import '../features/subscriptions/application/subscriptions_notifier.dart';
import '../features/subscriptions/data/profile_store.dart';
import '../features/subscriptions/data/subscription_list_store.dart';
import '../features/subscriptions/data/subscriptions_repository.dart';
import 'app_identity.dart';
import 'router.dart';

class LitheNetApp extends StatelessWidget {
  const LitheNetApp({
    super.key,
    this.coreGateway,
    this.initialSettings,
    this.settingsStore,
    this.subscriptionListStore,
    this.profileStore,
    this.subscriptionRepository,
  });

  final CoreGateway? coreGateway;
  final AppSettings? initialSettings;
  final AppSettingsStore? settingsStore;
  final SubscriptionListStore? subscriptionListStore;
  final AtomicProfileStore? profileStore;
  final SubscriptionRepository? subscriptionRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (coreGateway != null)
          coreGatewayProvider.overrideWithValue(coreGateway!),
        if (initialSettings != null)
          initialSettingsProvider.overrideWithValue(initialSettings!),
        if (settingsStore != null)
          settingsStoreProvider.overrideWithValue(settingsStore!),
        if (subscriptionListStore != null)
          subscriptionListStoreProvider.overrideWithValue(
            subscriptionListStore!,
          ),
        if (profileStore != null)
          profileStoreProvider.overrideWithValue(profileStore!),
        if (subscriptionRepository != null)
          subscriptionRepositoryProvider.overrideWithValue(
            subscriptionRepository!,
          ),
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
    ref.read(subscriptionsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).settings;

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
