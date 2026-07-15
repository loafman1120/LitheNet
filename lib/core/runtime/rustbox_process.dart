import 'dart:io';

class RustBoxProcessResolver {
  const RustBoxProcessResolver();

  Future<String> resolve() async {
    final executableName = Platform.isWindows
        ? 'rustbox-app.exe'
        : 'rustbox-app';
    final explicit = Platform.environment['LITHENET_RUSTBOX_BIN'];
    final executableDirectory = File(Platform.resolvedExecutable).parent.path;
    final candidates = <String>[
      if (explicit != null && explicit.trim().isNotEmpty) explicit.trim(),
      '$executableDirectory${Platform.pathSeparator}$executableName',
      '${Directory.current.path}${Platform.pathSeparator}bin'
          '${Platform.pathSeparator}$executableName',
      '${Directory.current.parent.path}${Platform.pathSeparator}RustBox'
          '${Platform.pathSeparator}target${Platform.pathSeparator}debug'
          '${Platform.pathSeparator}$executableName',
    ];

    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        return File(candidate).absolute.path;
      }
    }
    throw StateError(
      'rustbox-app was not found. Put $executableName beside LitheNet, '
      'under bin/, or set LITHENET_RUSTBOX_BIN.',
    );
  }
}
