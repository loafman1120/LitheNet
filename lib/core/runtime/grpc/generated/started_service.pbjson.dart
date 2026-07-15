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
  ],
};

/// Descriptor for `GroupItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupItemDescriptor = $convert.base64Decode(
    'CglHcm91cEl0ZW0SEAoDdGFnGAEgASgJUgN0YWcSEgoEdHlwZRgCIAEoCVIEdHlwZRIgCgt1cm'
    'xUZXN0VGltZRgDIAEoA1ILdXJsVGVzdFRpbWUSIgoMdXJsVGVzdERlbGF5GAQgASgFUgx1cmxU'
    'ZXN0RGVsYXk=');

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
