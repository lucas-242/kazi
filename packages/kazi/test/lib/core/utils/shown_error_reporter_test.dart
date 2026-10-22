import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/injector.dart';
import 'package:kazi/features/services/domain/errors/services_error.dart';
import 'package:kazi/features/services/domain/errors/catalog_error.dart';
import 'package:kazi/features/clients/domain/errors/clients_error.dart';
import 'package:kazi/features/auth/domain/errors/auth_error.dart';
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

  test('a repository failure is reported by its code and root cause', () {
    final firestore = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    final error = ServicesError(
      ServicesFailure.add,
      cause: firestore,
      trace: StackTrace.empty,
    );

    report(error);

    expect(shownParameters(), {
      'code': 'services/add',
      'screen': 'unknown',
      'origin': 'DashboardController',
      'kind': 'external',
      'cause': 'cloud_firestore/unavailable',
    });
    // The service unwraps it; handing it the wrapper is what carries the code.
    expect(crashlytics.loggedExceptions, [error]);
    expect(crashlytics.loggedReasons, [
      'services/add shown by DashboardController on unknown',
    ]);
  });

  test('a business rule is reported as itself, with no cause', () {
    final refusal = ClientsError(ClientsFailure.documentTaken);
    final caughtAt = StackTrace.current;

    report(refusal, caughtAt);

    expect(shownParameters()['code'], 'clients/documentTaken');
    expect(shownParameters()['kind'], 'business_rule');
    expect(shownParameters().containsKey('cause'), isFalse);
    expect(crashlytics.loggedExceptions, [refusal]);
    expect(crashlytics.loggedTraces, [caughtAt]);
  });

  test('a bug at the root of a chain is reported as a bug', () {
    report(
      ServicesError(
        ServicesFailure.load,
        cause: CatalogError(
          CatalogFailure.load,
          cause: StateError('bad document'),
        ),
      ),
    );

    expect(shownParameters()['kind'], 'unexpected');
    expect(shownParameters()['cause'], 'StateError');
  });

  test('anything but an app error is coded by its type', () {
    report(FirebaseException(plugin: 'cloud_firestore', code: 'aborted'));

    expect(shownParameters()['code'], 'cloud_firestore/aborted');
  });

  group('failureReason', () {
    test('names the platform failure at the root', () {
      final error = AuthError(
        AuthFailure.signIn,
        cause: FirebaseException(plugin: 'firebase_auth', code: 'network'),
      );

      expect(failureReason(error), 'firebase_auth/network');
    });

    test('falls back to the code when nothing deeper failed', () {
      expect(
        failureReason(ClientsError(ClientsFailure.nameRequired)),
        'clients/nameRequired',
      );
    });
  });

  test('a failing Crashlytics does not cost analytics its event', () {
    container.dispose();
    buildContainer(crashlyticsSink: _BrokenCrashlyticsService());

    report(ClientsError(ClientsFailure.nameRequired));

    expect(analytics.events, contains(AnalyticsEvent.errorShown));
  });
}
