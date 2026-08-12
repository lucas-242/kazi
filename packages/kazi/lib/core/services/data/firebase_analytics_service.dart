import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

final class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics, this._crashlyticsService);

  final FirebaseAnalytics _analytics;
  final CrashlyticsService _crashlyticsService;

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) async {
    try {
      await _analytics.logEvent(
        name: event.name,
        parameters: parameters.isEmpty ? null : parameters,
      );
    } catch (exception, trace) {
      // Swallowed on purpose. Every caller sits on a path the user is walking
      // — seeding a catalog, finishing the setup — and none of them may fail
      // because a measurement did.
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
    }
  }
}
