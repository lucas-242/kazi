import 'package:kazi/core/services/domain/analytics_event.dart';

/// One facade over every analytics destination.
///
/// Callers never learn there are two of them: `CompositeAnalyticsService` fans
/// out to Firebase Analytics (key events only) and PostHog (everything). See
/// [AnalyticsEvent.isKey] for why the split exists.
abstract class AnalyticsService {
  /// Records [event].
  ///
  /// Implementations must never throw and never block: a measurement failure
  /// cannot be allowed to break the flow being measured.
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  });

  /// Records a screen view. [name] is an `AppPage` name, not a raw route — the
  /// enum is stable across route refactors and free of query strings.
  Future<void> screen(String name, {Map<String, Object> parameters = const {}});

  /// Binds the session to [userId] — always the Firebase Auth uid, in both
  /// sinks, so a PostHog funnel and a Firebase audience describe the same
  /// person.
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  });

  /// Updates the cohort attributes every funnel is broken down by. Without
  /// these a funnel says *that* people dropped; with them it says *which*.
  Future<void> setUserProperties(Map<String, Object> properties);

  /// Detaches the current identity on sign-out, so the next user does not
  /// inherit the previous one's profile.
  Future<void> reset();
}
