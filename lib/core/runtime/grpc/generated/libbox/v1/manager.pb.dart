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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'manager.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'manager.pbenum.dart';

class VersionResponse extends $pb.GeneratedMessage {
  factory VersionResponse({
    $core.String? libboxVersion,
    $core.String? singBoxVersion,
    $core.String? goVersion,
    $core.int? protocolVersion,
  }) {
    final result = create();
    if (libboxVersion != null) result.libboxVersion = libboxVersion;
    if (singBoxVersion != null) result.singBoxVersion = singBoxVersion;
    if (goVersion != null) result.goVersion = goVersion;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    return result;
  }

  VersionResponse._();

  factory VersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'libboxVersion')
    ..aOS(2, _omitFieldNames ? '' : 'singBoxVersion')
    ..aOS(3, _omitFieldNames ? '' : 'goVersion')
    ..aI(4, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse copyWith(void Function(VersionResponse) updates) =>
      super.copyWith((message) => updates(message as VersionResponse))
          as VersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionResponse create() => VersionResponse._();
  @$core.override
  VersionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VersionResponse>(create);
  static VersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get libboxVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set libboxVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLibboxVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearLibboxVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get singBoxVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set singBoxVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSingBoxVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearSingBoxVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get goVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set goVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get protocolVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set protocolVersion($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocolVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocolVersion() => $_clearField(4);
}

class CapabilitiesResponse extends $pb.GeneratedMessage {
  factory CapabilitiesResponse({
    $core.String? platform,
    $core.bool? platformVpn,
  }) {
    final result = create();
    if (platform != null) result.platform = platform;
    if (platformVpn != null) result.platformVpn = platformVpn;
    return result;
  }

  CapabilitiesResponse._();

  factory CapabilitiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CapabilitiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CapabilitiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'platform')
    ..aOB(3, _omitFieldNames ? '' : 'platformVpn')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapabilitiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapabilitiesResponse copyWith(void Function(CapabilitiesResponse) updates) =>
      super.copyWith((message) => updates(message as CapabilitiesResponse))
          as CapabilitiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CapabilitiesResponse create() => CapabilitiesResponse._();
  @$core.override
  CapabilitiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CapabilitiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CapabilitiesResponse>(create);
  static CapabilitiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get platform => $_getSZ(0);
  @$pb.TagNumber(1)
  set platform($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlatform() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlatform() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.bool get platformVpn => $_getBF(1);
  @$pb.TagNumber(3)
  set platformVpn($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(3)
  $core.bool hasPlatformVpn() => $_has(1);
  @$pb.TagNumber(3)
  void clearPlatformVpn() => $_clearField(3);
}

class ConfigRequest extends $pb.GeneratedMessage {
  factory ConfigRequest({
    $core.String? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  ConfigRequest._();

  factory ConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigRequest copyWith(void Function(ConfigRequest) updates) =>
      super.copyWith((message) => updates(message as ConfigRequest))
          as ConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigRequest create() => ConfigRequest._();
  @$core.override
  ConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigRequest>(create);
  static ConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
}

class CheckConfigResponse extends $pb.GeneratedMessage {
  factory CheckConfigResponse({
    $core.bool? valid,
    $core.String? formattedError,
  }) {
    final result = create();
    if (valid != null) result.valid = valid;
    if (formattedError != null) result.formattedError = formattedError;
    return result;
  }

  CheckConfigResponse._();

  factory CheckConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'formattedError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckConfigResponse copyWith(void Function(CheckConfigResponse) updates) =>
      super.copyWith((message) => updates(message as CheckConfigResponse))
          as CheckConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckConfigResponse create() => CheckConfigResponse._();
  @$core.override
  CheckConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckConfigResponse>(create);
  static CheckConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get formattedError => $_getSZ(1);
  @$pb.TagNumber(2)
  set formattedError($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormattedError() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormattedError() => $_clearField(2);
}

class StartRequest extends $pb.GeneratedMessage {
  factory StartRequest({
    $core.String? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  StartRequest._();

  factory StartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'config')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartRequest copyWith(void Function(StartRequest) updates) =>
      super.copyWith((message) => updates(message as StartRequest))
          as StartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartRequest create() => StartRequest._();
  @$core.override
  StartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartRequest>(create);
  static StartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get config => $_getSZ(0);
  @$pb.TagNumber(1)
  set config($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
}

class ReloadRequest extends $pb.GeneratedMessage {
  factory ReloadRequest({
    $core.String? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  ReloadRequest._();

  factory ReloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'config')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRequest copyWith(void Function(ReloadRequest) updates) =>
      super.copyWith((message) => updates(message as ReloadRequest))
          as ReloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReloadRequest create() => ReloadRequest._();
  @$core.override
  ReloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReloadRequest>(create);
  static ReloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get config => $_getSZ(0);
  @$pb.TagNumber(1)
  set config($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
}

class RestartRequest extends $pb.GeneratedMessage {
  factory RestartRequest({
    $core.String? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  RestartRequest._();

  factory RestartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'config')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartRequest copyWith(void Function(RestartRequest) updates) =>
      super.copyWith((message) => updates(message as RestartRequest))
          as RestartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartRequest create() => RestartRequest._();
  @$core.override
  RestartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestartRequest>(create);
  static RestartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get config => $_getSZ(0);
  @$pb.TagNumber(1)
  set config($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
}

class OperationResponse extends $pb.GeneratedMessage {
  factory OperationResponse({
    ServiceState? state,
  }) {
    final result = create();
    if (state != null) result.state = state;
    return result;
  }

  OperationResponse._();

  factory OperationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OperationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OperationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aOM<ServiceState>(1, _omitFieldNames ? '' : 'state',
        subBuilder: ServiceState.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationResponse copyWith(void Function(OperationResponse) updates) =>
      super.copyWith((message) => updates(message as OperationResponse))
          as OperationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OperationResponse create() => OperationResponse._();
  @$core.override
  OperationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OperationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OperationResponse>(create);
  static OperationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ServiceState get state => $_getN(0);
  @$pb.TagNumber(1)
  set state(ServiceState value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);
  @$pb.TagNumber(1)
  ServiceState ensureState() => $_ensure(0);
}

class ServiceState extends $pb.GeneratedMessage {
  factory ServiceState({
    ServiceStateType? state,
    $core.String? errorMessage,
    $fixnum.Int64? changedAtUnixMs,
  }) {
    final result = create();
    if (state != null) result.state = state;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (changedAtUnixMs != null) result.changedAtUnixMs = changedAtUnixMs;
    return result;
  }

  ServiceState._();

  factory ServiceState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServiceState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'libbox.v1'),
      createEmptyInstance: create)
    ..aE<ServiceStateType>(1, _omitFieldNames ? '' : 'state',
        enumValues: ServiceStateType.values)
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aInt64(3, _omitFieldNames ? '' : 'changedAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceState copyWith(void Function(ServiceState) updates) =>
      super.copyWith((message) => updates(message as ServiceState))
          as ServiceState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServiceState create() => ServiceState._();
  @$core.override
  ServiceState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServiceState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServiceState>(create);
  static ServiceState? _defaultInstance;

  @$pb.TagNumber(1)
  ServiceStateType get state => $_getN(0);
  @$pb.TagNumber(1)
  set state(ServiceStateType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get changedAtUnixMs => $_getI64(2);
  @$pb.TagNumber(3)
  set changedAtUnixMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChangedAtUnixMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangedAtUnixMs() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
