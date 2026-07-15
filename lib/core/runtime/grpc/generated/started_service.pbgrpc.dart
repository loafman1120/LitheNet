// This is a generated file - do not edit.
//
// Generated from started_service.proto.

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

import 'started_service.pb.dart' as $1;

export 'started_service.pb.dart';

@$pb.GrpcServiceName('daemon.StartedService')
class StartedServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  StartedServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$1.Groups> subscribeGroups(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeGroups, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> selectOutbound(
    $1.SelectOutboundRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$selectOutbound, request, options: options);
  }

  // method descriptors

  static final _$subscribeGroups = $grpc.ClientMethod<$0.Empty, $1.Groups>(
      '/daemon.StartedService/SubscribeGroups',
      ($0.Empty value) => value.writeToBuffer(),
      $1.Groups.fromBuffer);
  static final _$selectOutbound =
      $grpc.ClientMethod<$1.SelectOutboundRequest, $0.Empty>(
          '/daemon.StartedService/SelectOutbound',
          ($1.SelectOutboundRequest value) => value.writeToBuffer(),
          $0.Empty.fromBuffer);
}

@$pb.GrpcServiceName('daemon.StartedService')
abstract class StartedServiceBase extends $grpc.Service {
  $core.String get $name => 'daemon.StartedService';

  StartedServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Groups>(
        'SubscribeGroups',
        subscribeGroups_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Groups value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SelectOutboundRequest, $0.Empty>(
        'SelectOutbound',
        selectOutbound_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.SelectOutboundRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$1.Groups> subscribeGroups_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* subscribeGroups($call, await $request);
  }

  $async.Stream<$1.Groups> subscribeGroups(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Empty> selectOutbound_Pre($grpc.ServiceCall $call,
      $async.Future<$1.SelectOutboundRequest> $request) async {
    return selectOutbound($call, await $request);
  }

  $async.Future<$0.Empty> selectOutbound(
      $grpc.ServiceCall call, $1.SelectOutboundRequest request);
}
