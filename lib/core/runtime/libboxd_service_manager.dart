import 'dart:convert';
import 'dart:io';

import '../logging/app_logger.dart';

enum LibboxdServiceStatus { running, stopped, unknown, notInstalled }

class LibboxdServiceResult {
  const LibboxdServiceResult(this.status, {this.output = ''});

  final LibboxdServiceStatus status;
  final String output;
}

/// Controls the standalone libboxd executable. This deliberately uses the
/// daemon's CLI so it works on Windows SCM and Linux systemd alike.
class LibboxdServiceManager {
  LibboxdServiceManager([this._executablePath]);

  final String? _executablePath;

  Future<String> resolveExecutable() async {
    final candidates = <String>[
      ..._optional(_executablePath),
      '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}libboxd${Platform.isWindows ? '.exe' : ''}',
      '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}bin${Platform.pathSeparator}libboxd${Platform.isWindows ? '.exe' : ''}',
    ];
    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        AppLogger.debug('Resolved executable: $candidate', source: 'libboxd');
        return candidate;
      }
    }
    AppLogger.error(
      'Executable not found; checked: ${candidates.join(', ')}',
      source: 'libboxd',
    );
    throw StateError(
      'libboxd executable is not bundled with this application. '
      'Rebuild the desktop target to copy it from the libbox build output.',
    );
  }

  Future<LibboxdServiceResult> run(
    String action, {
    required String basePath,
    String workingPath = '',
    String tempPath = '',
    String locale = '',
    bool elevated = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    AppLogger.info(
      'Service action started: action=$action elevated=$elevated '
      'basePath=$basePath workingPath=${_displayOptional(workingPath)} '
      'tempPath=${_displayOptional(tempPath)} locale=${_displayOptional(locale)}',
      source: 'libboxd',
    );
    try {
      final executable = await resolveExecutable();
      final args = <String>[action, '--base-path', basePath];
      if (workingPath.trim().isNotEmpty) {
        args.addAll(['--working-path', workingPath]);
      }
      if (tempPath.trim().isNotEmpty) {
        args.addAll(['--temp-path', tempPath]);
      }
      if (locale.trim().isNotEmpty) {
        args.addAll(['--locale', locale]);
      }
      final result = elevated
          ? await _runElevated(executable, args)
          : await Process.run(executable, args);
      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      if (stdout.isNotEmpty) {
        AppLogger.info('stdout:\n$stdout', source: 'libboxd');
      }
      if (stderr.isNotEmpty) {
        AppLogger.warning('stderr:\n$stderr', source: 'libboxd');
      }
      final output = [
        stdout,
        stderr,
      ].where((value) => value.isNotEmpty).join('\n');
      AppLogger.info(
        'Service action exited: action=$action exitCode=${result.exitCode} '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
        source: 'libboxd',
      );
      if (result.exitCode != 0) {
        throw ProcessException(executable, args, output, result.exitCode);
      }
      final status = action == 'status'
          ? _parseStatus(output)
          : LibboxdServiceStatus.unknown;
      return LibboxdServiceResult(status, output: output);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Service action failed: action=$action '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
        source: 'libboxd',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<ProcessResult> _runElevated(String executable, List<String> args) {
    if (Platform.isWindows) {
      final nonce = '${pid}_${DateTime.now().microsecondsSinceEpoch}';
      final stdoutPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'target_libboxd_$nonce.stdout.log';
      final stderrPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'target_libboxd_$nonce.stderr.log';
      final elevatedCommand =
          "try { & ${_powershellQuote(executable)} "
          "${args.map(_powershellQuote).join(' ')} "
          "1> ${_powershellQuote(stdoutPath)} "
          "2> ${_powershellQuote(stderrPath)}; "
          "exit \$LASTEXITCODE } catch { "
          "\$_ | Out-File -LiteralPath ${_powershellQuote(stderrPath)} "
          "-Encoding utf8; exit 1 }";
      final encodedCommand = _encodePowerShellCommand(elevatedCommand);
      AppLogger.info(
        'Requesting Windows administrator privileges',
        source: 'libboxd',
      );
      return Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "\$out = ${_powershellQuote(stdoutPath)}; "
            "\$err = ${_powershellQuote(stderrPath)}; "
            "try { "
            "\$p = Start-Process -FilePath 'powershell.exe' "
            "-ArgumentList ${_powershellQuote('-NoProfile -NonInteractive -EncodedCommand $encodedCommand')} "
            "-Verb RunAs -Wait -PassThru; "
            "\$code = \$p.ExitCode "
            "} finally { "
            "if (Test-Path -LiteralPath \$out) { "
            "[Console]::Out.Write((Get-Content -Raw -LiteralPath \$out)); "
            "Remove-Item -LiteralPath \$out -Force }; "
            "if (Test-Path -LiteralPath \$err) { "
            "[Console]::Error.Write((Get-Content -Raw -LiteralPath \$err)); "
            "Remove-Item -LiteralPath \$err -Force } }; "
            "if (\$null -eq \$code) { exit 1 } else { exit \$code }",
      ]);
    }
    if (Platform.isMacOS) {
      final command = [executable, ...args].map(_shellQuote).join(' ');
      return Process.run('osascript', [
        '-e',
        'do shell script ${_appleScriptQuote(command)} with administrator privileges',
      ]);
    }
    return _runPkexecOrSudo(executable, args);
  }

  Future<ProcessResult> _runPkexecOrSudo(
    String executable,
    List<String> args,
  ) async {
    try {
      final pkexec = await Process.run('pkexec', [executable, ...args]);
      if (pkexec.exitCode != 127) return pkexec;
    } on ProcessException {
      // Fall through to sudo on minimal Linux installations.
    }
    return Process.run('sudo', [executable, ...args]);
  }

  String _powershellQuote(String value) => "'${value.replaceAll("'", "''")}'";

  String _encodePowerShellCommand(String command) {
    final bytes = <int>[];
    for (final codeUnit in command.codeUnits) {
      bytes
        ..add(codeUnit & 0xff)
        ..add(codeUnit >> 8);
    }
    return base64Encode(bytes);
  }

  String _shellQuote(String value) => "'${value.replaceAll("'", "'\\''")}'";

  String _appleScriptQuote(String value) =>
      '"${value.replaceAll('\\', '\\\\').replaceAll('"', '${String.fromCharCode(92)}"')}"';

  Future<Process> launch({
    required String basePath,
    String workingPath = '',
    String tempPath = '',
    String locale = '',
  }) async {
    AppLogger.info(
      'Daemon launch started: basePath=$basePath '
      'workingPath=${_displayOptional(workingPath)} '
      'tempPath=${_displayOptional(tempPath)} locale=${_displayOptional(locale)}',
      source: 'libboxd',
    );
    try {
      final executable = await resolveExecutable();
      final args = <String>['--base-path', basePath];
      if (workingPath.trim().isNotEmpty) {
        args.addAll(['--working-path', workingPath]);
      }
      if (tempPath.trim().isNotEmpty) {
        args.addAll(['--temp-path', tempPath]);
      }
      if (locale.trim().isNotEmpty) {
        args.addAll(['--locale', locale]);
      }
      final process = await Process.start(executable, args);
      AppLogger.info(
        'Daemon process started: pid=${process.pid}',
        source: 'libboxd',
      );
      return process;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Daemon launch failed',
        source: 'libboxd',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  LibboxdServiceStatus _parseStatus(String output) {
    final value = output.toLowerCase();
    if (value.contains('running')) return LibboxdServiceStatus.running;
    if (value.contains('stopped')) return LibboxdServiceStatus.stopped;
    if (value.contains('not installed') || value.contains('does not exist')) {
      return LibboxdServiceStatus.notInstalled;
    }
    return LibboxdServiceStatus.unknown;
  }

  List<String> _optional(String? value) =>
      value == null || value.isEmpty ? const [] : [value];

  String _displayOptional(String value) =>
      value.trim().isEmpty ? '<default>' : value;
}
