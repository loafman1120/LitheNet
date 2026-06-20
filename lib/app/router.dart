import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/placeholders/logs_page.dart';
import '../features/placeholders/profiles_page.dart';
import '../features/placeholders/rules_page.dart';
import '../features/placeholders/settings_page.dart';
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
            path: AppRoute.profiles.path,
            pageBuilder: _fadePageBuilder(const ProfilesPage()),
          ),
          GoRoute(
            path: AppRoute.rules.path,
            pageBuilder: _fadePageBuilder(const RulesPage()),
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
  profiles('/profiles'),
  rules('/rules'),
  logs('/logs'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
