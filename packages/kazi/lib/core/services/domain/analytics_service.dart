import 'package:kazi/core/services/domain/analytics_event.dart';

abstract class AnalyticsService {
  /// Records [event]. Implementations must never throw and never block: a
  /// measurement failure cannot be allowed to break the flow being measured.
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  });
}
