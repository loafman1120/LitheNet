import '../../../data/models/subscription.dart';
import 'profile_store.dart';
import 'subscription_errors.dart';
import 'subscription_fetcher.dart';
import 'subscription_headers.dart';
import 'subscription_parser.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionUpdateResult> updateOne(Subscription subscription);
}

class SubscriptionUpdateResult {
  const SubscriptionUpdateResult({
    required this.subscription,
    required this.status,
    required this.changed,
    required this.profileChanged,
    required this.duration,
    this.errorCode,
    this.message,
    this.profile,
  });

  final Subscription subscription;
  final SubscriptionUpdateStatus status;
  final bool changed;
  final bool profileChanged;
  final Duration duration;
  final String? errorCode;
  final String? message;
  final ParsedProfile? profile;
}

class DefaultSubscriptionRepository implements SubscriptionRepository {
  DefaultSubscriptionRepository({
    SubscriptionFetcher? fetcher,
    SubscriptionParser? parser,
    SubscriptionHeaderParser? headerParser,
    AtomicProfileStore? store,
  })  : _fetcher = fetcher ?? HttpSubscriptionFetcher(),
        _parser = parser ?? const AutoSubscriptionParser(),
        _headerParser = headerParser ?? const SubscriptionHeaderParser(),
        _store = store ?? InMemoryProfileStore();

  final SubscriptionFetcher _fetcher;
  final SubscriptionParser _parser;
  final SubscriptionHeaderParser _headerParser;
  final AtomicProfileStore _store;

  @override
  Future<SubscriptionUpdateResult> updateOne(Subscription subscription) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _fetcher.fetch(subscription);
      final metadata = _headerParser.parse(result.headers);
      if (result.notModified) {
        return SubscriptionUpdateResult(
          subscription: _applyMetadata(subscription, metadata).copyWith(
            updateStatus: SubscriptionUpdateStatus.noChange,
            lastUpdatedAt: DateTime.now(),
            lastError: '',
          ),
          status: SubscriptionUpdateStatus.noChange,
          changed: false,
          profileChanged: false,
          duration: stopwatch.elapsed,
        );
      }

      final current = await _store.currentFor(subscription.id);
      if (current != null) {
        await _store.backup(current);
      }
      final parsed = await _parser.parse(result, subscription);
      final stored = await _store.replaceAtomically(parsed);
      final profileChanged = current?.rawHash != stored.rawHash;

      return SubscriptionUpdateResult(
        subscription: _applyMetadata(subscription, metadata).copyWith(
          name: metadata.title ?? subscription.name,
          updateStatus: SubscriptionUpdateStatus.updated,
          lastUpdatedAt: DateTime.now(),
          activeProfileId: stored.id,
          nodeCount: stored.nodeCount,
          lastError: '',
        ),
        status: SubscriptionUpdateStatus.updated,
        changed: true,
        profileChanged: profileChanged,
        duration: stopwatch.elapsed,
        profile: stored,
      );
    } on SubscriptionException catch (error) {
      await _store.rollback(subscription.id);
      return SubscriptionUpdateResult(
        subscription: subscription.copyWith(
          updateStatus: SubscriptionUpdateStatus.failed,
          lastError: error.message,
        ),
        status: SubscriptionUpdateStatus.failed,
        changed: false,
        profileChanged: false,
        duration: stopwatch.elapsed,
        errorCode: error.code,
        message: error.message,
      );
    } on Object catch (error) {
      await _store.rollback(subscription.id);
      return SubscriptionUpdateResult(
        subscription: subscription.copyWith(
          updateStatus: SubscriptionUpdateStatus.failed,
          lastError: error.toString(),
        ),
        status: SubscriptionUpdateStatus.failed,
        changed: false,
        profileChanged: false,
        duration: stopwatch.elapsed,
        errorCode: SubscriptionErrorCodes.parse,
        message: error.toString(),
      );
    }
  }

  Subscription _applyMetadata(
    Subscription subscription,
    SubscriptionHeaderMetadata metadata,
  ) {
    return subscription.copyWith(
      updateIntervalSeconds:
          metadata.updateIntervalSeconds ?? subscription.updateIntervalSeconds,
      uploadBytes: metadata.uploadBytes ?? subscription.uploadBytes,
      downloadBytes: metadata.downloadBytes ?? subscription.downloadBytes,
      totalBytes: metadata.totalBytes ?? subscription.totalBytes,
      expiresAt: metadata.expiresAt ?? subscription.expiresAt,
      webPageUrl: metadata.webPageUrl ?? subscription.webPageUrl,
      supportUrl: metadata.supportUrl ?? subscription.supportUrl,
      movedPermanentlyTo:
          metadata.movedPermanentlyTo ?? subscription.movedPermanentlyTo,
      lastEtag: metadata.etag ?? subscription.lastEtag,
      lastModified: metadata.lastModified ?? subscription.lastModified,
      profileTitle: metadata.title ?? subscription.profileTitle,
    );
  }
}
