// This is a generated file - do not edit.
//
// Generated from libbox/v1/manager.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ServiceStateType extends $pb.ProtobufEnum {
  static const ServiceStateType SERVICE_STATE_UNSPECIFIED =
      ServiceStateType._(0, _omitEnumNames ? '' : 'SERVICE_STATE_UNSPECIFIED');
  static const ServiceStateType SERVICE_STATE_IDLE =
      ServiceStateType._(1, _omitEnumNames ? '' : 'SERVICE_STATE_IDLE');
  static const ServiceStateType SERVICE_STATE_STARTING =
      ServiceStateType._(2, _omitEnumNames ? '' : 'SERVICE_STATE_STARTING');
  static const ServiceStateType SERVICE_STATE_RUNNING =
      ServiceStateType._(3, _omitEnumNames ? '' : 'SERVICE_STATE_RUNNING');
  static const ServiceStateType SERVICE_STATE_STOPPING =
      ServiceStateType._(4, _omitEnumNames ? '' : 'SERVICE_STATE_STOPPING');
  static const ServiceStateType SERVICE_STATE_FAILED =
      ServiceStateType._(5, _omitEnumNames ? '' : 'SERVICE_STATE_FAILED');

  static const $core.List<ServiceStateType> values = <ServiceStateType>[
    SERVICE_STATE_UNSPECIFIED,
    SERVICE_STATE_IDLE,
    SERVICE_STATE_STARTING,
    SERVICE_STATE_RUNNING,
    SERVICE_STATE_STOPPING,
    SERVICE_STATE_FAILED,
  ];

  static final $core.List<ServiceStateType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ServiceStateType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ServiceStateType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
