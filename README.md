# LitheNet

LitheNet is a Flutter desktop proxy client UI powered by the separate
`loafman1120/singbox-ffi` native core package.

This repository is the app. It does not build the Go FFI core. The native
`singbox-ffi` binaries are built and released from `loafman1120/singbox-ffi`,
while this Flutter project imports that package's Flutter FFI plugin API.

## Project Layout

```text
lib/        Flutter UI
bin/        Dart smoke runners for the same FFI API
test/       Flutter widget tests
linux/      Linux desktop runner
macos/      macOS desktop runner
windows/    Windows desktop runner
```

LitheNet consumes the published `singbox_ffi` Flutter FFI plugin from pub.dev:

```yaml
singbox_ffi: ^0.1.2
```

## Native Core

Build or download the native libraries from `loafman1120/singbox-ffi`.

Dynamic library artifact names:

```text
Windows: singboxffi.dll
macOS:   libsingboxffi.dylib
Linux:   libsingboxffi.so
```

For Flutter builds, place the native library in the `singbox_ffi` plugin artifact
directory and let Flutter's generated plugin CMake bundle it.

The app loads the bundled plugin core with `SingboxFfi.openBundled()`. It does
not expose process-symbol/static mode in the UI.

GitHub Actions downloads every `singboxffi-*` artifact from the latest
successful `loafman1120/singbox-ffi` Build workflow, including:

- desktop dynamic artifacts
- desktop static artifacts
- Android dynamic artifacts
- Android static artifacts

The LitheNet workflow stages the Windows DLL into the resolved pub cache copy of
`singbox_ffi` before building. The Flutter FFI plugin then contributes it through
`PLUGIN_BUNDLED_LIBRARIES`; LitheNet does not modify Flutter generated CMake.

## Run The App

```powershell
flutter pub get
.\scripts\download_core_desktop.ps1
flutter run -d windows
```

The app validates a sing-box JSON config, starts/stops the local mixed proxy,
and streams service logs through the bundled `singbox_ffi` plugin.

## Run The Dart Smoke Proxy

```powershell
dart pub get
dart run bin\proxy.dart ..\singbox-ffi\build\singboxffi.dll
```

In another terminal:

```powershell
curl.exe -x socks5h://127.0.0.1:2080 https://example.com
```

Press `Ctrl+C` in the Dart process to stop the proxy.

## Verify

```powershell
flutter analyze
flutter test
.\scripts\download_core_desktop.ps1
flutter build windows --debug
```

## License Notice

The `singbox-ffi` native package links against
`github.com/sagernet/sing-box/experimental/libbox`. sing-box is distributed under
the GNU General Public License, version 3 or later, with the additional upstream
naming restriction copied in `LICENSE.sing-box`.

Distributions that embed the native library should carry the corresponding GPL
notice and must not use the sing-box name or imply association with the upstream
application without prior consent.
