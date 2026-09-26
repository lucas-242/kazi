import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';

/// Accumulates the events a flow emits, in order.
class FakeAnalyticsService implements AnalyticsService {
  final List<({AnalyticsEvent event, Map<String, Object> parameters})> logged =
      [];

  /// Screen names reported, in order — so a test can assert a navigation was
  /// measured without reaching into the router.
  final List<String> screens = [];

  /// Every property map handed over, whether by `identify` or
  /// `setUserProperties`, merged in arrival order.
  final Map<String, Object> userProperties = {};

  String? identifiedUserId;
  int resetCount = 0;

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

  @override
  Future<void> screen(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    screens.add(name);
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  }) async {
    identifiedUserId = userId;
    userProperties.addAll(properties);
  }

  @override
  Future<void> setUserProperties(Map<String, Object> properties) async {
    userProperties.addAll(properties);
  }

  @override
  Future<void> reset() async {
    resetCount++;
    identifiedUserId = null;
    userProperties.clear();
  }
}
