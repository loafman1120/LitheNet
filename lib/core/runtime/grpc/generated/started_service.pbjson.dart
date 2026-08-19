// This is a generated file - do not edit.
//
// Generated from started_service.proto.

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

@$core.Deprecated('Use logLevelDescriptor instead')
const LogLevel$json = {
  '1': 'LogLevel',
  '2': [
    {'1': 'PANIC', '2': 0},
    {'1': 'FATAL', '2': 1},
    {'1': 'ERROR', '2': 2},
    {'1': 'WARN', '2': 3},
    {'1': 'INFO', '2': 4},
    {'1': 'DEBUG', '2': 5},
    {'1': 'TRACE', '2': 6},
  ],
};

/// Descriptor for `LogLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List logLevelDescriptor = $convert.base64Decode(
    'CghMb2dMZXZlbBIJCgVQQU5JQxAAEgkKBUZBVEFMEAESCQoFRVJST1IQAhIICgRXQVJOEAMSCA'
    'oESU5GTxAEEgkKBURFQlVHEAUSCQoFVFJBQ0UQBg==');

@$core.Deprecated('Use connectionEventTypeDescriptor instead')
const ConnectionEventType$json = {
  '1': 'ConnectionEventType',
  '2': [
    {'1': 'CONNECTION_EVENT_NEW', '2': 0},
    {'1': 'CONNECTION_EVENT_UPDATE', '2': 1},
    {'1': 'CONNECTION_EVENT_CLOSED', '2': 2},
  ],
};

/// Descriptor for `ConnectionEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List connectionEventTypeDescriptor = $convert.base64Decode(
    'ChNDb25uZWN0aW9uRXZlbnRUeXBlEhgKFENPTk5FQ1RJT05fRVZFTlRfTkVXEAASGwoXQ09OTk'
    'VDVElPTl9FVkVOVF9VUERBVEUQARIbChdDT05ORUNUSU9OX0VWRU5UX0NMT1NFRBAC');

@$core.Deprecated('Use serviceStatusDescriptor instead')
const ServiceStatus$json = {
  '1': 'ServiceStatus',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.daemon.ServiceStatus.Type',
      '10': 'status'
    },
    {'1': 'errorMessage', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
  '4': [ServiceStatus_Type$json],
};

@$core.Deprecated('Use serviceStatusDescriptor instead')
const ServiceStatus_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'IDLE', '2': 0},
    {'1': 'STARTING', '2': 1},
    {'1': 'STARTED', '2': 2},
    {'1': 'STOPPING', '2': 3},
    {'1': 'FATAL', '2': 4},
  ],
};

/// Descriptor for `ServiceStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceStatusDescriptor = $convert.base64Decode(
    'Cg1TZXJ2aWNlU3RhdHVzEjIKBnN0YXR1cxgBIAEoDjIaLmRhZW1vbi5TZXJ2aWNlU3RhdHVzLl'
    'R5cGVSBnN0YXR1cxIiCgxlcnJvck1lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZSJECgRUeXBl'
    'EggKBElETEUQABIMCghTVEFSVElORxABEgsKB1NUQVJURUQQAhIMCghTVE9QUElORxADEgkKBU'
    'ZBVEFMEAQ=');

@$core.Deprecated('Use logDescriptor instead')
const Log$json = {
  '1': 'Log',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.daemon.Log.Message',
      '10': 'messages'
    },
    {'1': 'reset', '3': 2, '4': 1, '5': 8, '10': 'reset'},
  ],
  '3': [Log_Message$json],
};

@$core.Deprecated('Use logDescriptor instead')
const Log_Message$json = {
  '1': 'Message',
  '2': [
    {
      '1': 'level',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.daemon.LogLevel',
      '10': 'level'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Log`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logDescriptor = $convert.base64Decode(
    'CgNMb2cSLwoIbWVzc2FnZXMYASADKAsyEy5kYWVtb24uTG9nLk1lc3NhZ2VSCG1lc3NhZ2VzEh'
    'QKBXJlc2V0GAIgASgIUgVyZXNldBpLCgdNZXNzYWdlEiYKBWxldmVsGAEgASgOMhAuZGFlbW9u'
    'LkxvZ0xldmVsUgVsZXZlbBIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use subscribeStatusRequestDescriptor instead')
const SubscribeStatusRequest$json = {
  '1': 'SubscribeStatusRequest',
  '2': [
    {'1': 'interval', '3': 1, '4': 1, '5': 3, '10': 'interval'},
  ],
};

/// Descriptor for `SubscribeStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeStatusRequestDescriptor =
    $convert.base64Decode(
        'ChZTdWJzY3JpYmVTdGF0dXNSZXF1ZXN0EhoKCGludGVydmFsGAEgASgDUghpbnRlcnZhbA==');

@$core.Deprecated('Use statusDescriptor instead')
const Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'memory', '3': 1, '4': 1, '5': 4, '10': 'memory'},
    {'1': 'goroutines', '3': 2, '4': 1, '5': 5, '10': 'goroutines'},
    {'1': 'connectionsIn', '3': 3, '4': 1, '5': 5, '10': 'connectionsIn'},
    {'1': 'connectionsOut', '3': 4, '4': 1, '5': 5, '10': 'connectionsOut'},
    {'1': 'trafficAvailable', '3': 5, '4': 1, '5': 8, '10': 'trafficAvailable'},
    {'1': 'uplink', '3': 6, '4': 1, '5': 3, '10': 'uplink'},
    {'1': 'downlink', '3': 7, '4': 1, '5': 3, '10': 'downlink'},
    {'1': 'uplinkTotal', '3': 8, '4': 1, '5': 3, '10': 'uplinkTotal'},
    {'1': 'downlinkTotal', '3': 9, '4': 1, '5': 3, '10': 'downlinkTotal'},
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode(
    'CgZTdGF0dXMSFgoGbWVtb3J5GAEgASgEUgZtZW1vcnkSHgoKZ29yb3V0aW5lcxgCIAEoBVIKZ2'
    '9yb3V0aW5lcxIkCg1jb25uZWN0aW9uc0luGAMgASgFUg1jb25uZWN0aW9uc0luEiYKDmNvbm5l'
    'Y3Rpb25zT3V0GAQgASgFUg5jb25uZWN0aW9uc091dBIqChB0cmFmZmljQXZhaWxhYmxlGAUgAS'
    'gIUhB0cmFmZmljQXZhaWxhYmxlEhYKBnVwbGluaxgGIAEoA1IGdXBsaW5rEhoKCGRvd25saW5r'
    'GAcgASgDUghkb3dubGluaxIgCgt1cGxpbmtUb3RhbBgIIAEoA1ILdXBsaW5rVG90YWwSJAoNZG'
    '93bmxpbmtUb3RhbBgJIAEoA1INZG93bmxpbmtUb3RhbA==');

@$core.Deprecated('Use groupsDescriptor instead')
const Groups$json = {
  '1': 'Groups',
  '2': [
    {
      '1': 'group',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.daemon.Group',
      '10': 'group'
    },
  ],
};

/// Descriptor for `Groups`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupsDescriptor = $convert.base64Decode(
    'CgZHcm91cHMSIwoFZ3JvdXAYASADKAsyDS5kYWVtb24uR3JvdXBSBWdyb3Vw');

@$core.Deprecated('Use groupDescriptor instead')
const Group$json = {
  '1': 'Group',
  '2': [
    {'1': 'tag', '3': 1, '4': 1, '5': 9, '10': 'tag'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'selectable', '3': 3, '4': 1, '5': 8, '10': 'selectable'},
    {'1': 'selected', '3': 4, '4': 1, '5': 9, '10': 'selected'},
    {'1': 'isExpand', '3': 5, '4': 1, '5': 8, '10': 'isExpand'},
    {
      '1': 'items',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.daemon.GroupItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode(
    'CgVHcm91cBIQCgN0YWcYASABKAlSA3RhZxISCgR0eXBlGAIgASgJUgR0eXBlEh4KCnNlbGVjdG'
    'FibGUYAyABKAhSCnNlbGVjdGFibGUSGgoIc2VsZWN0ZWQYBCABKAlSCHNlbGVjdGVkEhoKCGlz'
    'RXhwYW5kGAUgASgIUghpc0V4cGFuZBInCgVpdGVtcxgGIAMoCzIRLmRhZW1vbi5Hcm91cEl0ZW'
    '1SBWl0ZW1z');

@$core.Deprecated('Use groupItemDescriptor instead')
const GroupItem$json = {
  '1': 'GroupItem',
  '2': [
    {'1': 'tag', '3': 1, '4': 1, '5': 9, '10': 'tag'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'urlTestTime', '3': 3, '4': 1, '5': 3, '10': 'urlTestTime'},
    {'1': 'urlTestDelay', '3': 4, '4': 1, '5': 5, '10': 'urlTestDelay'},
    {
      '1': 'consecutiveFailures',
      '3': 5,
      '4': 1,
      '5': 13,
      '10': 'consecutiveFailures'
    },
    {'1': 'lastError', '3': 6, '4': 1, '5': 9, '10': 'lastError'},
    {'1': 'lastSuccessTime', '3': 7, '4': 1, '5': 3, '10': 'lastSuccessTime'},
  ],
};

/// Descriptor for `GroupItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupItemDescriptor = $convert.base64Decode(
    'CglHcm91cEl0ZW0SEAoDdGFnGAEgASgJUgN0YWcSEgoEdHlwZRgCIAEoCVIEdHlwZRIgCgt1cm'
    'xUZXN0VGltZRgDIAEoA1ILdXJsVGVzdFRpbWUSIgoMdXJsVGVzdERlbGF5GAQgASgFUgx1cmxU'
    'ZXN0RGVsYXkSMAoTY29uc2VjdXRpdmVGYWlsdXJlcxgFIAEoDVITY29uc2VjdXRpdmVGYWlsdX'
    'JlcxIcCglsYXN0RXJyb3IYBiABKAlSCWxhc3RFcnJvchIoCg9sYXN0U3VjY2Vzc1RpbWUYByAB'
    'KANSD2xhc3RTdWNjZXNzVGltZQ==');

@$core.Deprecated('Use uRLTestRequestDescriptor instead')
const URLTestRequest$json = {
  '1': 'URLTestRequest',
  '2': [
    {'1': 'outboundTag', '3': 1, '4': 1, '5': 9, '10': 'outboundTag'},
  ],
};

/// Descriptor for `URLTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uRLTestRequestDescriptor = $convert.base64Decode(
    'Cg5VUkxUZXN0UmVxdWVzdBIgCgtvdXRib3VuZFRhZxgBIAEoCVILb3V0Ym91bmRUYWc=');

@$core.Deprecated('Use selectOutboundRequestDescriptor instead')
const SelectOutboundRequest$json = {
  '1': 'SelectOutboundRequest',
  '2': [
    {'1': 'groupTag', '3': 1, '4': 1, '5': 9, '10': 'groupTag'},
    {'1': 'outboundTag', '3': 2, '4': 1, '5': 9, '10': 'outboundTag'},
  ],
};

/// Descriptor for `SelectOutboundRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectOutboundRequestDescriptor = $convert.base64Decode(
    'ChVTZWxlY3RPdXRib3VuZFJlcXVlc3QSGgoIZ3JvdXBUYWcYASABKAlSCGdyb3VwVGFnEiAKC2'
    '91dGJvdW5kVGFnGAIgASgJUgtvdXRib3VuZFRhZw==');

@$core.Deprecated('Use subscribeConnectionsRequestDescriptor instead')
const SubscribeConnectionsRequest$json = {
  '1': 'SubscribeConnectionsRequest',
  '2': [
    {'1': 'interval', '3': 1, '4': 1, '5': 3, '10': 'interval'},
  ],
};

/// Descriptor for `SubscribeConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChtTdWJzY3JpYmVDb25uZWN0aW9uc1JlcXVlc3QSGgoIaW50ZXJ2YWwYASABKANSCGludGVydm'
        'Fs');

@$core.Deprecated('Use connectionEventDescriptor instead')
const ConnectionEvent$json = {
  '1': 'ConnectionEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.daemon.ConnectionEventType',
      '10': 'type'
    },
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'connection',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.daemon.Connection',
      '10': 'connection'
    },
    {'1': 'uplinkDelta', '3': 4, '4': 1, '5': 3, '10': 'uplinkDelta'},
    {'1': 'downlinkDelta', '3': 5, '4': 1, '5': 3, '10': 'downlinkDelta'},
    {'1': 'closedAt', '3': 6, '4': 1, '5': 3, '10': 'closedAt'},
  ],
};

/// Descriptor for `ConnectionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionEventDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uRXZlbnQSLwoEdHlwZRgBIAEoDjIbLmRhZW1vbi5Db25uZWN0aW9uRXZlbn'
    'RUeXBlUgR0eXBlEg4KAmlkGAIgASgJUgJpZBIyCgpjb25uZWN0aW9uGAMgASgLMhIuZGFlbW9u'
    'LkNvbm5lY3Rpb25SCmNvbm5lY3Rpb24SIAoLdXBsaW5rRGVsdGEYBCABKANSC3VwbGlua0RlbH'
    'RhEiQKDWRvd25saW5rRGVsdGEYBSABKANSDWRvd25saW5rRGVsdGESGgoIY2xvc2VkQXQYBiAB'
    'KANSCGNsb3NlZEF0');

@$core.Deprecated('Use connectionEventsDescriptor instead')
const ConnectionEvents$json = {
  '1': 'ConnectionEvents',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.daemon.ConnectionEvent',
      '10': 'events'
    },
    {'1': 'reset', '3': 2, '4': 1, '5': 8, '10': 'reset'},
  ],
};

/// Descriptor for `ConnectionEvents`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionEventsDescriptor = $convert.base64Decode(
    'ChBDb25uZWN0aW9uRXZlbnRzEi8KBmV2ZW50cxgBIAMoCzIXLmRhZW1vbi5Db25uZWN0aW9uRX'
    'ZlbnRSBmV2ZW50cxIUCgVyZXNldBgCIAEoCFIFcmVzZXQ=');

@$core.Deprecated('Use connectionDescriptor instead')
const Connection$json = {
  '1': 'Connection',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'inbound', '3': 2, '4': 1, '5': 9, '10': 'inbound'},
    {'1': 'inboundType', '3': 3, '4': 1, '5': 9, '10': 'inboundType'},
    {'1': 'ipVersion', '3': 4, '4': 1, '5': 5, '10': 'ipVersion'},
    {'1': 'network', '3': 5, '4': 1, '5': 9, '10': 'network'},
    {'1': 'source', '3': 6, '4': 1, '5': 9, '10': 'source'},
    {'1': 'destination', '3': 7, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'domain', '3': 8, '4': 1, '5': 9, '10': 'domain'},
    {'1': 'protocol', '3': 9, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'user', '3': 10, '4': 1, '5': 9, '10': 'user'},
    {'1': 'fromOutbound', '3': 11, '4': 1, '5': 9, '10': 'fromOutbound'},
    {'1': 'createdAt', '3': 12, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'closedAt', '3': 13, '4': 1, '5': 3, '10': 'closedAt'},
    {'1': 'uplink', '3': 14, '4': 1, '5': 3, '10': 'uplink'},
    {'1': 'downlink', '3': 15, '4': 1, '5': 3, '10': 'downlink'},
    {'1': 'uplinkTotal', '3': 16, '4': 1, '5': 3, '10': 'uplinkTotal'},
    {'1': 'downlinkTotal', '3': 17, '4': 1, '5': 3, '10': 'downlinkTotal'},
    {'1': 'rule', '3': 18, '4': 1, '5': 9, '10': 'rule'},
    {'1': 'outbound', '3': 19, '4': 1, '5': 9, '10': 'outbound'},
    {'1': 'outboundType', '3': 20, '4': 1, '5': 9, '10': 'outboundType'},
    {'1': 'chainList', '3': 21, '4': 3, '5': 9, '10': 'chainList'},
  ],
};

/// Descriptor for `Connection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionDescriptor = $convert.base64Decode(
    'CgpDb25uZWN0aW9uEg4KAmlkGAEgASgJUgJpZBIYCgdpbmJvdW5kGAIgASgJUgdpbmJvdW5kEi'
    'AKC2luYm91bmRUeXBlGAMgASgJUgtpbmJvdW5kVHlwZRIcCglpcFZlcnNpb24YBCABKAVSCWlw'
    'VmVyc2lvbhIYCgduZXR3b3JrGAUgASgJUgduZXR3b3JrEhYKBnNvdXJjZRgGIAEoCVIGc291cm'
    'NlEiAKC2Rlc3RpbmF0aW9uGAcgASgJUgtkZXN0aW5hdGlvbhIWCgZkb21haW4YCCABKAlSBmRv'
    'bWFpbhIaCghwcm90b2NvbBgJIAEoCVIIcHJvdG9jb2wSEgoEdXNlchgKIAEoCVIEdXNlchIiCg'
    'xmcm9tT3V0Ym91bmQYCyABKAlSDGZyb21PdXRib3VuZBIcCgljcmVhdGVkQXQYDCABKANSCWNy'
    'ZWF0ZWRBdBIaCghjbG9zZWRBdBgNIAEoA1IIY2xvc2VkQXQSFgoGdXBsaW5rGA4gASgDUgZ1cG'
    'xpbmsSGgoIZG93bmxpbmsYDyABKANSCGRvd25saW5rEiAKC3VwbGlua1RvdGFsGBAgASgDUgt1'
    'cGxpbmtUb3RhbBIkCg1kb3dubGlua1RvdGFsGBEgASgDUg1kb3dubGlua1RvdGFsEhIKBHJ1bG'
    'UYEiABKAlSBHJ1bGUSGgoIb3V0Ym91bmQYEyABKAlSCG91dGJvdW5kEiIKDG91dGJvdW5kVHlw'
    'ZRgUIAEoCVIMb3V0Ym91bmRUeXBlEhwKCWNoYWluTGlzdBgVIAMoCVIJY2hhaW5MaXN0');

@$core.Deprecated('Use closeConnectionRequestDescriptor instead')
const CloseConnectionRequest$json = {
  '1': 'CloseConnectionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CloseConnectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeConnectionRequestDescriptor = $convert
    .base64Decode('ChZDbG9zZUNvbm5lY3Rpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');
