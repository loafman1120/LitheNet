// This is a generated file - do not edit.
//
// Generated from libbox/v1/manager.proto.

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

@$core.Deprecated('Use serviceStateTypeDescriptor instead')
const ServiceStateType$json = {
  '1': 'ServiceStateType',
  '2': [
    {'1': 'SERVICE_STATE_UNSPECIFIED', '2': 0},
    {'1': 'SERVICE_STATE_IDLE', '2': 1},
    {'1': 'SERVICE_STATE_STARTING', '2': 2},
    {'1': 'SERVICE_STATE_RUNNING', '2': 3},
    {'1': 'SERVICE_STATE_STOPPING', '2': 4},
    {'1': 'SERVICE_STATE_FAILED', '2': 5},
  ],
};

/// Descriptor for `ServiceStateType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List serviceStateTypeDescriptor = $convert.base64Decode(
    'ChBTZXJ2aWNlU3RhdGVUeXBlEh0KGVNFUlZJQ0VfU1RBVEVfVU5TUEVDSUZJRUQQABIWChJTRV'
    'JWSUNFX1NUQVRFX0lETEUQARIaChZTRVJWSUNFX1NUQVRFX1NUQVJUSU5HEAISGQoVU0VSVklD'
    'RV9TVEFURV9SVU5OSU5HEAMSGgoWU0VSVklDRV9TVEFURV9TVE9QUElORxAEEhgKFFNFUlZJQ0'
    'VfU1RBVEVfRkFJTEVEEAU=');

@$core.Deprecated('Use versionResponseDescriptor instead')
const VersionResponse$json = {
  '1': 'VersionResponse',
  '2': [
    {'1': 'libbox_version', '3': 1, '4': 1, '5': 9, '10': 'libboxVersion'},
    {'1': 'sing_box_version', '3': 2, '4': 1, '5': 9, '10': 'singBoxVersion'},
    {'1': 'go_version', '3': 3, '4': 1, '5': 9, '10': 'goVersion'},
    {'1': 'protocol_version', '3': 4, '4': 1, '5': 13, '10': 'protocolVersion'},
  ],
};

/// Descriptor for `VersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionResponseDescriptor = $convert.base64Decode(
    'Cg9WZXJzaW9uUmVzcG9uc2USJQoObGliYm94X3ZlcnNpb24YASABKAlSDWxpYmJveFZlcnNpb2'
    '4SKAoQc2luZ19ib3hfdmVyc2lvbhgCIAEoCVIOc2luZ0JveFZlcnNpb24SHQoKZ29fdmVyc2lv'
    'bhgDIAEoCVIJZ29WZXJzaW9uEikKEHByb3RvY29sX3ZlcnNpb24YBCABKA1SD3Byb3RvY29sVm'
    'Vyc2lvbg==');

@$core.Deprecated('Use capabilitiesResponseDescriptor instead')
const CapabilitiesResponse$json = {
  '1': 'CapabilitiesResponse',
  '2': [
    {'1': 'platform', '3': 1, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'platform_vpn', '3': 3, '4': 1, '5': 8, '10': 'platformVpn'},
  ],
  '9': [
    {'1': 2, '2': 3},
    {'1': 4, '2': 5},
  ],
  '10': ['system_proxy'],
};

/// Descriptor for `CapabilitiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capabilitiesResponseDescriptor = $convert.base64Decode(
    'ChRDYXBhYmlsaXRpZXNSZXNwb25zZRIaCghwbGF0Zm9ybRgBIAEoCVIIcGxhdGZvcm0SIQoMcG'
    'xhdGZvcm1fdnBuGAMgASgIUgtwbGF0Zm9ybVZwbkoECAIQA0oECAQQBVIMc3lzdGVtX3Byb3h5');

@$core.Deprecated('Use configRequestDescriptor instead')
const ConfigRequest$json = {
  '1': 'ConfigRequest',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `ConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configRequestDescriptor = $convert
    .base64Decode('Cg1Db25maWdSZXF1ZXN0EhgKB2NvbnRlbnQYASABKAlSB2NvbnRlbnQ=');

@$core.Deprecated('Use checkConfigResponseDescriptor instead')
const CheckConfigResponse$json = {
  '1': 'CheckConfigResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {'1': 'formatted_error', '3': 2, '4': 1, '5': 9, '10': 'formattedError'},
  ],
};

/// Descriptor for `CheckConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkConfigResponseDescriptor = $convert.base64Decode(
    'ChNDaGVja0NvbmZpZ1Jlc3BvbnNlEhQKBXZhbGlkGAEgASgIUgV2YWxpZBInCg9mb3JtYXR0ZW'
    'RfZXJyb3IYAiABKAlSDmZvcm1hdHRlZEVycm9y');

@$core.Deprecated('Use startRequestDescriptor instead')
const StartRequest$json = {
  '1': 'StartRequest',
  '2': [
    {'1': 'config', '3': 1, '4': 1, '5': 9, '10': 'config'},
  ],
};

/// Descriptor for `StartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startRequestDescriptor = $convert
    .base64Decode('CgxTdGFydFJlcXVlc3QSFgoGY29uZmlnGAEgASgJUgZjb25maWc=');

@$core.Deprecated('Use reloadRequestDescriptor instead')
const ReloadRequest$json = {
  '1': 'ReloadRequest',
  '2': [
    {'1': 'config', '3': 1, '4': 1, '5': 9, '10': 'config'},
  ],
};

/// Descriptor for `ReloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reloadRequestDescriptor = $convert
    .base64Decode('Cg1SZWxvYWRSZXF1ZXN0EhYKBmNvbmZpZxgBIAEoCVIGY29uZmln');

@$core.Deprecated('Use restartRequestDescriptor instead')
const RestartRequest$json = {
  '1': 'RestartRequest',
  '2': [
    {'1': 'config', '3': 1, '4': 1, '5': 9, '10': 'config'},
  ],
};

/// Descriptor for `RestartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartRequestDescriptor = $convert
    .base64Decode('Cg5SZXN0YXJ0UmVxdWVzdBIWCgZjb25maWcYASABKAlSBmNvbmZpZw==');

@$core.Deprecated('Use operationResponseDescriptor instead')
const OperationResponse$json = {
  '1': 'OperationResponse',
  '2': [
    {
      '1': 'state',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.libbox.v1.ServiceState',
      '10': 'state'
    },
  ],
};

/// Descriptor for `OperationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationResponseDescriptor = $convert.base64Decode(
    'ChFPcGVyYXRpb25SZXNwb25zZRItCgVzdGF0ZRgBIAEoCzIXLmxpYmJveC52MS5TZXJ2aWNlU3'
    'RhdGVSBXN0YXRl');

@$core.Deprecated('Use serviceStateDescriptor instead')
const ServiceState$json = {
  '1': 'ServiceState',
  '2': [
    {
      '1': 'state',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.libbox.v1.ServiceStateType',
      '10': 'state'
    },
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'changed_at_unix_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'changedAtUnixMs'
    },
  ],
};

/// Descriptor for `ServiceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceStateDescriptor = $convert.base64Decode(
    'CgxTZXJ2aWNlU3RhdGUSMQoFc3RhdGUYASABKA4yGy5saWJib3gudjEuU2VydmljZVN0YXRlVH'
    'lwZVIFc3RhdGUSIwoNZXJyb3JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEisKEmNoYW5n'
    'ZWRfYXRfdW5peF9tcxgDIAEoA1IPY2hhbmdlZEF0VW5peE1z');
