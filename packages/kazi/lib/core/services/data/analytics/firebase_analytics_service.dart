import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kazi/core/services/data/analytics/analytics_scrubber.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The Firebase sink. Receives key events only; the filtering lives in
/// [CompositeAnalyticsService].
final class FirebaseAnalyticsService implements AnalyticsService {
  /// A factory, not an instance: `FirebaseAnalytics.instance` throws when no
  /// Firebase app is initialised, and resolving it eagerly would raise that
  /// during provider construction, where no guard in this class can catch it.
  FirebaseAnalyticsService(this._analyticsFactory, this._crashlyticsService);

  final FirebaseAnalytics Function() _analyticsFactory;
  final CrashlyticsService _crashlyticsService;

  FirebaseAnalytics get _analytics => _analyticsFactory();

  /// Firebase throws on a longer name rather than ignoring it.
  static const int _maxPropertyNameLength = 24;

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) => _guard(
    () => _analytics.logEvent(
      name: event.name,
      parameters: parameters.isEmpty ? null : _forFirebase(parameters),
    ),
  );

  @override
  Future<void> screen(
    String name, {
    Map<String, Object> parameters = const {},
  }) => _guard(
    () => _analytics.logScreenView(
      screenName: name,
      parameters: parameters.isEmpty ? null : _forFirebase(parameters),
    ),
  );

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  }) => _guard(() async {
    await _analytics.setUserId(id: userId);
    await _setProperties(properties);
  });

  @override
  Future<void> setUserProperties(Map<String, Object> properties) =>
      _guard(() => _setProperties(properties));

  @override
  Future<void> reset() => _guard(() async {
    await _analytics.setUserId();
    await _analytics.resetAnalyticsData();
  });

  /// Silences the SDK itself, so the automatic events (`session_start`,
  /// `screen_view`, …) stop too — which the call-site gate cannot do.
  Future<void> setCollectionEnabled(bool enabled) =>
      _guard(() => _analytics.setAnalyticsCollectionEnabled(enabled));

  Future<void> _setProperties(Map<String, Object> properties) async {
    for (final entry in AnalyticsScrubber.scrub(properties).entries) {
      if (!_isValidPropertyName(entry.key)) continue;
      await _analytics.setUserProperty(
        name: entry.key,
        value: _asString(entry.value),
      );
    }
  }

  /// `logEvent` asserts on anything that is not a `String` or a `num`, so one
  /// boolean parameter takes the call down in debug builds. Booleans become
  /// `1`/`0` so they still aggregate as a rate in the console.
  static Map<String, Object> _forFirebase(Map<String, Object> parameters) {
    final coerced = <String, Object>{};
    for (final entry in AnalyticsScrubber.scrub(parameters).entries) {
      final value = entry.value;
      coerced[entry.key] = switch (value) {
        bool() => value ? 1 : 0,
        num() || String() => value,
        _ => value.toString(),
      };
    }
    return coerced;
  }

  static String _asString(Object value) => switch (value) {
    bool() => value ? 'true' : 'false',
    _ => value.toString(),
  };

  static bool _isValidPropertyName(String name) =>
      name.isNotEmpty &&
      name.length <= _maxPropertyNameLength &&
      RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(name);

  /// Swallowed on purpose: every caller sits on a path the user is walking, and
  /// none may fail because a measurement did.
  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
    }
  }
}
