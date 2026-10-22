import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/fake_subscription_service.dart';
import '../../../../../utils/fakes/fake_analytics_service.dart';
import '../../../../../utils/test_helper.dart';

void main() {
  late FakeAnalyticsService analytics;

  TestHelper.loadAppLocalizations();

  ProviderContainer containerWith(Entitlement entitlement) {
    analytics = FakeAnalyticsService();
    final container = ProviderContainer(
      overrides: [
        subscriptionServiceProvider.overrideWithValue(
          FakeSubscriptionService(entitlement: entitlement),
        ),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);
    container.listen(paywallControllerProvider, (_, _) {});
    return container;
  }

  const free = Entitlement.free();
  const trial = Entitlement(
    isPremium: true,
    isInGracePeriod: false,
    willRenew: true,
    isTrial: true,
    hasPaidBefore: false,
  );

  test('reports the trial the store actually granted', () async {
    final container = containerWith(trial);
    await container.read(paywallControllerProvider.future);

    await container.read(paywallControllerProvider.notifier).subscribe();

    expect(analytics.parametersOf(AnalyticsEvent.subscriptionStarted), {
      'is_trial': true,
    });
  });

  test('does not report a purchase that granted nothing', () async {
    final container = containerWith(free);
    await container.read(paywallControllerProvider.future);

    await container.read(paywallControllerProvider.notifier).subscribe();

    expect(analytics.events, contains(AnalyticsEvent.subscribeTapped));
    expect(
      analytics.events,
      isNot(contains(AnalyticsEvent.subscriptionStarted)),
    );
  });

  test('does not report a restore that found nothing', () async {
    final container = containerWith(free);
    await container.read(paywallControllerProvider.future);

    await container.read(paywallControllerProvider.notifier).restore();

    expect(
      analytics.events,
      isNot(contains(AnalyticsEvent.subscriptionRestored)),
    );
  });
}
