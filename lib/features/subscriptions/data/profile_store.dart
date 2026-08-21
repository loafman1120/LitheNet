import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../data/storage/secret_store.dart';
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
      return ParsedProfile.fromJson(Map<String, dynamic>.from(decoded as Map));
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
    return File(
      '${directory.path}${Platform.pathSeparator}'
      '${_safeFileName(subscriptionId)}.json',
    );
  }

  File _backupFile(String subscriptionId) {
    return File(
      '${directory.path}${Platform.pathSeparator}'
      '${_safeFileName(subscriptionId)}.bak.json',
    );
  }

  String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_');
  }

  Future<void> deleteFor(String subscriptionId) async {
    for (final file in [
      _profileFile(subscriptionId),
      _backupFile(subscriptionId),
    ]) {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

class SecureProfileStore implements AtomicProfileStore {
  SecureProfileStore(this._secrets, [this._legacyStore]);

  final SecretStore _secrets;
  final FileProfileStore? _legacyStore;

  Future<void> migrateLegacyProfiles() async {
    final legacyStore = _legacyStore;
    if (legacyStore == null || !await legacyStore.directory.exists()) {
      return;
    }

    await for (final entity in legacyStore.directory.list()) {
      if (entity is! File ||
          !entity.path.endsWith('.json') ||
          entity.path.endsWith('.bak.json')) {
        continue;
      }
      try {
        final decoded = jsonDecode(await entity.readAsString());
        final profile = ParsedProfile.fromJson(
          Map<String, dynamic>.from(decoded as Map),
        );
        await replaceAtomically(profile);

        final basePath = entity.path.substring(
          0,
          entity.path.length - '.json'.length,
        );
        final backup = File('$basePath.bak.json');
        if (await backup.exists()) {
          final backupDecoded = jsonDecode(await backup.readAsString());
          final backupProfile = ParsedProfile.fromJson(
            Map<String, dynamic>.from(backupDecoded as Map),
          );
          await _secrets.write(
            _backupKey(profile.subscriptionId),
            _encode(backupProfile),
          );
        }
        await legacyStore.deleteFor(profile.subscriptionId);
      } on Object {
        // Keep unreadable legacy files in place so they can be recovered.
      }
    }
  }

  @override
  Future<ParsedProfile?> currentFor(String subscriptionId) async {
    final encoded = await _secrets.read(_key(subscriptionId));
    if (encoded != null) {
      return _decode(encoded);
    }

    final legacy = await _legacyStore?.currentFor(subscriptionId);
    if (legacy != null) {
      await replaceAtomically(legacy);
      await _legacyStore?.deleteFor(subscriptionId);
    }
    return legacy;
  }

  @override
  Future<void> backup(ParsedProfile profile) async {
    final current = await currentFor(profile.subscriptionId);
    if (current != null) {
      await _secrets.write(
        _backupKey(profile.subscriptionId),
        _encode(current),
      );
    }
  }

  @override
  Future<ParsedProfile> replaceAtomically(ParsedProfile profile) async {
    await _secrets.write(_key(profile.subscriptionId), _encode(profile));
    return profile;
  }

  @override
  Future<void> rollback(String subscriptionId) async {
    final backup = await _secrets.read(_backupKey(subscriptionId));
    if (backup != null) {
      await _secrets.write(_key(subscriptionId), backup);
    }
  }

  String _encode(ParsedProfile profile) => jsonEncode(profile.toJson());

  ParsedProfile _decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw const FormatException('Invalid secure subscription profile.');
    }
    return ParsedProfile.fromJson(Map<String, dynamic>.from(decoded));
  }

  String _key(String subscriptionId) => 'profile.${_digest(subscriptionId)}';

  String _backupKey(String subscriptionId) {
    return 'profile-backup.${_digest(subscriptionId)}';
  }

  String _digest(String value) => sha256.convert(utf8.encode(value)).toString();
}
