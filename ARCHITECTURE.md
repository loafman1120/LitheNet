# Lithe Architecture

## Design goals

1. Keep Flutter UI independent from the native core implementation.
2. Keep one observable source of truth for each feature.
3. Make runtime dependencies replaceable in tests and at app startup.
4. Avoid code generation until the Rustbox Dart API stabilizes.

## Layers

```text
lib/app                 application composition, routing, shell
lib/core                theme, reusable widgets, runtime boundary
lib/features            feature state, data access, and presentation
lib/data                shared models and local persistence
```

Riverpod providers in `lib/app/app_providers.dart` form the composition root.
Pages read providers directly; they do not create controllers, bind listeners,
or depend on custom `InheritedNotifier` scopes.

## Native runtime boundary

`CoreGateway` is the only contract the Rustbox integration needs to implement.
It exposes lifecycle operations and a stream of immutable `CoreSnapshot`
values. `CoreController` converts that stream into UI-observable state and
owns error/busy handling.

The default `UnavailableCoreGateway` is intentional. It keeps the UI usable
while the Dart bridge is unfinished without simulated traffic, fake latency,
or a hidden dependency on the deleted core.

## State ownership

| State | Owner |
| --- | --- |
| Core lifecycle, traffic, connections, logs | `CoreController` |
| Durable user settings | `SettingsController` |
| Subscription metadata and updates | `SubscriptionsController` |
| Parsed proxy groups | `ProxyCatalog` |
| Page filters and selections | feature controllers |

Controllers currently remain small `ChangeNotifier` state objects, while
Riverpod handles their lifecycle, injection, observation, and test overrides.
This avoids a risky all-at-once rewrite and leaves a straightforward path to
Riverpod `Notifier`/`AsyncNotifier` when Rustbox introduces asynchronous state.

## Rustbox adapter checklist

1. Create a package-specific adapter implementing `CoreGateway`.
2. Map Rustbox values into `CoreSnapshot`, `CoreConnection`, `ProxyGroup`, and
   `LogEntry` at the boundary.
3. Override `coreGatewayProvider` during app bootstrap.
4. Add adapter contract tests; keep widgets unchanged.
