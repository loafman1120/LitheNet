import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/connections/presentation/connections_page.dart';
import '../features/home/home_page.dart';
import '../features/logs/presentation/logs_page.dart';
import '../features/proxies/presentation/proxies_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/subscriptions/presentation/subscriptions_page.dart';
import 'shell/app_shell.dart';

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            pageBuilder: _fadePageBuilder(const HomePage()),
          ),
          GoRoute(
            path: AppRoute.proxies.path,
            pageBuilder: _fadePageBuilder(const ProxiesPage()),
          ),
          GoRoute(
            path: AppRoute.subscriptions.path,
            pageBuilder: _fadePageBuilder(const SubscriptionsPage()),
          ),
          GoRoute(
            path: AppRoute.connections.path,
            pageBuilder: _fadePageBuilder(const ConnectionsPage()),
          ),
          GoRoute(
            path: AppRoute.logs.path,
            pageBuilder: _fadePageBuilder(const LogsPage()),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            pageBuilder: _fadePageBuilder(const SettingsPage()),
          ),
        ],
      ),
    ],
  );

  static Page<void> Function(BuildContext, GoRouterState) _fadePageBuilder(
    Widget child,
  ) {
    return (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: child,
        );
  }
}

enum AppRoute {
  home('/'),
  proxies('/proxies'),
  subscriptions('/subscriptions'),
  connections('/connections'),
  logs('/logs'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
