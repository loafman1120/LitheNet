import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:singbox_ffi/singbox_ffi.dart';

import '../app/app_identity.dart';
import '../data/models/app_settings.dart';
import '../data/models/log_entry.dart';
import '../data/singbox_api/singbox_api_client.dart';
import '../data/singbox_api/singbox_api_config.dart';
import '../data/singbox_api/singbox_api_models.dart';
import '../data/storage/app_storage_paths.dart';

part 'proxy_repository_contract.dart';
part 'singbox_api_bindings.dart';
part 'singbox_config.dart';
part 'singbox_platform.dart';
part 'proxy_repository_scope.dart';
part 'singbox_proxy_repository.dart';
part 'traffic_snapshot.dart';
