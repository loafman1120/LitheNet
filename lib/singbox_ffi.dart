import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final class SbInitOptions extends Struct {
  external Pointer<Utf8> basePath;
  external Pointer<Utf8> workingPath;
  external Pointer<Utf8> tempPath;
  external Pointer<Utf8> locale;
  external Pointer<Utf8> commandSecret;

  @Int32()
  external int commandPort;

  @Int32()
  external int logMaxLines;

  @Bool()
  external bool debug;

  @Bool()
  external bool oomKillerEnabled;

  @Bool()
  external bool oomKillerDisabled;

  @Int64()
  external int oomMemoryLimit;
}

typedef SbHandle = int;

typedef SbVersionNative = Pointer<Utf8> Function();
typedef SbVersionDart = Pointer<Utf8> Function();
typedef SbGoVersionNative = Pointer<Utf8> Function();
typedef SbGoVersionDart = Pointer<Utf8> Function();
typedef SbFreeStringNative = Void Function(Pointer<Utf8>);
typedef SbFreeStringDart = void Function(Pointer<Utf8>);
typedef SbInitNative = Int32 Function(
  Pointer<SbInitOptions>,
  Pointer<Pointer<Utf8>>,
);
typedef SbInitDart = int Function(
  Pointer<SbInitOptions>,
  Pointer<Pointer<Utf8>>,
);
typedef SbCheckConfigNative = Int32 Function(
  Pointer<Utf8>,
  Pointer<Pointer<Utf8>>,
);
typedef SbCheckConfigDart = int Function(
  Pointer<Utf8>,
  Pointer<Pointer<Utf8>>,
);
typedef SbStartNative = Int32 Function(
  Pointer<Utf8>,
  Pointer<Uint64>,
  Pointer<Pointer<Utf8>>,
);
typedef SbStartDart = int Function(
  Pointer<Utf8>,
  Pointer<Uint64>,
  Pointer<Pointer<Utf8>>,
);
typedef SbReloadNative = Int32 Function(
  Uint64,
  Pointer<Utf8>,
  Pointer<Pointer<Utf8>>,
);
typedef SbReloadDart = int Function(
  int,
  Pointer<Utf8>,
  Pointer<Pointer<Utf8>>,
);
typedef SbStopNative = Int32 Function(Uint64, Pointer<Pointer<Utf8>>);
typedef SbStopDart = int Function(int, Pointer<Pointer<Utf8>>);
typedef SbFreeHandleNative = Int32 Function(Uint64);
typedef SbFreeHandleDart = int Function(int);

class SingboxException implements Exception {
  SingboxException(this.message);

  final String message;

  @override
  String toString() => 'SingboxException: $message';
}

class SingboxInitOptions {
  const SingboxInitOptions({
    this.basePath = '.',
    this.workingPath = '.',
    this.tempPath = '.',
    this.locale,
    this.commandSecret = 'lithenet-secret',
    this.commandPort = 0,
    this.logMaxLines = 300,
    this.debug = false,
    this.oomKillerEnabled = false,
    this.oomKillerDisabled = true,
    this.oomMemoryLimit = 0,
  });

  final String basePath;
  final String workingPath;
  final String tempPath;
  final String? locale;
  final String commandSecret;
  final int commandPort;
  final int logMaxLines;
  final bool debug;
  final bool oomKillerEnabled;
  final bool oomKillerDisabled;
  final int oomMemoryLimit;
}

class SingboxRawBindings {
  SingboxRawBindings(this.library)
      : sbVersion =
            library.lookupFunction<SbVersionNative, SbVersionDart>('sb_version'),
        sbGoVersion = library
            .lookupFunction<SbGoVersionNative, SbGoVersionDart>('sb_go_version'),
        sbFreeString = library
            .lookupFunction<SbFreeStringNative, SbFreeStringDart>(
          'sb_free_string',
        ),
        sbInit = library.lookupFunction<SbInitNative, SbInitDart>('sb_init'),
        sbCheckConfig = library
            .lookupFunction<SbCheckConfigNative, SbCheckConfigDart>(
          'sb_check_config',
        ),
        sbStart =
            library.lookupFunction<SbStartNative, SbStartDart>('sb_start'),
        sbReload =
            library.lookupFunction<SbReloadNative, SbReloadDart>('sb_reload'),
        sbStop = library.lookupFunction<SbStopNative, SbStopDart>('sb_stop'),
        sbFreeHandle = library
            .lookupFunction<SbFreeHandleNative, SbFreeHandleDart>(
          'sb_free_handle',
        );

  factory SingboxRawBindings.open(String path) {
    return SingboxRawBindings(DynamicLibrary.open(path));
  }

  final DynamicLibrary library;
  final SbVersionDart sbVersion;
  final SbGoVersionDart sbGoVersion;
  final SbFreeStringDart sbFreeString;
  final SbInitDart sbInit;
  final SbCheckConfigDart sbCheckConfig;
  final SbStartDart sbStart;
  final SbReloadDart sbReload;
  final SbStopDart sbStop;
  final SbFreeHandleDart sbFreeHandle;
}

class SingboxFfi {
  SingboxFfi._(this.raw);

  factory SingboxFfi.open(String path) {
    return SingboxFfi._(SingboxRawBindings.open(path));
  }

  factory SingboxFfi.openDefault() {
    return SingboxFfi.open(defaultLibraryPath());
  }

  static String defaultLibraryPath() {
    if (Platform.isWindows) {
      return _firstExistingPath([
        'native/windows/singboxffi.dll',
        '${File(Platform.resolvedExecutable).parent.path}/singboxffi.dll',
        'singboxffi.dll',
      ]);
    }
    if (Platform.isMacOS) {
      return _firstExistingPath([
        'native/macos/libsingboxffi.dylib',
        '${File(Platform.resolvedExecutable).parent.path}/libsingboxffi.dylib',
        'libsingboxffi.dylib',
      ]);
    }
    return _firstExistingPath([
      'native/linux/libsingboxffi.so',
      '${File(Platform.resolvedExecutable).parent.path}/libsingboxffi.so',
      'libsingboxffi.so',
    ]);
  }

  final SingboxRawBindings raw;

  String version() => _takeString(raw.sbVersion());

  String goVersion() => _takeString(raw.sbGoVersion());

  void init([SingboxInitOptions options = const SingboxInitOptions()]) {
    final opts = calloc<SbInitOptions>();
    final errOut = calloc<Pointer<Utf8>>();
    final allocations = <Pointer<Utf8>>[];

    Pointer<Utf8> nativeString(String? value) {
      if (value == null) {
        return nullptr;
      }
      final pointer = value.toNativeUtf8(allocator: calloc);
      allocations.add(pointer);
      return pointer;
    }

    try {
      opts.ref
        ..basePath = nativeString(options.basePath)
        ..workingPath = nativeString(options.workingPath)
        ..tempPath = nativeString(options.tempPath)
        ..locale = nativeString(options.locale)
        ..commandSecret = nativeString(options.commandSecret)
        ..commandPort = options.commandPort
        ..logMaxLines = options.logMaxLines
        ..debug = options.debug
        ..oomKillerEnabled = options.oomKillerEnabled
        ..oomKillerDisabled = options.oomKillerDisabled
        ..oomMemoryLimit = options.oomMemoryLimit;

      final code = raw.sbInit(opts, errOut);
      if (code != 0) {
        throw SingboxException(_takeError(errOut));
      }
    } finally {
      for (final pointer in allocations) {
        calloc.free(pointer);
      }
      calloc.free(errOut);
      calloc.free(opts);
    }
  }

  void checkConfig(String configJson) {
    final config = configJson.toNativeUtf8(allocator: calloc);
    final errOut = calloc<Pointer<Utf8>>();
    try {
      final code = raw.sbCheckConfig(config, errOut);
      if (code != 0) {
        throw SingboxException(_takeError(errOut));
      }
    } finally {
      calloc.free(config);
      calloc.free(errOut);
    }
  }

  SingboxService start(String configJson) {
    final config = configJson.toNativeUtf8(allocator: calloc);
    final handleOut = calloc<Uint64>();
    final errOut = calloc<Pointer<Utf8>>();
    try {
      final code = raw.sbStart(config, handleOut, errOut);
      if (code != 0) {
        throw SingboxException(_takeError(errOut));
      }
      return SingboxService._(this, handleOut.value);
    } finally {
      calloc.free(config);
      calloc.free(handleOut);
      calloc.free(errOut);
    }
  }

  void reload(SbHandle handle, String configJson) {
    final config = configJson.toNativeUtf8(allocator: calloc);
    final errOut = calloc<Pointer<Utf8>>();
    try {
      final code = raw.sbReload(handle, config, errOut);
      if (code != 0) {
        throw SingboxException(_takeError(errOut));
      }
    } finally {
      calloc.free(config);
      calloc.free(errOut);
    }
  }

  void stop(SbHandle handle) {
    final errOut = calloc<Pointer<Utf8>>();
    try {
      final code = raw.sbStop(handle, errOut);
      if (code != 0) {
        throw SingboxException(_takeError(errOut));
      }
    } finally {
      calloc.free(errOut);
    }
  }

  void freeHandle(SbHandle handle) {
    final code = raw.sbFreeHandle(handle);
    if (code != 0) {
      throw SingboxException('invalid handle');
    }
  }

  String _takeString(Pointer<Utf8> pointer) {
    if (pointer == nullptr) {
      return '';
    }
    try {
      return pointer.toDartString();
    } finally {
      raw.sbFreeString(pointer);
    }
  }

  String _takeError(Pointer<Pointer<Utf8>> errOut) {
    final pointer = errOut.value;
    if (pointer == nullptr) {
      return 'unknown error';
    }
    return _takeString(pointer);
  }
}

String _firstExistingPath(List<String> paths) {
  for (final path in paths) {
    if (File(path).existsSync()) {
      return path;
    }
  }
  return paths.first;
}

class SingboxService {
  SingboxService._(this._ffi, this.handle);

  final SingboxFfi _ffi;
  final SbHandle handle;
  bool _closed = false;

  void reload(String configJson) {
    if (_closed) {
      throw SingboxException('service is closed');
    }
    _ffi.reload(handle, configJson);
  }

  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    try {
      _ffi.stop(handle);
    } finally {
      _ffi.freeHandle(handle);
    }
  }
}
