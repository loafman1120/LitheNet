# LitheNet Persistence Settings Design

## Scope

This design covers persistence for user-facing settings and closely related
local app state:

- App settings: theme, boot behavior, notifications, proxy mode, listen address,
  mixed port, IPv6, system proxy, per-app proxy.
- Subscription list metadata.
- Parsed subscription profiles used to rebuild the proxy catalog after restart.
- Lightweight migration and recovery behavior for future schema changes.

Runtime-only state stays in memory:

- Current core process/service handle.
- Runtime command-server and API bearer secrets.
- Selected loopback API port.
- Live traffic counters, active connections, and log stream buffers.
- Temporary update progress flags.

## Current Architecture Findings

The app already follows a feature-first Flutter structure:

- `LitheNetApp` creates long-lived app services: `ProxyRepository`,
  `ProxyCatalog`, and `AppRouter`.
- Feature pages create local `ChangeNotifier` controllers in `initState`.
- `SettingsController` currently owns an in-memory `AppSettings`.
- `SettingsPage` reads network values partly from `SettingsController` and
  partly from `ProxyRepository`.
- `Subscription` already has `toJson` and `fromJson`.
- `SubscriptionsController` can import and export subscriptions as JSON, but
  does not save automatically.
- `AtomicProfileStore` exists, but the concrete implementation is currently
  `InMemoryProfileStore`.
- `SingboxProxyRepository` already creates an app directory through the native
  core path, but this is private to the repository and not exposed as a general
  Flutter persistence layer.

The cleanest extension is to add a small app storage layer below controllers and
repositories, then inject long-lived persisted services from `LitheNetApp`.

## Flutter Storage Choice

Use JSON files in the platform application support directory as the primary
store.

Rationale:

- LitheNet targets desktop first and needs inspectable, backup-friendly files.
- Settings and subscriptions are structured data, not only primitive key-value
  pairs.
- Parsed subscription profiles can be larger than a normal preferences entry.
- Atomic writes and explicit schema migrations are easier with files.
- The project currently avoids heavy dependencies and already uses immutable
  model objects with JSON support.

Recommended package:

- `path_provider` for locating the application support directory on Windows,
  macOS, and Linux.

Not recommended as the main store:

- `shared_preferences`: good for small primitive key-value data, but not ideal
  for critical or structured JSON state because writes are asynchronous and the
  package itself does not guarantee durability after a write returns.
- SQLite: useful once we need indexed history, queryable logs, rule databases,
  or large connection/event archives. It is more machinery than current settings
  persistence needs.

## Directory Layout

Use one app-owned root from `getApplicationSupportDirectory()`:

```text
<application-support>/LitheNet/
  settings.json
  core/
  subscriptions.json
  profiles/
    <subscription-id>.json
    <subscription-id>.bak.json
  config/
    generated-singbox.json
  backups/
    settings.<timestamp>.json
    subscriptions.<timestamp>.json
```

Notes:

- Keep the root resolution behind an abstraction so tests can use a temporary
  directory without depending on Flutter plugins.
- Use `core/` as the sing-box `basePath` and `workingPath`, keeping native core
  state with the rest of the app support data instead of `$HOME/.lithenet`.
- `config/generated-singbox.json` is optional in the first implementation. The
  repository can still regenerate config from settings.
- Do not persist logs by default in this phase. Add explicit export later.

## Proposed Code Structure

```text
lib/
  data/
    storage/
      app_storage_paths.dart
      json_file_store.dart
      persistence_exception.dart
  features/
    settings/
      data/
        settings_store.dart
      application/
        settings_controller.dart
    subscriptions/
      data/
        file_profile_store.dart
        subscription_list_store.dart
```

### AppStoragePaths

Responsibilities:

- Resolve the app support directory once.
- Create required subdirectories.
- Expose typed paths for each persisted file.
- Provide a test constructor for a manually supplied root directory.

### JsonFileStore

Responsibilities:

- Read JSON with graceful missing-file behavior.
- Write JSON atomically: write to `*.tmp`, flush, then rename.
- Keep an optional `*.corrupt.<timestamp>` copy when JSON parsing fails.
- Return typed errors for permission, parse, and schema failures.

### SettingsStore

Responsibilities:

- Load `AppSettings` from `settings.json`.
- Save `AppSettings` after every committed controller mutation.
- Apply schema version defaults.

Proposed JSON shape:

```json
{
  "schemaVersion": 1,
  "settings": {
    "themeMode": "system",
    "startOnBoot": false,
    "enableNotifications": true,
    "listenAddress": "127.0.0.1",
    "mixedPort": 2080,
    "proxyMode": "mixed",
    "ipv6": false,
    "systemProxy": true,
    "perAppProxy": false
  }
}
```

### SubscriptionListStore

Responsibilities:

- Load and save the subscription list using existing `Subscription.toJson`.
- Normalize update-only fields on startup if needed.
- Save after add, remove, rename, active switch, and update completion.

Proposed JSON shape:

```json
{
  "schemaVersion": 1,
  "subscriptions": []
}
```

### FileProfileStore

Responsibilities:

- Replace `InMemoryProfileStore` for real app runs.
- Store one parsed profile per subscription ID.
- Use existing `AtomicProfileStore` contract.
- Implement backup and rollback with sibling `.bak.json` files.

The profile model currently comes from `subscription_parser.dart`; if it does
not have JSON methods yet, add `toJson` and `fromJson` there first.

## App Startup Flow

1. `main()` calls an async bootstrap before `runApp`.
2. Bootstrap initializes Flutter bindings and storage paths.
3. Load settings from `SettingsStore`, falling back to defaults on missing file.
4. Create `SettingsController(initialSettings, settingsStore)`.
5. Create `SingboxProxyRepository(initialSettings)` or call a repository hydrate
   method before first build.
6. Create `SubscriptionsController` with `SubscriptionListStore` and
   `DefaultSubscriptionRepository(store: FileProfileStore(...))`.
7. Load subscriptions and current profiles; rebuild `ProxyCatalog` from the
   active profile when available.
8. Render `LitheNetApp` with the long-lived controllers/services injected.

This moves settings ownership from `SettingsPage` to `LitheNetApp`, matching how
`ProxyRepository` and `ProxyCatalog` are already long-lived.

## State Ownership

Settings should have one source of truth:

- `SettingsController` owns durable user settings.
- `ProxyRepository` owns runtime core state.
- When a network setting changes, `SettingsController` persists it and then
  applies the runtime side effect to `ProxyRepository`.

Recommended dependency direction:

```text
SettingsPage
  -> SettingsController
  -> SettingsStore
  -> JsonFileStore

SettingsPage or coordinator
  -> ProxyRepository runtime methods
```

Avoid making `ProxyRepository` depend on Flutter storage. It should receive
initial settings or explicit update calls.

## AppSettings Model Changes

Add JSON serialization to `AppSettings`:

- `Map<String, dynamic> toJson()`
- `factory AppSettings.fromJson(Map<String, dynamic> json)`
- Safe enum parsing helpers with defaults.
- Basic validation:
  - Empty `listenAddress` becomes `127.0.0.1`.
  - Invalid `mixedPort` becomes `2080`.
  - Unknown enum values become current defaults.

Add nullable-aware update methods only if a future setting needs clearing.

## Controller Changes

`SettingsController` should become async-aware:

```dart
class SettingsController extends ChangeNotifier {
  SettingsController({
    required AppSettings initialSettings,
    required SettingsStore store,
  });

  AppSettings get settings;
  bool get saving;
  Object? get lastError;
}
```

Mutation methods should:

1. Optimistically update `_settings`.
2. Notify listeners immediately.
3. Save to disk.
4. Surface `lastError` if saving fails.

For settings that need reconnect warnings, keep the confirmation in UI, then
call the controller method and the repository method after confirmation.

## Repository Changes

Add initialization support to `SingboxProxyRepository`:

```dart
SingboxProxyRepository({
  AppSettings initialSettings = const AppSettings(),
  AppStoragePaths? storagePaths,
  bool demoMode = false,
})
```

or:

```dart
void hydrateSettings(AppSettings settings)
```

The constructor path is preferable because it keeps `_configJson` correct from
the first frame.

Initial fields should come from settings:

- `_systemProxyEnabled`
- `_proxyMode`
- `_listenAddress`
- `_mixedPort`
- `_configJson`

Runtime-only fields should be generated inside the repository:

- `commandSecret` for libbox command support.
- API bearer secret.
- API endpoint port, selected from an available loopback port before service
  start.

Synchronous FFI operations (`loadCore`, config validation, `start`, `reload`)
should update user-visible state and append elapsed-time log entries while they
still run on the UI isolate. Moving them behind a runner/isolate remains the
next architectural step.

API subscription failures should not fabricate production traffic. The
repository reports "API unavailable" and leaves traffic counters at the latest
real values; synthetic traffic is allowed only when `demoMode` is explicitly
enabled.

## Migration Strategy

Use a top-level `schemaVersion` in each persisted file.

Phase 1 only supports version `1`:

- Missing file: return defaults.
- Version `1`: load normally.
- Unknown future version: keep a backup and return defaults with an error.
- Corrupt JSON: rename to a timestamped corrupt file and return defaults with
  an error.

Do not block app launch for settings read failure. Show a diagnostics message in
settings later.

## Testing Plan

Unit tests:

- `AppSettings` JSON round trip and default fallback.
- `JsonFileStore` missing file, corrupt file, and atomic write behavior.
- `SettingsStore` schema loading and invalid field fallback.
- `SubscriptionListStore` save/load round trip.
- `FileProfileStore` backup, replace, current, rollback.

Widget/controller tests:

- `SettingsController` persists each mutation.
- Settings page reflects injected settings instead of recreating defaults.
- Repository starts with persisted endpoint and proxy mode.

Manual verification:

- Change theme, port, proxy mode, and system proxy.
- Quit and relaunch.
- Confirm UI and repository values match saved values.
- Corrupt `settings.json`, launch, and confirm app recovers with defaults.

## Implementation Phases

### Phase 1: Settings Persistence

- Add `path_provider`.
- Add storage path and JSON file helpers.
- Add `AppSettings` JSON serialization.
- Add `SettingsStore`.
- Hoist `SettingsController` to `LitheNetApp`.
- Inject initial settings into `SingboxProxyRepository`.
- Persist settings page changes.

### Phase 2: Subscription List Persistence

- Add `SubscriptionListStore`.
- Load subscriptions on controller startup.
- Save on all subscription mutations and update completion.
- Restore active subscription after restart.

### Phase 3: Profile Persistence

- Add JSON serialization for `ParsedProfile`.
- Add `FileProfileStore`.
- Rebuild `ProxyCatalog` from the active stored profile on startup.
- Keep atomic backup and rollback behavior.

### Phase 4: Recovery and Diagnostics

- Add settings diagnostics UI for storage errors.
- Add export/import backup actions.
- Add schema migration tests before introducing version `2`.
