import 'dart:math';

import 'package:kazi/core/services/data/analytics/firebase_analytics_service.dart';
import 'package:kazi/core/services/data/analytics/posthog_analytics_service.dart';
import 'package:kazi/core/services/data/analytics/session_replay_policy.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Decides, once per launch, whether this session is measured and recorded.
///
/// Both SDKs come up silent from `main` because the answers here need Remote
/// Config, which is only fetched on the splash. The cost is that the splash is
/// never recorded; the alternative leaks a first session from someone who had
/// said no.
class AnalyticsBootstrap {
  AnalyticsBootstrap({
    required FirebaseAnalyticsService firebase,
    required PostHogAnalyticsService postHog,
    Random? random,
  }) : _firebase = firebase,
       _postHog = postHog,
       _random = random ?? Random();

  final FirebaseAnalyticsService _firebase;
  final PostHogAnalyticsService _postHog;
  final Random _random;

  /// Idempotent — re-run whenever the user changes their mind in the menu.
  ///
  /// Silences the SDKs rather than only the call sites, so the automatic events
  /// neither sink routes through this app's code stop as well.
  Future<void> applyConsent({
    required bool analyticsAllowed,
    required bool replayAllowed,
  }) async {
    await _firebase.setCollectionEnabled(analyticsAllowed);
    await _postHog.setCollectionEnabled(analyticsAllowed);

    // Replay is gated more strictly: its consent is an explicit yes, so
    // anything short of one stops the recording whatever the sampling decided.
    if (!analyticsAllowed || !replayAllowed) {
      await _postHog.stopReplay();
    }
  }

  /// The once-per-session dice roll. Call after [applyConsent]; returns whether
  /// the session is being recorded.
  Future<bool> applySampling({
    required SessionReplayPolicy policy,
    required bool replayAllowed,
    required int? accountAgeDays,
  }) async {
    if (!replayAllowed) {
      await _postHog.stopReplay();
      return false;
    }

    final shouldRecord = policy.shouldRecordAtStart(
      isNewUser: policy.isNewUser(accountAgeDays),
      roll: _random.nextDouble(),
    );

    // The `stop` branch is not a no-op: the SDK was set up with session replay
    // enabled, so enabling collection starts a recording on its own.
    if (shouldRecord) {
      await _postHog.startReplay();
    } else {
      await _postHog.stopReplay();
    }

    Log.flow('Session replay: ${shouldRecord ? 'recording' : 'sampled out'}');
    return shouldRecord;
  }

  /// Promotes a session that was not being recorded. Recording runs forward
  /// only — what came before is gone, what they do next is the part that says
  /// whether they recovered or left.
  Future<void> promoteForFriction({required SessionReplayPolicy policy}) async {
    if (!policy.shouldRecordOnFriction()) return;
    await _postHog.startReplay(restart: true);
  }
}
