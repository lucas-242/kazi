import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Fans one call out to both sinks, and the only place that knows there are two.
///
/// Events are filtered by [AnalyticsEvent.isKey]; identity is not, because a
/// sink with the events but not the person cannot break a funnel down by cohort.
final class CompositeAnalyticsService implements AnalyticsService {
  CompositeAnalyticsService({
    required AnalyticsService firebase,
    required AnalyticsService postHog,
    required bool Function() isEnabled,
  }) : _firebase = firebase,
       _postHog = postHog,
       _isEnabled = isEnabled;

  final AnalyticsService _firebase;
  final AnalyticsService _postHog;

  /// Read per call rather than captured, so revoking consent takes effect on the
  /// next event instead of the next launch.
  final bool Function() _isEnabled;

  /// Fails closed: the gate reads providers that can throw before an event is
  /// even built, and an unresolvable consent state is not consent.
  bool get _allowed {
    try {
      return _isEnabled();
    } catch (exception) {
      Log.error('Analytics consent gate failed: $exception');
      return false;
    }
  }

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) async {
    if (!_allowed) return;
    if (event.isKey) {
      await _isolate(() => _firebase.log(event, parameters: parameters));
    }
    await _isolate(() => _postHog.log(event, parameters: parameters));
  }

  @override
  Future<void> screen(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    if (!_allowed) return;
    await _isolate(() => _firebase.screen(name, parameters: parameters));
    await _isolate(() => _postHog.screen(name, parameters: parameters));
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  }) async {
    if (!_allowed) return;
    await _isolate(() => _firebase.identify(userId, properties: properties));
    await _isolate(() => _postHog.identify(userId, properties: properties));
  }

  @override
  Future<void> setUserProperties(Map<String, Object> properties) async {
    if (!_allowed) return;
    await _isolate(() => _firebase.setUserProperties(properties));
    await _isolate(() => _postHog.setUserProperties(properties));
  }

  /// Runs regardless of consent: forgetting who someone was is the one operation
  /// a withdrawn consent must never block.
  @override
  Future<void> reset() async {
    await _isolate(_firebase.reset);
    await _isolate(_postHog.reset);
  }

  /// Awaited separately, never through `Future.wait`: one sink throwing must not
  /// cost the other its call.
  static Future<void> _isolate(Future<void> Function() call) async {
    try {
      await call();
    } catch (exception) {
      Log.error(exception);
    }
  }
}
