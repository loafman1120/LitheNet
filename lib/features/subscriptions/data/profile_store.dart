import 'dart:convert';
import 'dart:io';

import 'subscription_parser.dart';

abstract class AtomicProfileStore {
  Future<ParsedProfile?> currentFor(String subscriptionId);
  Future<void> backup(ParsedProfile profile);
  Future<ParsedProfile> replaceAtomically(ParsedProfile profile);
  Future<void> rollback(String subscriptionId);
}

class InMemoryProfileStore implements AtomicProfileStore {
  final Map<String, ParsedProfile> _profiles = {};
  final Map<String, ParsedProfile> _backups = {};

  @override
  Future<ParsedProfile?> currentFor(String subscriptionId) async {
    return _profiles[subscriptionId];
  }

  @override
  Future<void> backup(ParsedProfile profile) async {
    _backups[profile.subscriptionId] = profile;
  }

  @override
  Future<ParsedProfile> replaceAtomically(ParsedProfile profile) async {
    _profiles[profile.subscriptionId] = profile;
    return profile;
  }

  @override
  Future<void> rollback(String subscriptionId) async {
    final backup = _backups[subscriptionId];
    if (backup != null) {
      _profiles[subscriptionId] = backup;
    }
  }
}

class FileProfileStore implements AtomicProfileStore {
  FileProfileStore(this.directory);

  final Directory directory;

  @override
  Future<ParsedProfile?> currentFor(String subscriptionId) async {
    final file = _profileFile(subscriptionId);
    if (!await file.exists()) {
      return null;
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      return ParsedProfile.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> backup(ParsedProfile profile) async {
    final current = _profileFile(profile.subscriptionId);
    if (!await current.exists()) {
      return;
    }
    await directory.create(recursive: true);
    final backup = _backupFile(profile.subscriptionId);
    if (await backup.exists()) {
      await backup.delete();
    }
    await current.copy(backup.path);
  }

  @override
  Future<ParsedProfile> replaceAtomically(ParsedProfile profile) async {
    await directory.create(recursive: true);
    final file = _profileFile(profile.subscriptionId);
    final temp = File('${file.path}.tmp');
    final json = const JsonEncoder.withIndent('  ').convert(profile.toJson());
    await temp.writeAsString('$json\n', flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await temp.rename(file.path);
    return profile;
  }

  @override
  Future<void> rollback(String subscriptionId) async {
    final backup = _backupFile(subscriptionId);
    if (!await backup.exists()) {
      return;
    }
    final current = _profileFile(subscriptionId);
    if (await current.exists()) {
      await current.delete();
    }
    await backup.copy(current.path);
  }

  File _profileFile(String subscriptionId) {
    return File('${directory.path}${Platform.pathSeparator}'
        '${_safeFileName(subscriptionId)}.json');
  }

  File _backupFile(String subscriptionId) {
    return File('${directory.path}${Platform.pathSeparator}'
        '${_safeFileName(subscriptionId)}.bak.json');
  }

  String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_');
  }
}
