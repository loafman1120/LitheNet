part of 'proxy_repository.dart';

bool isSingboxServiceRunning(SingboxService? service) {
  return service?.state().running ?? false;
}

bool isTunPermissionError(String message) {
  return message.contains('platform.permission_denied') ||
      message.contains('Access is denied') ||
      message.contains('administrator permission') ||
      message.contains('elevated network permission') ||
      message.contains('operation not permitted') ||
      message.contains('permission denied');
}

Future<void> restartWindowsAsAdministrator() async {
  final executable = Platform.resolvedExecutable;
  final workingDirectory = File(executable).parent.path;
  final command = 'Start-Process '
      '-FilePath ${_powerShellString(executable)} '
      '-WorkingDirectory ${_powerShellString(workingDirectory)} '
      '-Verb RunAs';
  final result = await Process.run(
    'powershell.exe',
    [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      command,
    ],
  );
  if (result.exitCode != 0) {
    throw SingboxException(
      'Administrator restart was cancelled or failed.${_processFailureDetails(result)}',
      kind: SingboxErrorKind.permission,
    );
  }
  exit(0);
}

Future<void> restartLinuxWithPkexec() async {
  final environment = <String, String>{
    if (Platform.environment['DISPLAY'] case final display?) 'DISPLAY': display,
    if (Platform.environment['WAYLAND_DISPLAY'] case final wayland?)
      'WAYLAND_DISPLAY': wayland,
    if (Platform.environment['XAUTHORITY'] case final xauthority?)
      'XAUTHORITY': xauthority,
    if (Platform.environment['XDG_RUNTIME_DIR'] case final runtimeDir?)
      'XDG_RUNTIME_DIR': runtimeDir,
  };
  final result = await Process.run(
    'pkexec',
    [
      'env',
      ...environment.entries.map((entry) => '${entry.key}=${entry.value}'),
      Platform.resolvedExecutable,
    ],
    runInShell: true,
  );
  if (result.exitCode != 0) {
    throw SingboxException(
      'Elevated restart was cancelled or failed.',
      kind: SingboxErrorKind.permission,
    );
  }
  exit(0);
}

String cleanSingboxLogMessage(String message) {
  return message.replaceAll(
    RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
    '',
  );
}

LogLevel mapSingboxLogLevel(SingboxLogEvent event, String message) {
  final parsed = _parseLogLevel(message);
  if (parsed != null) {
    return parsed;
  }

  final levelName = event.levelName.toLowerCase();
  if (levelName.contains('error') || levelName.contains('fatal')) {
    return LogLevel.error;
  }
  if (levelName.contains('warn')) {
    return LogLevel.warning;
  }
  if (levelName.contains('debug')) {
    return LogLevel.debug;
  }
  if (levelName.contains('trace')) {
    return LogLevel.trace;
  }
  return LogLevel.info;
}

String _powerShellString(String value) {
  return "'${value.replaceAll("'", "''")}'";
}

String _processFailureDetails(ProcessResult result) {
  final details = [
    result.stderr.toString().trim(),
    result.stdout.toString().trim(),
  ].where((line) => line.isNotEmpty).join(' ');
  if (details.isEmpty) {
    return '';
  }
  return ' $details';
}

LogLevel? _parseLogLevel(String message) {
  final match = RegExp(r'^\s*(TRACE|DEBUG|INFO|WARN|WARNING|ERROR|FATAL)\b')
      .firstMatch(message.toUpperCase());
  return switch (match?.group(1)) {
    'TRACE' => LogLevel.trace,
    'DEBUG' => LogLevel.debug,
    'INFO' => LogLevel.info,
    'WARN' || 'WARNING' => LogLevel.warning,
    'ERROR' || 'FATAL' => LogLevel.error,
    _ => null,
  };
}
