// This is a generated file - do not edit.
//
// Generated from libbox/v1/manager.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'manager.pb.dart' as $1;

export 'manager.pb.dart';

@$pb.GrpcServiceName('libbox.v1.LibboxManager')
class LibboxManagerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LibboxManagerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.VersionResponse> getVersion(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getVersion, request, options: options);
  }

  $grpc.ResponseFuture<$1.CapabilitiesResponse> getCapabilities(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCapabilities, request, options: options);
  }

  $grpc.ResponseFuture<$1.CheckConfigResponse> checkConfig(
    $1.ConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkConfig, request, options: options);
  }

  $grpc.ResponseFuture<$1.OperationResponse> start(
    $1.StartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$1.OperationResponse> reload(
    $1.ReloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reload, request, options: options);
  }

  $grpc.ResponseFuture<$1.OperationResponse> restart(
    $1.RestartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restart, request, options: options);
  }

  $grpc.ResponseFuture<$1.OperationResponse> stop(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stop, request, options: options);
  }

  $grpc.ResponseFuture<$1.ServiceState> getState(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getState, request, options: options);
  }

  $grpc.ResponseStream<$1.ServiceState> subscribeState(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeState, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getVersion = $grpc.ClientMethod<$0.Empty, $1.VersionResponse>(
      '/libbox.v1.LibboxManager/GetVersion',
      ($0.Empty value) => value.writeToBuffer(),
      $1.VersionResponse.fromBuffer);
  static final _$getCapabilities =
      $grpc.ClientMethod<$0.Empty, $1.CapabilitiesResponse>(
          '/libbox.v1.LibboxManager/GetCapabilities',
          ($0.Empty value) => value.writeToBuffer(),
          $1.CapabilitiesResponse.fromBuffer);
  static final _$checkConfig =
      $grpc.ClientMethod<$1.ConfigRequest, $1.CheckConfigResponse>(
          '/libbox.v1.LibboxManager/CheckConfig',
          ($1.ConfigRequest value) => value.writeToBuffer(),
          $1.CheckConfigResponse.fromBuffer);
  static final _$start =
      $grpc.ClientMethod<$1.StartRequest, $1.OperationResponse>(
          '/libbox.v1.LibboxManager/Start',
          ($1.StartRequest value) => value.writeToBuffer(),
          $1.OperationResponse.fromBuffer);
  static final _$reload =
      $grpc.ClientMethod<$1.ReloadRequest, $1.OperationResponse>(
          '/libbox.v1.LibboxManager/Reload',
          ($1.ReloadRequest value) => value.writeToBuffer(),
          $1.OperationResponse.fromBuffer);
  static final _$restart =
      $grpc.ClientMethod<$1.RestartRequest, $1.OperationResponse>(
          '/libbox.v1.LibboxManager/Restart',
          ($1.RestartRequest value) => value.writeToBuffer(),
          $1.OperationResponse.fromBuffer);
  static final _$stop = $grpc.ClientMethod<$0.Empty, $1.OperationResponse>(
      '/libbox.v1.LibboxManager/Stop',
      ($0.Empty value) => value.writeToBuffer(),
      $1.OperationResponse.fromBuffer);
  static final _$getState = $grpc.ClientMethod<$0.Empty, $1.ServiceState>(
      '/libbox.v1.LibboxManager/GetState',
      ($0.Empty value) => value.writeToBuffer(),
      $1.ServiceState.fromBuffer);
  static final _$subscribeState = $grpc.ClientMethod<$0.Empty, $1.ServiceState>(
      '/libbox.v1.LibboxManager/SubscribeState',
      ($0.Empty value) => value.writeToBuffer(),
      $1.ServiceState.fromBuffer);
}

@$pb.GrpcServiceName('libbox.v1.LibboxManager')
abstract class LibboxManagerServiceBase extends $grpc.Service {
  $core.String get $name => 'libbox.v1.LibboxManager';

  LibboxManagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.VersionResponse>(
        'GetVersion',
        getVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.VersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.CapabilitiesResponse>(
        'GetCapabilities',
        getCapabilities_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.CapabilitiesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.ConfigRequest, $1.CheckConfigResponse>(
        'CheckConfig',
        checkConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.ConfigRequest.fromBuffer(value),
        ($1.CheckConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StartRequest, $1.OperationResponse>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.StartRequest.fromBuffer(value),
        ($1.OperationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.ReloadRequest, $1.OperationResponse>(
        'Reload',
        reload_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.ReloadRequest.fromBuffer(value),
        ($1.OperationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.RestartRequest, $1.OperationResponse>(
        'Restart',
        restart_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.RestartRequest.fromBuffer(value),
        ($1.OperationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.OperationResponse>(
        'Stop',
        stop_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.OperationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ServiceState>(
        'GetState',
        getState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ServiceState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ServiceState>(
        'SubscribeState',
        subscribeState_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ServiceState value) => value.writeToBuffer()));
  }

  $async.Future<$1.VersionResponse> getVersion_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getVersion($call, await $request);
  }

  $async.Future<$1.VersionResponse> getVersion(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.CapabilitiesResponse> getCapabilities_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getCapabilities($call, await $request);
  }

  $async.Future<$1.CapabilitiesResponse> getCapabilities(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.CheckConfigResponse> checkConfig_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.ConfigRequest> $request) async {
    return checkConfig($call, await $request);
  }

  $async.Future<$1.CheckConfigResponse> checkConfig(
      $grpc.ServiceCall call, $1.ConfigRequest request);

  $async.Future<$1.OperationResponse> start_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.StartRequest> $request) async {
    return start($call, await $request);
  }

  $async.Future<$1.OperationResponse> start(
      $grpc.ServiceCall call, $1.StartRequest request);

  $async.Future<$1.OperationResponse> reload_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.ReloadRequest> $request) async {
    return reload($call, await $request);
  }

  $async.Future<$1.OperationResponse> reload(
      $grpc.ServiceCall call, $1.ReloadRequest request);

  $async.Future<$1.OperationResponse> restart_Pre($grpc.ServiceCall $call,
      $async.Future<$1.RestartRequest> $request) async {
    return restart($call, await $request);
  }

  $async.Future<$1.OperationResponse> restart(
      $grpc.ServiceCall call, $1.RestartRequest request);

  $async.Future<$1.OperationResponse> stop_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return stop($call, await $request);
  }

  $async.Future<$1.OperationResponse> stop(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.ServiceState> getState_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getState($call, await $request);
  }

  $async.Future<$1.ServiceState> getState(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Stream<$1.ServiceState> subscribeState_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* subscribeState($call, await $request);
  }

  $async.Stream<$1.ServiceState> subscribeState(
      $grpc.ServiceCall call, $0.Empty request);
}
