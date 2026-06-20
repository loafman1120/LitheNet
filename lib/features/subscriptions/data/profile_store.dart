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
