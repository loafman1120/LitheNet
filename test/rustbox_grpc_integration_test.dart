import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lithenet/core/runtime/core_models.dart';
import 'package:lithenet/core/runtime/rustbox_grpc_gateway.dart';
import 'package:lithenet/data/models/app_settings.dart';

void main() {
  final binary = Platform.environment['LITHENET_RUSTBOX_BIN'];

  test(
    'starts, observes, and stops RustBox through gRPC asynchronously',
    () async {
      final gateway = RustBoxGrpcGateway(
        workingDirectory: await Directory.systemTemp.createTemp(
          'lithenet-grpc-test-',
        ),
      );
      addTearDown(gateway.dispose);

      await gateway.configure(
        const AppSettings(mixedPort: 28081, systemProxy: false),
      );
      await gateway.start();

      expect((await gateway.current()).lifecycle, CoreLifecycle.running);

      await gateway.stop();
      expect((await gateway.current()).lifecycle, CoreLifecycle.stopped);
    },
    skip: binary == null || binary.isEmpty
        ? 'Set LITHENET_RUSTBOX_BIN to run the real gRPC integration test.'
        : false,
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
