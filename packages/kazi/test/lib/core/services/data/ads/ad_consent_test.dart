import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/ads/ad_consent.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/fakes/fake_ad_consent_service.dart';
import '../../../../../utils/fakes/fake_crashlytics_service.dart';

void main() {
  late FakeAdConsentService service;
  late FakeCrashlyticsService crashlytics;
  late ProviderContainer container;

  setUp(() {
    service = FakeAdConsentService();
    crashlytics = FakeCrashlyticsService();
    container = ProviderContainer(
      overrides: [
        adConsentServiceProvider.overrideWithValue(service),
        crashlyticsServiceProvider.overrideWithValue(crashlytics),
      ],
    );
    addTearDown(container.dispose);
  });

  test('no ad may be requested before consent is gathered', () {
    expect(container.read(adConsentProvider), isFalse);
  });

  test('records what UMP answers once consent is gathered', () async {
    await container.read(adConsentProvider.notifier).gather();
    expect(service.gatherCount, 1);
    expect(container.read(adConsentProvider), isTrue);

    service.canRequest = false;
    await container.read(adConsentProvider.notifier).gather();
    expect(container.read(adConsentProvider), isFalse);
  });

  test(
    'a failed gather is reported and still reads the persisted status',
    () async {
      service.gatherError = Exception('offline');

      await container.read(adConsentProvider.notifier).gather();

      expect(crashlytics.loggedExceptions, hasLength(1));
      expect(container.read(adConsentProvider), isTrue);
    },
  );

  test('the privacy options form re-reads the status when closed', () async {
    await container.read(adConsentProvider.notifier).gather();
    service.canRequest = false;

    await container.read(adConsentProvider.notifier).showPrivacyOptions();

    expect(service.privacyOptionsCount, 1);
    expect(container.read(adConsentProvider), isFalse);
  });
}
