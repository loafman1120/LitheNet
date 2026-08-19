# Flutter dependencies and Libbox frontend gaps

## Dependency roles

Dependencies should be introduced at the layer that owns the capability. UI
packages must not leak into subscription parsing or the Libbox gateway.

| Package | Owner | Purpose |
| --- | --- | --- |
| `lottie` | presentation | Render local `.json` or `.lottie` state animations. Assets should be bundled with the app and carry a source/license manifest. |
| `flutter_svg` | presentation/core widgets | Render official SVG logos and product/protocol marks. Prefer Flutter Material icons for generic actions. |
| `yaml` | subscriptions data | Parse Clash YAML structurally instead of relying on line order and regular expressions. |
| `crypto` | subscriptions data | Produce stable SHA-256 profile and node fingerprints. It must not be used as a password-storage primitive. |
| `package_info_plus` | app/platform | Read the packaged app version instead of duplicating it in widgets. |

No animation or icon assets are included yet. UI code should later expose them
through one asset catalog rather than referring to paths from feature pages.

## Current Libbox surface

Lithe uses the Libbox FFI package for native lifecycle and its command-server
gRPC API for status, connections, groups, commands, and real-time logs.

## P0: configuration contract and validation

Libbox consumes sing-box JSON configuration:

The adapter validates this JSON through `libbox_check_config` before starting
or reloading the service.

Remaining frontend requirements:

- Expose structured config diagnostics from `libbox_check_config`.
- Add atomic `ApplyConfig`/`ReloadConfig` with a request id, expected generation,
  resulting generation, and whether a restart was required.
- Return the active configuration fingerprint and generation in every runtime
  snapshot so Flutter can distinguish saved, pending, and applied settings.
- Keep secrets out of diagnostics and snapshots.

Suggested shape:

```proto
rpc ValidateConfig(ValidateConfigRequest) returns (ValidateConfigResponse);
rpc ApplyConfig(ApplyConfigRequest) returns (ApplyConfigResponse);

message Diagnostic {
  string code = 1;
  string severity = 2;
  string path = 3;
  string message = 4;
}
```

## P0: observable state stream

- Replace one-second Flutter polling with a server-streaming `WatchRuntime`
  endpoint carrying monotonically increasing sequence and generation values.
- Include lifecycle, traffic totals/rates, active connections, group changes,
  and bounded event/log batches.
- Support resume from `after_sequence`; signal explicitly when the client must
  request a full snapshot.
- Publish a capabilities/version handshake before Flutter enables controls.

The stream should be authoritative. Flutter should not merge a separate UI
proxy catalog with runtime groups after the engine starts.

## P1: frontend commands

- `CloseConnection(flow_id)` and optionally `CloseAllConnections`.
- `TriggerUrlTest(group_tag)` is now wired through the Flutter gateway. It
  schedules the runtime URLTest and waits for `SubscribeGroups` to publish a
  newer test timestamp before returning the measured delay. A future per-node
  command could still expose a custom URL, timeout, and structured failure code.
- `SetRoutingMode(rule/global/direct)` as a runtime command or a documented
  configuration transaction.
- `GetGroups` plus `WatchGroups`; selection responses should return the selected
  outbound and resulting generation rather than an empty response.
- `QueryEvents` with cursor/time range and `ClearEvents` semantics defined per
  client versus globally.

## P1: platform integration status

Expose observable results for operations owned by Libbox or its privileged
helper:

- TUN availability and permission state;
- system-proxy applied/restored state;
- DNS/listener bind failures with the conflicting address/port;
- required restart and privilege elevation;
- unexpected exit/crash summary and a safe diagnostic bundle.

Flutter should receive stable error codes and parameters. Display strings can
then be localized in the app instead of parsing Rust error text.

## P2: compatibility and testing

- Add `GetCapabilities` with API semver, Libbox version, supported RPCs,
  supported inbound/outbound types, and platform features.
- Keep protobuf field additions backward compatible and define a minimum
  supported frontend API version.
- Publish a fake/in-memory frontend service so Flutter integration tests can
  exercise streams, reconnects, stale generations, and command failures without
  launching the real sidecar.
- Run contract tests against an in-memory and sidecar gRPC implementation.

## Recommended implementation order

1. Capabilities handshake and structured diagnostics.
2. Validate/apply configuration with generation control.
3. Unified runtime stream.
4. Groups, latency testing, and connection commands.
5. Platform helper status and diagnostic bundle.
6. In-memory/sidecar contract tests.
