# Lithe

Lithe is a Flutter desktop proxy client UI powered by the separate
`loafman1120/singbox-ffi` native core package.

The Dart package and executable remain `lithenet` for compatibility with
existing imports, scripts, and build outputs. Platform app identifiers use
`top.loafman.lithe`, and the website is `https://lithe.loafman.top`.

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

Lithe consumes the published `singbox_ffi` Flutter FFI plugin from pub.dev:

```yaml
singbox_ffi: ^0.1.6
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

Runtime paths and local API behavior:

- Settings live under the platform application support directory in
  `Lithe/settings.json`.
- The sing-box core `basePath` and `workingPath` use
  `Lithe/core/` under the same application support root.
- Temporary files use the system temp directory under `lithenet/`.
- Existing `LitheNet`, `.lithenet`, and early `com.example/lithenet/LitheNet`
  support directories are copied forward when files are missing.
- The local sing-box API listens only on loopback and gets an available port at
  service start instead of assuming `9090`.
- The command server and API bearer secrets are generated per app process and
  kept in memory only.
- API failures surface as unavailable statistics; synthetic traffic is disabled
  unless a repository is explicitly created in demo mode.

GitHub Actions downloads every `singboxffi-*` artifact from the latest
successful `loafman1120/singbox-ffi` Build workflow, including:

- desktop dynamic artifacts
- desktop static artifacts
- Android dynamic artifacts
- Android static artifacts

The Lithe workflow stages the Windows DLL into the resolved pub cache copy of
`singbox_ffi` before building. The Flutter FFI plugin then contributes it through
`PLUGIN_BUNDLED_LIBRARIES`; Lithe does not modify Flutter generated CMake.

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
