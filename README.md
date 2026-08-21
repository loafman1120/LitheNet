# Target

Target is a Flutter desktop proxy client backed by Libbox. It initializes the
Libbox native library and uses its authenticated loopback gRPC command server
for runtime state, commands, and logs.

## Status

- Flutter UI: available
- Settings and subscription persistence: available
- Subscription parsing and proxy catalog: available
- Libbox runtime lifecycle: available through FFI and gRPC
- Runtime metrics, connections, events, and outbound groups: available
- Active URLTest triggering and refreshed latency results: available
- Libbox logs: streamed through the authenticated gRPC command server
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
  -> Libbox FFI and gRPC adapter
```

`CoreGateway` keeps widgets independent from generated protobuf and process
management code. Put the platform native library (`libbox.dll`, `libbox.so`, or
`libbox.dylib`) beside the application or under `bin/`, or set
`LIBBOX_LIBRARY` to an explicit path.

During local development, a sibling checkout at `../libbox/build` is also
searched automatically.

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
