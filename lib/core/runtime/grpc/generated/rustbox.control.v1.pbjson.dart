// This is a generated file - do not edit.
//
// Generated from rustbox.control.v1.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use connectionStateDescriptor instead')
const ConnectionState$json = {
  '1': 'ConnectionState',
  '2': [
    {'1': 'CONNECTION_STATE_UNSPECIFIED', '2': 0},
    {'1': 'CONNECTION_STATE_ACTIVE', '2': 1},
    {'1': 'CONNECTION_STATE_COMPLETED', '2': 2},
    {'1': 'CONNECTION_STATE_FAILED', '2': 3},
  ],
};

/// Descriptor for `ConnectionState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List connectionStateDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uU3RhdGUSIAocQ09OTkVDVElPTl9TVEFURV9VTlNQRUNJRklFRBAAEhsKF0'
    'NPTk5FQ1RJT05fU1RBVEVfQUNUSVZFEAESHgoaQ09OTkVDVElPTl9TVEFURV9DT01QTEVURUQQ'
    'AhIbChdDT05ORUNUSU9OX1NUQVRFX0ZBSUxFRBAD');

@$core.Deprecated('Use engineStateDescriptor instead')
const EngineState$json = {
  '1': 'EngineState',
  '2': [
    {'1': 'ENGINE_STATE_UNSPECIFIED', '2': 0},
    {'1': 'ENGINE_STATE_CREATED', '2': 1},
    {'1': 'ENGINE_STATE_PREPARED', '2': 2},
    {'1': 'ENGINE_STATE_RUNNING', '2': 3},
    {'1': 'ENGINE_STATE_STOPPING', '2': 4},
    {'1': 'ENGINE_STATE_STOPPED', '2': 5},
    {'1': 'ENGINE_STATE_FAILED', '2': 6},
  ],
};

/// Descriptor for `EngineState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List engineStateDescriptor = $convert.base64Decode(
    'CgtFbmdpbmVTdGF0ZRIcChhFTkdJTkVfU1RBVEVfVU5TUEVDSUZJRUQQABIYChRFTkdJTkVfU1'
    'RBVEVfQ1JFQVRFRBABEhkKFUVOR0lORV9TVEFURV9QUkVQQVJFRBACEhgKFEVOR0lORV9TVEFU'
    'RV9SVU5OSU5HEAMSGQoVRU5HSU5FX1NUQVRFX1NUT1BQSU5HEAQSGAoURU5HSU5FX1NUQVRFX1'
    'NUT1BQRUQQBRIXChNFTkdJTkVfU1RBVEVfRkFJTEVEEAY=');

@$core.Deprecated('Use getMetricsRequestDescriptor instead')
const GetMetricsRequest$json = {
  '1': 'GetMetricsRequest',
};

/// Descriptor for `GetMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricsRequestDescriptor =
    $convert.base64Decode('ChFHZXRNZXRyaWNzUmVxdWVzdA==');

@$core.Deprecated('Use listConnectionsRequestDescriptor instead')
const ListConnectionsRequest$json = {
  '1': 'ListConnectionsRequest',
};

/// Descriptor for `ListConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConnectionsRequestDescriptor =
    $convert.base64Decode('ChZMaXN0Q29ubmVjdGlvbnNSZXF1ZXN0');

@$core.Deprecated('Use getObservabilitySnapshotRequestDescriptor instead')
const GetObservabilitySnapshotRequest$json = {
  '1': 'GetObservabilitySnapshotRequest',
};

/// Descriptor for `GetObservabilitySnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getObservabilitySnapshotRequestDescriptor =
    $convert.base64Decode('Ch9HZXRPYnNlcnZhYmlsaXR5U25hcHNob3RSZXF1ZXN0');

@$core.Deprecated('Use getEngineSnapshotRequestDescriptor instead')
const GetEngineSnapshotRequest$json = {
  '1': 'GetEngineSnapshotRequest',
};

/// Descriptor for `GetEngineSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEngineSnapshotRequestDescriptor =
    $convert.base64Decode('ChhHZXRFbmdpbmVTbmFwc2hvdFJlcXVlc3Q=');

@$core.Deprecated('Use stopRequestDescriptor instead')
const StopRequest$json = {
  '1': 'StopRequest',
};

/// Descriptor for `StopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopRequestDescriptor =
    $convert.base64Decode('CgtTdG9wUmVxdWVzdA==');

@$core.Deprecated('Use queryEventsRequestDescriptor instead')
const QueryEventsRequest$json = {
  '1': 'QueryEventsRequest',
  '2': [
    {'1': 'min_level', '3': 1, '4': 1, '5': 9, '10': 'minLevel'},
    {'1': 'target_prefix', '3': 2, '4': 1, '5': 9, '10': 'targetPrefix'},
    {'1': 'flow_id', '3': 3, '4': 1, '5': 4, '10': 'flowId'},
    {'1': 'limit', '3': 4, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `QueryEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryEventsRequestDescriptor = $convert.base64Decode(
    'ChJRdWVyeUV2ZW50c1JlcXVlc3QSGwoJbWluX2xldmVsGAEgASgJUghtaW5MZXZlbBIjCg10YX'
    'JnZXRfcHJlZml4GAIgASgJUgx0YXJnZXRQcmVmaXgSFwoHZmxvd19pZBgDIAEoBFIGZmxvd0lk'
    'EhQKBWxpbWl0GAQgASgNUgVsaW1pdA==');

@$core.Deprecated('Use metricsSnapshotDescriptor instead')
const MetricsSnapshot$json = {
  '1': 'MetricsSnapshot',
  '2': [
    {'1': 'services_started', '3': 1, '4': 1, '5': 4, '10': 'servicesStarted'},
    {'1': 'services_stopped', '3': 2, '4': 1, '5': 4, '10': 'servicesStopped'},
    {
      '1': 'connections_accepted',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'connectionsAccepted'
    },
    {'1': 'flows_accepted', '3': 4, '4': 1, '5': 4, '10': 'flowsAccepted'},
    {'1': 'flows_active', '3': 5, '4': 1, '5': 4, '10': 'flowsActive'},
    {'1': 'flows_completed', '3': 6, '4': 1, '5': 4, '10': 'flowsCompleted'},
    {'1': 'flows_failed', '3': 7, '4': 1, '5': 4, '10': 'flowsFailed'},
    {'1': 'routes_selected', '3': 8, '4': 1, '5': 4, '10': 'routesSelected'},
    {
      '1': 'outbound_connect_attempts',
      '3': 9,
      '4': 1,
      '5': 4,
      '10': 'outboundConnectAttempts'
    },
    {
      '1': 'outbound_connect_successes',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'outboundConnectSuccesses'
    },
    {
      '1': 'outbound_connect_failures',
      '3': 11,
      '4': 1,
      '5': 4,
      '10': 'outboundConnectFailures'
    },
    {
      '1': 'inbound_to_outbound_bytes',
      '3': 12,
      '4': 1,
      '5': 4,
      '10': 'inboundToOutboundBytes'
    },
    {
      '1': 'outbound_to_inbound_bytes',
      '3': 13,
      '4': 1,
      '5': 4,
      '10': 'outboundToInboundBytes'
    },
    {'1': 'diagnostics', '3': 14, '4': 1, '5': 4, '10': 'diagnostics'},
  ],
};

/// Descriptor for `MetricsSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricsSnapshotDescriptor = $convert.base64Decode(
    'Cg9NZXRyaWNzU25hcHNob3QSKQoQc2VydmljZXNfc3RhcnRlZBgBIAEoBFIPc2VydmljZXNTdG'
    'FydGVkEikKEHNlcnZpY2VzX3N0b3BwZWQYAiABKARSD3NlcnZpY2VzU3RvcHBlZBIxChRjb25u'
    'ZWN0aW9uc19hY2NlcHRlZBgDIAEoBFITY29ubmVjdGlvbnNBY2NlcHRlZBIlCg5mbG93c19hY2'
    'NlcHRlZBgEIAEoBFINZmxvd3NBY2NlcHRlZBIhCgxmbG93c19hY3RpdmUYBSABKARSC2Zsb3dz'
    'QWN0aXZlEicKD2Zsb3dzX2NvbXBsZXRlZBgGIAEoBFIOZmxvd3NDb21wbGV0ZWQSIQoMZmxvd3'
    'NfZmFpbGVkGAcgASgEUgtmbG93c0ZhaWxlZBInCg9yb3V0ZXNfc2VsZWN0ZWQYCCABKARSDnJv'
    'dXRlc1NlbGVjdGVkEjoKGW91dGJvdW5kX2Nvbm5lY3RfYXR0ZW1wdHMYCSABKARSF291dGJvdW'
    '5kQ29ubmVjdEF0dGVtcHRzEjwKGm91dGJvdW5kX2Nvbm5lY3Rfc3VjY2Vzc2VzGAogASgEUhhv'
    'dXRib3VuZENvbm5lY3RTdWNjZXNzZXMSOgoZb3V0Ym91bmRfY29ubmVjdF9mYWlsdXJlcxgLIA'
    'EoBFIXb3V0Ym91bmRDb25uZWN0RmFpbHVyZXMSOQoZaW5ib3VuZF90b19vdXRib3VuZF9ieXRl'
    'cxgMIAEoBFIWaW5ib3VuZFRvT3V0Ym91bmRCeXRlcxI5ChlvdXRib3VuZF90b19pbmJvdW5kX2'
    'J5dGVzGA0gASgEUhZvdXRib3VuZFRvSW5ib3VuZEJ5dGVzEiAKC2RpYWdub3N0aWNzGA4gASgE'
    'UgtkaWFnbm9zdGljcw==');

@$core.Deprecated('Use connectionStatsDescriptor instead')
const ConnectionStats$json = {
  '1': 'ConnectionStats',
  '2': [
    {'1': 'flow_id', '3': 1, '4': 1, '5': 4, '10': 'flowId'},
    {'1': 'source', '3': 2, '4': 1, '5': 9, '10': 'source'},
    {'1': 'destination', '3': 3, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'network', '3': 4, '4': 1, '5': 9, '10': 'network'},
    {
      '1': 'state',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.rustbox.control.v1.ConnectionState',
      '10': 'state'
    },
    {
      '1': 'inbound_to_outbound_bytes',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'inboundToOutboundBytes'
    },
    {
      '1': 'outbound_to_inbound_bytes',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'outboundToInboundBytes'
    },
    {'1': 'outcome', '3': 8, '4': 1, '5': 9, '10': 'outcome'},
    {'1': 'error', '3': 9, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ConnectionStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionStatsDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uU3RhdHMSFwoHZmxvd19pZBgBIAEoBFIGZmxvd0lkEhYKBnNvdXJjZRgCIA'
    'EoCVIGc291cmNlEiAKC2Rlc3RpbmF0aW9uGAMgASgJUgtkZXN0aW5hdGlvbhIYCgduZXR3b3Jr'
    'GAQgASgJUgduZXR3b3JrEjkKBXN0YXRlGAUgASgOMiMucnVzdGJveC5jb250cm9sLnYxLkNvbm'
    '5lY3Rpb25TdGF0ZVIFc3RhdGUSOQoZaW5ib3VuZF90b19vdXRib3VuZF9ieXRlcxgGIAEoBFIW'
    'aW5ib3VuZFRvT3V0Ym91bmRCeXRlcxI5ChlvdXRib3VuZF90b19pbmJvdW5kX2J5dGVzGAcgAS'
    'gEUhZvdXRib3VuZFRvSW5ib3VuZEJ5dGVzEhgKB291dGNvbWUYCCABKAlSB291dGNvbWUSFAoF'
    'ZXJyb3IYCSABKAlSBWVycm9y');

@$core.Deprecated('Use eventDescriptor instead')
const Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'level', '3': 1, '4': 1, '5': 9, '10': 'level'},
    {'1': 'target', '3': 2, '4': 1, '5': 9, '10': 'target'},
    {'1': 'flow_id', '3': 3, '4': 1, '5': 4, '10': 'flowId'},
    {'1': 'kind', '3': 4, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'attributes',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.rustbox.control.v1.Event.AttributesEntry',
      '10': 'attributes'
    },
  ],
  '3': [Event_AttributesEntry$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_AttributesEntry$json = {
  '1': 'AttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBIUCgVsZXZlbBgBIAEoCVIFbGV2ZWwSFgoGdGFyZ2V0GAIgASgJUgZ0YXJnZXQSFw'
    'oHZmxvd19pZBgDIAEoBFIGZmxvd0lkEhIKBGtpbmQYBCABKAlSBGtpbmQSGAoHbWVzc2FnZRgF'
    'IAEoCVIHbWVzc2FnZRJJCgphdHRyaWJ1dGVzGAYgAygLMikucnVzdGJveC5jb250cm9sLnYxLk'
    'V2ZW50LkF0dHJpYnV0ZXNFbnRyeVIKYXR0cmlidXRlcxo9Cg9BdHRyaWJ1dGVzRW50cnkSEAoD'
    'a2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use listConnectionsResponseDescriptor instead')
const ListConnectionsResponse$json = {
  '1': 'ListConnectionsResponse',
  '2': [
    {
      '1': 'connections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.rustbox.control.v1.ConnectionStats',
      '10': 'connections'
    },
  ],
};

/// Descriptor for `ListConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConnectionsResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0Q29ubmVjdGlvbnNSZXNwb25zZRJFCgtjb25uZWN0aW9ucxgBIAMoCzIjLnJ1c3Rib3'
        'guY29udHJvbC52MS5Db25uZWN0aW9uU3RhdHNSC2Nvbm5lY3Rpb25z');

@$core.Deprecated('Use queryEventsResponseDescriptor instead')
const QueryEventsResponse$json = {
  '1': 'QueryEventsResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.rustbox.control.v1.Event',
      '10': 'events'
    },
  ],
};

/// Descriptor for `QueryEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryEventsResponseDescriptor = $convert.base64Decode(
    'ChNRdWVyeUV2ZW50c1Jlc3BvbnNlEjEKBmV2ZW50cxgBIAMoCzIZLnJ1c3Rib3guY29udHJvbC'
    '52MS5FdmVudFIGZXZlbnRz');

@$core.Deprecated('Use observabilitySnapshotDescriptor instead')
const ObservabilitySnapshot$json = {
  '1': 'ObservabilitySnapshot',
  '2': [
    {
      '1': 'metrics',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.rustbox.control.v1.MetricsSnapshot',
      '10': 'metrics'
    },
    {
      '1': 'connections',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.rustbox.control.v1.ConnectionStats',
      '10': 'connections'
    },
    {
      '1': 'recent_events',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.rustbox.control.v1.Event',
      '10': 'recentEvents'
    },
  ],
};

/// Descriptor for `ObservabilitySnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List observabilitySnapshotDescriptor = $convert.base64Decode(
    'ChVPYnNlcnZhYmlsaXR5U25hcHNob3QSPQoHbWV0cmljcxgBIAEoCzIjLnJ1c3Rib3guY29udH'
    'JvbC52MS5NZXRyaWNzU25hcHNob3RSB21ldHJpY3MSRQoLY29ubmVjdGlvbnMYAiADKAsyIy5y'
    'dXN0Ym94LmNvbnRyb2wudjEuQ29ubmVjdGlvblN0YXRzUgtjb25uZWN0aW9ucxI+Cg1yZWNlbn'
    'RfZXZlbnRzGAMgAygLMhkucnVzdGJveC5jb250cm9sLnYxLkV2ZW50UgxyZWNlbnRFdmVudHM=');

@$core.Deprecated('Use engineSnapshotDescriptor instead')
const EngineSnapshot$json = {
  '1': 'EngineSnapshot',
  '2': [
    {
      '1': 'state',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.rustbox.control.v1.EngineState',
      '10': 'state'
    },
    {'1': 'generation', '3': 2, '4': 1, '5': 4, '10': 'generation'},
    {'1': 'inbound_count', '3': 3, '4': 1, '5': 4, '10': 'inboundCount'},
    {'1': 'outbound_count', '3': 4, '4': 1, '5': 4, '10': 'outboundCount'},
  ],
};

/// Descriptor for `EngineSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List engineSnapshotDescriptor = $convert.base64Decode(
    'Cg5FbmdpbmVTbmFwc2hvdBI1CgVzdGF0ZRgBIAEoDjIfLnJ1c3Rib3guY29udHJvbC52MS5Fbm'
    'dpbmVTdGF0ZVIFc3RhdGUSHgoKZ2VuZXJhdGlvbhgCIAEoBFIKZ2VuZXJhdGlvbhIjCg1pbmJv'
    'dW5kX2NvdW50GAMgASgEUgxpbmJvdW5kQ291bnQSJQoOb3V0Ym91bmRfY291bnQYBCABKARSDW'
    '91dGJvdW5kQ291bnQ=');
