import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../utils/fakes/fake_analytics_service.dart';
import '../../../utils/fakes/fake_crashlytics_service.dart';

class _BrokenCrashlyticsService extends FakeCrashlyticsService {
  @override
  void log(Object exception, StackTrace stackTrace, {String? reason}) =>
      throw StateError('crashlytics is down');
}

void main() {
  late FakeAnalyticsService analytics;
  late FakeCrashlyticsService crashlytics;
  late ProviderContainer container;

  void buildContainer({CrashlyticsService? crashlyticsSink}) {
    container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
        crashlyticsServiceProvider.overrideWithValue(
          crashlyticsSink ?? crashlytics,
        ),
        // No router in a unit test; the screen resolves to `unknown`.
        kaziRouterProvider.overrideWith((ref) => throw UnimplementedError()),
      ],
    );
  }

  setUp(() {
    analytics = FakeAnalyticsService();
    crashlytics = FakeCrashlyticsService();
    buildContainer();
  });

  tearDown(() => container.dispose());

  void report(Object exception, [StackTrace? trace]) => reportShownError(
    container.read,
    exception,
    trace,
    origin: 'DashboardController',
  );

  Map<String, Object> shownParameters() =>
      analytics.parametersOf(AnalyticsEvent.errorShown)!;

  test('a repository failure is reported by its root cause', () {
    final firestore = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    final caughtAt = StackTrace.current;

    report(ExternalError('x', cause: firestore, trace: caughtAt));

    expect(shownParameters(), {
      'code': 'ExternalError',
      'screen': 'unknown',
      'origin': 'DashboardController',
      'kind': 'external',
      'cause': 'cloud_firestore/unavailable',
    });
    expect(crashlytics.loggedExceptions, [firestore]);
    expect(crashlytics.loggedTraces, [caughtAt]);
    expect(crashlytics.loggedReasons, [
      'ExternalError shown by DashboardController on unknown',
    ]);
  });

  test('a business rule is reported as itself, with no cause', () {
    final refusal = ClientError('repeated document');
    final caughtAt = StackTrace.current;

    report(refusal, caughtAt);

    expect(shownParameters()['kind'], 'business_rule');
    expect(shownParameters().containsKey('cause'), isFalse);
    expect(crashlytics.loggedExceptions, [refusal]);
    expect(crashlytics.loggedTraces, [caughtAt]);
  });

  test('a chain is followed to its innermost failure and trace', () {
    final bug = StateError('bad document');
    final innerTrace = StackTrace.current;

    report(
      ExternalError(
        'check failed',
        cause: ExternalError('read failed', cause: bug, trace: innerTrace),
        trace: StackTrace.empty,
      ),
    );

    expect(shownParameters()['kind'], 'unexpected');
    expect(shownParameters()['cause'], 'StateError');
    expect(crashlytics.loggedExceptions, [bug]);
    expect(crashlytics.loggedTraces, [innerTrace]);
  });

  test('a failing Crashlytics does not cost analytics its event', () {
    container.dispose();
    buildContainer(crashlyticsSink: _BrokenCrashlyticsService());

    report(ClientError('x'));

    expect(analytics.events, contains(AnalyticsEvent.errorShown));
  });
}
