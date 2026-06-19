# LitheNet

LitheNet is a Flutter GUI proxy client that consumes prebuilt `singbox-ffi`
shared-library artifacts. The app does not compile Go and does not link static
archives directly.

## Architecture

- `loafman1120/singbox-ffi` builds and publishes native core artifacts.
- `loafman1120/LitheNet` builds the Flutter UI.
- LitheNet v1 loads the shared native core with Dart FFI.
- Static `singbox-ffi` archives are not exposed in the UI until a dedicated
  Flutter platform package or native-assets integration exists.

## Get The Core

Download the latest successful Windows shared artifact from `singbox-ffi`:

```powershell
pwsh scripts/download_core_windows.ps1
```

The script places the DLL at:

```text
native/windows/singboxffi.dll
```

## Run

```powershell
flutter create --platforms windows .
flutter pub get
flutter run -d windows
```

The first screen starts and stops a local mixed proxy on `127.0.0.1:2080`.

Test it from another terminal while the proxy is running:

```powershell
curl.exe -x socks5h://127.0.0.1:2080 https://example.com
```

## Static Linking Policy

LitheNet does not use static mode in v1. Static artifacts from `singbox-ffi` are
for future integration work only. Do not add CMake, Gradle, or runner-level
static archive linking to this repository. When static mode becomes product
ready, it should arrive through a reusable package such as `singbox_ffi_flutter`
or a native-assets integration.
