# Lithe Architecture

## Design goals

1. Keep Flutter UI independent from the native core implementation.
2. Keep one observable source of truth for each feature.
3. Make runtime dependencies replaceable in tests and at app startup.
4. Keep the Libbox FFI and command-server boundary replaceable.

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

`CoreGateway` is the only contract the Libbox integration needs to implement.
It exposes lifecycle operations and a stream of immutable `CoreSnapshot`
values. `CoreController` converts that stream into UI-observable state and
owns error/busy handling.

`LibboxGateway` initializes Libbox without blocking Flutter's UI isolate. It
maps authenticated command-server streams for status, connections, logs, and
outbound groups into `CoreSnapshot` values.

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
This keeps the runtime transport asynchronous while leaving a straightforward
path to Riverpod `Notifier`/`AsyncNotifier` later.

## Libbox runtime contract

The desktop app initializes Libbox with an ephemeral loopback gRPC port and a
random `x-command-secret`. The generated `daemon.StartedService` protobuf
surface remains below `lib/core/runtime/grpc`.
