import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/services/data/analytics/firebase_analytics_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firebase_analytics_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAnalytics>(),
  MockSpec<CrashlyticsService>(),
])
void main() {
  late MockFirebaseAnalytics firebaseAnalytics;
  late FirebaseAnalyticsService service;

  setUp(() {
    firebaseAnalytics = MockFirebaseAnalytics();
    service = FirebaseAnalyticsService(
      () => firebaseAnalytics,
      MockCrashlyticsService(),
    );
  });

  group('screen', () {
    test('sends the page name as the screen class too', () async {
      await service.screen(AppPage.services.name);

      verify(
        firebaseAnalytics.logScreenView(
          screenName: AppPage.services.name,
          screenClass: AppPage.services.name,
        ),
      ).called(1);
    });

    test('coerces boolean parameters for Firebase', () async {
      await service.screen(AppPage.home.name, parameters: {'is_trial': true});

      verify(
        firebaseAnalytics.logScreenView(
          screenName: AppPage.home.name,
          screenClass: AppPage.home.name,
          parameters: {'is_trial': 1},
        ),
      ).called(1);
    });

    test('never throws when the SDK does', () async {
      when(
        firebaseAnalytics.logScreenView(
          screenName: anyNamed('screenName'),
          screenClass: anyNamed('screenClass'),
          parameters: anyNamed('parameters'),
        ),
      ).thenThrow(StateError('no Firebase app'));

      await expectLater(service.screen(AppPage.home.name), completes);
    });
  });
}
