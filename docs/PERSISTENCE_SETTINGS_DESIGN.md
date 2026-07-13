# Persistence and runtime ownership

Lithe stores settings, subscription metadata, and parsed profiles as JSON in
the platform application-support directory. Runtime-only data such as traffic,
connections, logs, and native handles stays in memory.

## Ownership

- `SettingsController` owns and persists `AppSettings`.
- `SubscriptionsController` owns subscription metadata.
- `FileProfileStore` owns parsed subscription profiles.
- `CoreController` owns runtime state and forwards settings to `CoreGateway`.

Riverpod provides these long-lived objects from the application composition
root. Persistence classes do not depend on Riverpod or Flutter widgets.

## Rustbox integration

The future Rustbox adapter receives settings through
`CoreGateway.configure(AppSettings)`. It must not own settings persistence.
Core-specific caches and files may live under the existing application-support
`core/` directory, but their format belongs to the adapter.

## Migration policy

Persisted JSON keeps a top-level `schemaVersion`. Missing files use defaults;
corrupt files are preserved for diagnostics; unknown future versions fail
safely without blocking application startup.
