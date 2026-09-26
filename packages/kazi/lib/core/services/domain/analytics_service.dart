import 'package:kazi/core/services/domain/analytics_event.dart';

/// One facade over every analytics destination.
///
/// Callers never learn there are two: `CompositeAnalyticsService` fans out to
/// Firebase Analytics (key events only) and PostHog (everything).
abstract class AnalyticsService {
  /// Implementations must never throw and never block: a measurement failure
  /// cannot break the flow being measured.
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  });

  /// [name] is an `AppPage` name, not a raw route.
  Future<void> screen(String name, {Map<String, Object> parameters = const {}});

  /// [userId] is always the Firebase Auth uid, in both sinks, so a PostHog
  /// funnel and a Firebase audience describe the same person.
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  });

  /// The cohort attributes every funnel is broken down by.
  Future<void> setUserProperties(Map<String, Object> properties);

  /// Detaches the current identity on sign-out.
  Future<void> reset();
}
