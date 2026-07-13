import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/runtime/core_controller.dart';
import '../core/runtime/core_gateway.dart';
import '../features/connections/application/connections_controller.dart';
import '../features/logs/application/logs_controller.dart';
import '../features/proxies/application/proxies_controller.dart';
import '../features/proxies/application/proxy_catalog.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/subscriptions/application/subscriptions_controller.dart';

final coreGatewayProvider = Provider<CoreGateway>(
  (ref) => const UnavailableCoreGateway(),
);

final settingsControllerProvider = ChangeNotifierProvider<SettingsController>(
  (ref) => SettingsController(),
);

final coreControllerProvider = ChangeNotifierProvider<CoreController>((ref) {
  final settings = ref.read(settingsControllerProvider).settings;
  return CoreController(
    gateway: ref.read(coreGatewayProvider),
    initialSettings: settings,
  );
});

final proxyCatalogProvider = ChangeNotifierProvider<ProxyCatalog>(
  (ref) => ProxyCatalog(),
);

final subscriptionsControllerProvider =
    ChangeNotifierProvider<SubscriptionsController>((ref) {
      return SubscriptionsController()
        ..bindProxyCatalog(ref.read(proxyCatalogProvider));
    });

final proxiesControllerProvider = ChangeNotifierProvider<ProxiesController>((
  ref,
) {
  return ProxiesController(catalog: ref.read(proxyCatalogProvider))
    ..bindCore(ref.read(coreControllerProvider));
});

final connectionsControllerProvider =
    ChangeNotifierProvider<ConnectionsController>((ref) {
      return ConnectionsController()..bind(ref.read(coreControllerProvider));
    });

final logsControllerProvider = ChangeNotifierProvider<LogsController>((ref) {
  return LogsController()..bind(ref.read(coreControllerProvider));
});
