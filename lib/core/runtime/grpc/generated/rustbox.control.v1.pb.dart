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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'rustbox.control.v1.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'rustbox.control.v1.pbenum.dart';

class GetMetricsRequest extends $pb.GeneratedMessage {
  factory GetMetricsRequest() => create();

  GetMetricsRequest._();

  factory GetMetricsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsRequest copyWith(void Function(GetMetricsRequest) updates) =>
      super.copyWith((message) => updates(message as GetMetricsRequest))
          as GetMetricsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricsRequest create() => GetMetricsRequest._();
  @$core.override
  GetMetricsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricsRequest>(create);
  static GetMetricsRequest? _defaultInstance;
}

class ListConnectionsRequest extends $pb.GeneratedMessage {
  factory ListConnectionsRequest() => create();

  ListConnectionsRequest._();

  factory ListConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConnectionsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsRequest copyWith(
          void Function(ListConnectionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListConnectionsRequest))
          as ListConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConnectionsRequest create() => ListConnectionsRequest._();
  @$core.override
  ListConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConnectionsRequest>(create);
  static ListConnectionsRequest? _defaultInstance;
}

class GetObservabilitySnapshotRequest extends $pb.GeneratedMessage {
  factory GetObservabilitySnapshotRequest() => create();

  GetObservabilitySnapshotRequest._();

  factory GetObservabilitySnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetObservabilitySnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetObservabilitySnapshotRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetObservabilitySnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetObservabilitySnapshotRequest copyWith(
          void Function(GetObservabilitySnapshotRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetObservabilitySnapshotRequest))
          as GetObservabilitySnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetObservabilitySnapshotRequest create() =>
      GetObservabilitySnapshotRequest._();
  @$core.override
  GetObservabilitySnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetObservabilitySnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetObservabilitySnapshotRequest>(
          create);
  static GetObservabilitySnapshotRequest? _defaultInstance;
}

class GetEngineSnapshotRequest extends $pb.GeneratedMessage {
  factory GetEngineSnapshotRequest() => create();

  GetEngineSnapshotRequest._();

  factory GetEngineSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetEngineSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEngineSnapshotRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEngineSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEngineSnapshotRequest copyWith(
          void Function(GetEngineSnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as GetEngineSnapshotRequest))
          as GetEngineSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEngineSnapshotRequest create() => GetEngineSnapshotRequest._();
  @$core.override
  GetEngineSnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetEngineSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEngineSnapshotRequest>(create);
  static GetEngineSnapshotRequest? _defaultInstance;
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest() => create();

  StopRequest._();

  factory StopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StopRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest copyWith(void Function(StopRequest) updates) =>
      super.copyWith((message) => updates(message as StopRequest))
          as StopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopRequest create() => StopRequest._();
  @$core.override
  StopRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StopRequest>(create);
  static StopRequest? _defaultInstance;
}

class QueryEventsRequest extends $pb.GeneratedMessage {
  factory QueryEventsRequest({
    $core.String? minLevel,
    $core.String? targetPrefix,
    $fixnum.Int64? flowId,
    $core.int? limit,
  }) {
    final result = create();
    if (minLevel != null) result.minLevel = minLevel;
    if (targetPrefix != null) result.targetPrefix = targetPrefix;
    if (flowId != null) result.flowId = flowId;
    if (limit != null) result.limit = limit;
    return result;
  }

  QueryEventsRequest._();

  factory QueryEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QueryEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryEventsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'minLevel')
    ..aOS(2, _omitFieldNames ? '' : 'targetPrefix')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'flowId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEventsRequest copyWith(void Function(QueryEventsRequest) updates) =>
      super.copyWith((message) => updates(message as QueryEventsRequest))
          as QueryEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryEventsRequest create() => QueryEventsRequest._();
  @$core.override
  QueryEventsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QueryEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QueryEventsRequest>(create);
  static QueryEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get minLevel => $_getSZ(0);
  @$pb.TagNumber(1)
  set minLevel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinLevel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetPrefix => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetPrefix($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetPrefix() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetPrefix() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get flowId => $_getI64(2);
  @$pb.TagNumber(3)
  set flowId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFlowId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFlowId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

class MetricsSnapshot extends $pb.GeneratedMessage {
  factory MetricsSnapshot({
    $fixnum.Int64? servicesStarted,
    $fixnum.Int64? servicesStopped,
    $fixnum.Int64? connectionsAccepted,
    $fixnum.Int64? flowsAccepted,
    $fixnum.Int64? flowsActive,
    $fixnum.Int64? flowsCompleted,
    $fixnum.Int64? flowsFailed,
    $fixnum.Int64? routesSelected,
    $fixnum.Int64? outboundConnectAttempts,
    $fixnum.Int64? outboundConnectSuccesses,
    $fixnum.Int64? outboundConnectFailures,
    $fixnum.Int64? inboundToOutboundBytes,
    $fixnum.Int64? outboundToInboundBytes,
    $fixnum.Int64? diagnostics,
  }) {
    final result = create();
    if (servicesStarted != null) result.servicesStarted = servicesStarted;
    if (servicesStopped != null) result.servicesStopped = servicesStopped;
    if (connectionsAccepted != null)
      result.connectionsAccepted = connectionsAccepted;
    if (flowsAccepted != null) result.flowsAccepted = flowsAccepted;
    if (flowsActive != null) result.flowsActive = flowsActive;
    if (flowsCompleted != null) result.flowsCompleted = flowsCompleted;
    if (flowsFailed != null) result.flowsFailed = flowsFailed;
    if (routesSelected != null) result.routesSelected = routesSelected;
    if (outboundConnectAttempts != null)
      result.outboundConnectAttempts = outboundConnectAttempts;
    if (outboundConnectSuccesses != null)
      result.outboundConnectSuccesses = outboundConnectSuccesses;
    if (outboundConnectFailures != null)
      result.outboundConnectFailures = outboundConnectFailures;
    if (inboundToOutboundBytes != null)
      result.inboundToOutboundBytes = inboundToOutboundBytes;
    if (outboundToInboundBytes != null)
      result.outboundToInboundBytes = outboundToInboundBytes;
    if (diagnostics != null) result.diagnostics = diagnostics;
    return result;
  }

  MetricsSnapshot._();

  factory MetricsSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MetricsSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MetricsSnapshot',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'servicesStarted', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'servicesStopped', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'connectionsAccepted', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'flowsAccepted', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'flowsActive', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'flowsCompleted', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'flowsFailed', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'routesSelected', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(9, _omitFieldNames ? '' : 'outboundConnectAttempts',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(10, _omitFieldNames ? '' : 'outboundConnectSuccesses',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(11, _omitFieldNames ? '' : 'outboundConnectFailures',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'inboundToOutboundBytes',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(13, _omitFieldNames ? '' : 'outboundToInboundBytes',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        14, _omitFieldNames ? '' : 'diagnostics', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricsSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricsSnapshot copyWith(void Function(MetricsSnapshot) updates) =>
      super.copyWith((message) => updates(message as MetricsSnapshot))
          as MetricsSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MetricsSnapshot create() => MetricsSnapshot._();
  @$core.override
  MetricsSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MetricsSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MetricsSnapshot>(create);
  static MetricsSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get servicesStarted => $_getI64(0);
  @$pb.TagNumber(1)
  set servicesStarted($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServicesStarted() => $_has(0);
  @$pb.TagNumber(1)
  void clearServicesStarted() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get servicesStopped => $_getI64(1);
  @$pb.TagNumber(2)
  set servicesStopped($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServicesStopped() => $_has(1);
  @$pb.TagNumber(2)
  void clearServicesStopped() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get connectionsAccepted => $_getI64(2);
  @$pb.TagNumber(3)
  set connectionsAccepted($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectionsAccepted() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectionsAccepted() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get flowsAccepted => $_getI64(3);
  @$pb.TagNumber(4)
  set flowsAccepted($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFlowsAccepted() => $_has(3);
  @$pb.TagNumber(4)
  void clearFlowsAccepted() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get flowsActive => $_getI64(4);
  @$pb.TagNumber(5)
  set flowsActive($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFlowsActive() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlowsActive() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get flowsCompleted => $_getI64(5);
  @$pb.TagNumber(6)
  set flowsCompleted($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFlowsCompleted() => $_has(5);
  @$pb.TagNumber(6)
  void clearFlowsCompleted() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get flowsFailed => $_getI64(6);
  @$pb.TagNumber(7)
  set flowsFailed($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFlowsFailed() => $_has(6);
  @$pb.TagNumber(7)
  void clearFlowsFailed() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get routesSelected => $_getI64(7);
  @$pb.TagNumber(8)
  set routesSelected($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRoutesSelected() => $_has(7);
  @$pb.TagNumber(8)
  void clearRoutesSelected() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get outboundConnectAttempts => $_getI64(8);
  @$pb.TagNumber(9)
  set outboundConnectAttempts($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOutboundConnectAttempts() => $_has(8);
  @$pb.TagNumber(9)
  void clearOutboundConnectAttempts() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get outboundConnectSuccesses => $_getI64(9);
  @$pb.TagNumber(10)
  set outboundConnectSuccesses($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOutboundConnectSuccesses() => $_has(9);
  @$pb.TagNumber(10)
  void clearOutboundConnectSuccesses() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get outboundConnectFailures => $_getI64(10);
  @$pb.TagNumber(11)
  set outboundConnectFailures($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasOutboundConnectFailures() => $_has(10);
  @$pb.TagNumber(11)
  void clearOutboundConnectFailures() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get inboundToOutboundBytes => $_getI64(11);
  @$pb.TagNumber(12)
  set inboundToOutboundBytes($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasInboundToOutboundBytes() => $_has(11);
  @$pb.TagNumber(12)
  void clearInboundToOutboundBytes() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get outboundToInboundBytes => $_getI64(12);
  @$pb.TagNumber(13)
  set outboundToInboundBytes($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasOutboundToInboundBytes() => $_has(12);
  @$pb.TagNumber(13)
  void clearOutboundToInboundBytes() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get diagnostics => $_getI64(13);
  @$pb.TagNumber(14)
  set diagnostics($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDiagnostics() => $_has(13);
  @$pb.TagNumber(14)
  void clearDiagnostics() => $_clearField(14);
}

class ConnectionStats extends $pb.GeneratedMessage {
  factory ConnectionStats({
    $fixnum.Int64? flowId,
    $core.String? source,
    $core.String? destination,
    $core.String? network,
    ConnectionState? state,
    $fixnum.Int64? inboundToOutboundBytes,
    $fixnum.Int64? outboundToInboundBytes,
    $core.String? outcome,
    $core.String? error,
  }) {
    final result = create();
    if (flowId != null) result.flowId = flowId;
    if (source != null) result.source = source;
    if (destination != null) result.destination = destination;
    if (network != null) result.network = network;
    if (state != null) result.state = state;
    if (inboundToOutboundBytes != null)
      result.inboundToOutboundBytes = inboundToOutboundBytes;
    if (outboundToInboundBytes != null)
      result.outboundToInboundBytes = outboundToInboundBytes;
    if (outcome != null) result.outcome = outcome;
    if (error != null) result.error = error;
    return result;
  }

  ConnectionStats._();

  factory ConnectionStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectionStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectionStats',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'flowId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'source')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aOS(4, _omitFieldNames ? '' : 'network')
    ..aE<ConnectionState>(5, _omitFieldNames ? '' : 'state',
        enumValues: ConnectionState.values)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'inboundToOutboundBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'outboundToInboundBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(8, _omitFieldNames ? '' : 'outcome')
    ..aOS(9, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionStats copyWith(void Function(ConnectionStats) updates) =>
      super.copyWith((message) => updates(message as ConnectionStats))
          as ConnectionStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectionStats create() => ConnectionStats._();
  @$core.override
  ConnectionStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectionStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectionStats>(create);
  static ConnectionStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get flowId => $_getI64(0);
  @$pb.TagNumber(1)
  set flowId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFlowId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFlowId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get source => $_getSZ(1);
  @$pb.TagNumber(2)
  set source($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearSource() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get network => $_getSZ(3);
  @$pb.TagNumber(4)
  set network($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNetwork() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetwork() => $_clearField(4);

  @$pb.TagNumber(5)
  ConnectionState get state => $_getN(4);
  @$pb.TagNumber(5)
  set state(ConnectionState value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasState() => $_has(4);
  @$pb.TagNumber(5)
  void clearState() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get inboundToOutboundBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set inboundToOutboundBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInboundToOutboundBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearInboundToOutboundBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get outboundToInboundBytes => $_getI64(6);
  @$pb.TagNumber(7)
  set outboundToInboundBytes($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOutboundToInboundBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearOutboundToInboundBytes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get outcome => $_getSZ(7);
  @$pb.TagNumber(8)
  set outcome($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOutcome() => $_has(7);
  @$pb.TagNumber(8)
  void clearOutcome() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => $_clearField(9);
}

class Event extends $pb.GeneratedMessage {
  factory Event({
    $core.String? level,
    $core.String? target,
    $fixnum.Int64? flowId,
    $core.String? kind,
    $core.String? message,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? attributes,
  }) {
    final result = create();
    if (level != null) result.level = level;
    if (target != null) result.target = target;
    if (flowId != null) result.flowId = flowId;
    if (kind != null) result.kind = kind;
    if (message != null) result.message = message;
    if (attributes != null) result.attributes.addEntries(attributes);
    return result;
  }

  Event._();

  factory Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'level')
    ..aOS(2, _omitFieldNames ? '' : 'target')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'flowId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'kind')
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'Event.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('rustbox.control.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event)) as Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event create() => Event._();
  @$core.override
  Event createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Event>(create);
  static Event? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get level => $_getSZ(0);
  @$pb.TagNumber(1)
  set level($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get target => $_getSZ(1);
  @$pb.TagNumber(2)
  set target($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearTarget() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get flowId => $_getI64(2);
  @$pb.TagNumber(3)
  set flowId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFlowId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFlowId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get kind => $_getSZ(3);
  @$pb.TagNumber(4)
  set kind($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get attributes => $_getMap(5);
}

class ListConnectionsResponse extends $pb.GeneratedMessage {
  factory ListConnectionsResponse({
    $core.Iterable<ConnectionStats>? connections,
  }) {
    final result = create();
    if (connections != null) result.connections.addAll(connections);
    return result;
  }

  ListConnectionsResponse._();

  factory ListConnectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConnectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConnectionsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..pPM<ConnectionStats>(1, _omitFieldNames ? '' : 'connections',
        subBuilder: ConnectionStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsResponse copyWith(
          void Function(ListConnectionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListConnectionsResponse))
          as ListConnectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConnectionsResponse create() => ListConnectionsResponse._();
  @$core.override
  ListConnectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConnectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConnectionsResponse>(create);
  static ListConnectionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConnectionStats> get connections => $_getList(0);
}

class QueryEventsResponse extends $pb.GeneratedMessage {
  factory QueryEventsResponse({
    $core.Iterable<Event>? events,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    return result;
  }

  QueryEventsResponse._();

  factory QueryEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QueryEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryEventsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..pPM<Event>(1, _omitFieldNames ? '' : 'events', subBuilder: Event.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEventsResponse copyWith(void Function(QueryEventsResponse) updates) =>
      super.copyWith((message) => updates(message as QueryEventsResponse))
          as QueryEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryEventsResponse create() => QueryEventsResponse._();
  @$core.override
  QueryEventsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QueryEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QueryEventsResponse>(create);
  static QueryEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Event> get events => $_getList(0);
}

class ObservabilitySnapshot extends $pb.GeneratedMessage {
  factory ObservabilitySnapshot({
    MetricsSnapshot? metrics,
    $core.Iterable<ConnectionStats>? connections,
    $core.Iterable<Event>? recentEvents,
  }) {
    final result = create();
    if (metrics != null) result.metrics = metrics;
    if (connections != null) result.connections.addAll(connections);
    if (recentEvents != null) result.recentEvents.addAll(recentEvents);
    return result;
  }

  ObservabilitySnapshot._();

  factory ObservabilitySnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObservabilitySnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObservabilitySnapshot',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..aOM<MetricsSnapshot>(1, _omitFieldNames ? '' : 'metrics',
        subBuilder: MetricsSnapshot.create)
    ..pPM<ConnectionStats>(2, _omitFieldNames ? '' : 'connections',
        subBuilder: ConnectionStats.create)
    ..pPM<Event>(3, _omitFieldNames ? '' : 'recentEvents',
        subBuilder: Event.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObservabilitySnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObservabilitySnapshot copyWith(
          void Function(ObservabilitySnapshot) updates) =>
      super.copyWith((message) => updates(message as ObservabilitySnapshot))
          as ObservabilitySnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObservabilitySnapshot create() => ObservabilitySnapshot._();
  @$core.override
  ObservabilitySnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObservabilitySnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObservabilitySnapshot>(create);
  static ObservabilitySnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  MetricsSnapshot get metrics => $_getN(0);
  @$pb.TagNumber(1)
  set metrics(MetricsSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMetrics() => $_has(0);
  @$pb.TagNumber(1)
  void clearMetrics() => $_clearField(1);
  @$pb.TagNumber(1)
  MetricsSnapshot ensureMetrics() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<ConnectionStats> get connections => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Event> get recentEvents => $_getList(2);
}

class EngineSnapshot extends $pb.GeneratedMessage {
  factory EngineSnapshot({
    EngineState? state,
    $fixnum.Int64? generation,
    $fixnum.Int64? inboundCount,
    $fixnum.Int64? outboundCount,
  }) {
    final result = create();
    if (state != null) result.state = state;
    if (generation != null) result.generation = generation;
    if (inboundCount != null) result.inboundCount = inboundCount;
    if (outboundCount != null) result.outboundCount = outboundCount;
    return result;
  }

  EngineSnapshot._();

  factory EngineSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EngineSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EngineSnapshot',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rustbox.control.v1'),
      createEmptyInstance: create)
    ..aE<EngineState>(1, _omitFieldNames ? '' : 'state',
        enumValues: EngineState.values)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'generation', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'inboundCount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'outboundCount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EngineSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EngineSnapshot copyWith(void Function(EngineSnapshot) updates) =>
      super.copyWith((message) => updates(message as EngineSnapshot))
          as EngineSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EngineSnapshot create() => EngineSnapshot._();
  @$core.override
  EngineSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EngineSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EngineSnapshot>(create);
  static EngineSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  EngineState get state => $_getN(0);
  @$pb.TagNumber(1)
  set state(EngineState value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get generation => $_getI64(1);
  @$pb.TagNumber(2)
  set generation($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGeneration() => $_has(1);
  @$pb.TagNumber(2)
  void clearGeneration() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get inboundCount => $_getI64(2);
  @$pb.TagNumber(3)
  set inboundCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInboundCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearInboundCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get outboundCount => $_getI64(3);
  @$pb.TagNumber(4)
  set outboundCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOutboundCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearOutboundCount() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
