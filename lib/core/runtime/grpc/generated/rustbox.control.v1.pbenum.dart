// This is a generated file - do not edit.
//
// Generated from rustbox.control.v1.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConnectionState extends $pb.ProtobufEnum {
  static const ConnectionState CONNECTION_STATE_UNSPECIFIED = ConnectionState._(
      0, _omitEnumNames ? '' : 'CONNECTION_STATE_UNSPECIFIED');
  static const ConnectionState CONNECTION_STATE_ACTIVE =
      ConnectionState._(1, _omitEnumNames ? '' : 'CONNECTION_STATE_ACTIVE');
  static const ConnectionState CONNECTION_STATE_COMPLETED =
      ConnectionState._(2, _omitEnumNames ? '' : 'CONNECTION_STATE_COMPLETED');
  static const ConnectionState CONNECTION_STATE_FAILED =
      ConnectionState._(3, _omitEnumNames ? '' : 'CONNECTION_STATE_FAILED');

  static const $core.List<ConnectionState> values = <ConnectionState>[
    CONNECTION_STATE_UNSPECIFIED,
    CONNECTION_STATE_ACTIVE,
    CONNECTION_STATE_COMPLETED,
    CONNECTION_STATE_FAILED,
  ];

  static final $core.List<ConnectionState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ConnectionState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConnectionState._(super.value, super.name);
}

class EngineState extends $pb.ProtobufEnum {
  static const EngineState ENGINE_STATE_UNSPECIFIED =
      EngineState._(0, _omitEnumNames ? '' : 'ENGINE_STATE_UNSPECIFIED');
  static const EngineState ENGINE_STATE_CREATED =
      EngineState._(1, _omitEnumNames ? '' : 'ENGINE_STATE_CREATED');
  static const EngineState ENGINE_STATE_PREPARED =
      EngineState._(2, _omitEnumNames ? '' : 'ENGINE_STATE_PREPARED');
  static const EngineState ENGINE_STATE_RUNNING =
      EngineState._(3, _omitEnumNames ? '' : 'ENGINE_STATE_RUNNING');
  static const EngineState ENGINE_STATE_STOPPING =
      EngineState._(4, _omitEnumNames ? '' : 'ENGINE_STATE_STOPPING');
  static const EngineState ENGINE_STATE_STOPPED =
      EngineState._(5, _omitEnumNames ? '' : 'ENGINE_STATE_STOPPED');
  static const EngineState ENGINE_STATE_FAILED =
      EngineState._(6, _omitEnumNames ? '' : 'ENGINE_STATE_FAILED');

  static const $core.List<EngineState> values = <EngineState>[
    ENGINE_STATE_UNSPECIFIED,
    ENGINE_STATE_CREATED,
    ENGINE_STATE_PREPARED,
    ENGINE_STATE_RUNNING,
    ENGINE_STATE_STOPPING,
    ENGINE_STATE_STOPPED,
    ENGINE_STATE_FAILED,
  ];

  static final $core.List<EngineState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static EngineState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EngineState._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
