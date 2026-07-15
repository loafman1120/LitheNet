# Lithe

Lithe is a Flutter desktop proxy client backed by RustBox. It starts the
`rustbox-app` sidecar asynchronously and uses RustBox's authenticated loopback
gRPC control API for runtime state and commands.

## Status

- Flutter UI: available
- Settings and subscription persistence: available
- Subscription parsing and proxy catalog: available
- RustBox runtime lifecycle: available through gRPC
- Runtime metrics, connections, events, and outbound groups: available
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
  -> RustBox gRPC adapter
```

`CoreGateway` keeps widgets independent from generated protobuf and process
management code. Put `rustbox-app.exe` beside LitheNet or under `bin/`, or set
`LITHENET_RUSTBOX_BIN` to an explicit development binary.

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
