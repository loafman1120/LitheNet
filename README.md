# Lithe

Lithe is a Flutter desktop proxy client being migrated to the Rustbox core.
The previous sing-box FFI integration and its build automation have been
removed. Until the Rustbox Dart bridge is ready, the application runs as a UI
and subscription-management shell and reports the core as unavailable.

## Status

- Flutter UI: available
- Settings and subscription persistence: available
- Subscription parsing and proxy catalog: available
- Rustbox native runtime: waiting for the Dart bridge
- GitHub Actions: intentionally removed

## Architecture

The UI uses Riverpod as its composition and state-observation layer. Native
core access is isolated behind `CoreGateway`:

```text
Flutter widgets
  -> Riverpod providers
  -> feature controllers
  -> CoreController
  -> CoreGateway
  -> future Rustbox Dart adapter
```

The future adapter should implement
`lib/core/runtime/core_gateway.dart`. No feature or widget should import a
Rustbox package directly.

## Run

```powershell
flutter pub get
flutter run -d windows
```

## Verify

```powershell
flutter analyze
flutter test
flutter build windows --debug
```

The website is an independent Astro project:

```powershell
pnpm --dir website install
pnpm --dir website check
pnpm --dir website build
```
