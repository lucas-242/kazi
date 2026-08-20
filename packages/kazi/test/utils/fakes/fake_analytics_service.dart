import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';

/// Accumulates the events a flow emits, in order.
class FakeAnalyticsService implements AnalyticsService {
  final List<({AnalyticsEvent event, Map<String, Object> parameters})> logged =
      [];

  Iterable<AnalyticsEvent> get events => logged.map((entry) => entry.event);

  Map<String, Object>? parametersOf(AnalyticsEvent event) {
    for (final entry in logged) {
      if (entry.event == event) return entry.parameters;
    }
    return null;
  }

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) async {
    logged.add((event: event, parameters: parameters));
  }
}
