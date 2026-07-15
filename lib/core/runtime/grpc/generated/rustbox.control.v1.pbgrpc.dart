// This is a generated file - do not edit.
//
// Generated from rustbox.control.v1.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'rustbox.control.v1.pb.dart' as $0;

export 'rustbox.control.v1.pb.dart';

@$pb.GrpcServiceName('rustbox.control.v1.RustBoxControl')
class RustBoxControlClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RustBoxControlClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.MetricsSnapshot> getMetrics(
    $0.GetMetricsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMetrics, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListConnectionsResponse> listConnections(
    $0.ListConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listConnections, request, options: options);
  }

  $grpc.ResponseFuture<$0.QueryEventsResponse> queryEvents(
    $0.QueryEventsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$queryEvents, request, options: options);
  }

  $grpc.ResponseFuture<$0.ObservabilitySnapshot> getObservabilitySnapshot(
    $0.GetObservabilitySnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getObservabilitySnapshot, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.EngineSnapshot> getEngineSnapshot(
    $0.GetEngineSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getEngineSnapshot, request, options: options);
  }

  $grpc.ResponseFuture<$0.EngineSnapshot> stop(
    $0.StopRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stop, request, options: options);
  }

  // method descriptors

  static final _$getMetrics =
      $grpc.ClientMethod<$0.GetMetricsRequest, $0.MetricsSnapshot>(
          '/rustbox.control.v1.RustBoxControl/GetMetrics',
          ($0.GetMetricsRequest value) => value.writeToBuffer(),
          $0.MetricsSnapshot.fromBuffer);
  static final _$listConnections =
      $grpc.ClientMethod<$0.ListConnectionsRequest, $0.ListConnectionsResponse>(
          '/rustbox.control.v1.RustBoxControl/ListConnections',
          ($0.ListConnectionsRequest value) => value.writeToBuffer(),
          $0.ListConnectionsResponse.fromBuffer);
  static final _$queryEvents =
      $grpc.ClientMethod<$0.QueryEventsRequest, $0.QueryEventsResponse>(
          '/rustbox.control.v1.RustBoxControl/QueryEvents',
          ($0.QueryEventsRequest value) => value.writeToBuffer(),
          $0.QueryEventsResponse.fromBuffer);
  static final _$getObservabilitySnapshot = $grpc.ClientMethod<
          $0.GetObservabilitySnapshotRequest, $0.ObservabilitySnapshot>(
      '/rustbox.control.v1.RustBoxControl/GetObservabilitySnapshot',
      ($0.GetObservabilitySnapshotRequest value) => value.writeToBuffer(),
      $0.ObservabilitySnapshot.fromBuffer);
  static final _$getEngineSnapshot =
      $grpc.ClientMethod<$0.GetEngineSnapshotRequest, $0.EngineSnapshot>(
          '/rustbox.control.v1.RustBoxControl/GetEngineSnapshot',
          ($0.GetEngineSnapshotRequest value) => value.writeToBuffer(),
          $0.EngineSnapshot.fromBuffer);
  static final _$stop = $grpc.ClientMethod<$0.StopRequest, $0.EngineSnapshot>(
      '/rustbox.control.v1.RustBoxControl/Stop',
      ($0.StopRequest value) => value.writeToBuffer(),
      $0.EngineSnapshot.fromBuffer);
}

@$pb.GrpcServiceName('rustbox.control.v1.RustBoxControl')
abstract class RustBoxControlServiceBase extends $grpc.Service {
  $core.String get $name => 'rustbox.control.v1.RustBoxControl';

  RustBoxControlServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetMetricsRequest, $0.MetricsSnapshot>(
        'GetMetrics',
        getMetrics_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetMetricsRequest.fromBuffer(value),
        ($0.MetricsSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListConnectionsRequest,
            $0.ListConnectionsResponse>(
        'ListConnections',
        listConnections_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListConnectionsRequest.fromBuffer(value),
        ($0.ListConnectionsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.QueryEventsRequest, $0.QueryEventsResponse>(
            'QueryEvents',
            queryEvents_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.QueryEventsRequest.fromBuffer(value),
            ($0.QueryEventsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetObservabilitySnapshotRequest,
            $0.ObservabilitySnapshot>(
        'GetObservabilitySnapshot',
        getObservabilitySnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetObservabilitySnapshotRequest.fromBuffer(value),
        ($0.ObservabilitySnapshot value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetEngineSnapshotRequest, $0.EngineSnapshot>(
            'GetEngineSnapshot',
            getEngineSnapshot_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetEngineSnapshotRequest.fromBuffer(value),
            ($0.EngineSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StopRequest, $0.EngineSnapshot>(
        'Stop',
        stop_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StopRequest.fromBuffer(value),
        ($0.EngineSnapshot value) => value.writeToBuffer()));
  }

  $async.Future<$0.MetricsSnapshot> getMetrics_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetMetricsRequest> $request) async {
    return getMetrics($call, await $request);
  }

  $async.Future<$0.MetricsSnapshot> getMetrics(
      $grpc.ServiceCall call, $0.GetMetricsRequest request);

  $async.Future<$0.ListConnectionsResponse> listConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListConnectionsRequest> $request) async {
    return listConnections($call, await $request);
  }

  $async.Future<$0.ListConnectionsResponse> listConnections(
      $grpc.ServiceCall call, $0.ListConnectionsRequest request);

  $async.Future<$0.QueryEventsResponse> queryEvents_Pre($grpc.ServiceCall $call,
      $async.Future<$0.QueryEventsRequest> $request) async {
    return queryEvents($call, await $request);
  }

  $async.Future<$0.QueryEventsResponse> queryEvents(
      $grpc.ServiceCall call, $0.QueryEventsRequest request);

  $async.Future<$0.ObservabilitySnapshot> getObservabilitySnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetObservabilitySnapshotRequest> $request) async {
    return getObservabilitySnapshot($call, await $request);
  }

  $async.Future<$0.ObservabilitySnapshot> getObservabilitySnapshot(
      $grpc.ServiceCall call, $0.GetObservabilitySnapshotRequest request);

  $async.Future<$0.EngineSnapshot> getEngineSnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetEngineSnapshotRequest> $request) async {
    return getEngineSnapshot($call, await $request);
  }

  $async.Future<$0.EngineSnapshot> getEngineSnapshot(
      $grpc.ServiceCall call, $0.GetEngineSnapshotRequest request);

  $async.Future<$0.EngineSnapshot> stop_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.StopRequest> $request) async {
    return stop($call, await $request);
  }

  $async.Future<$0.EngineSnapshot> stop(
      $grpc.ServiceCall call, $0.StopRequest request);
}
