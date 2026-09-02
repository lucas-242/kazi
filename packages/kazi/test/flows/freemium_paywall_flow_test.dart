import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/services/domain/feature_flag.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/subscription/domain/freemium_limits.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';
import 'package:kazi/features/subscription/presenter/widgets/paywall_view.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The freemium gate, from hitting the limit to the paywall being on screen.
///
/// The gate lives in the controller, the presentation lives in `app_shell.dart`
/// and the two only meet through `PaywallPromptController`. That handshake is
/// what this covers — plus the part that matters most: a blocked creation must
/// not be written.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final freeLimits = FreemiumLimits.forTier(UserTier.newFree);

  Future<void> openTheForm(WidgetTester tester, TestAppHarness app) async {
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
  }

  Future<void> fillAndSave(
    WidgetTester tester,
    TestAppHarness app,
    String catalogItemId,
  ) async {
    final type = app.container
        .read(serviceFormControllerProvider())
        .requireValue
        .catalogItems
        .firstWhere((catalogItem) => catalogItem.id == catalogItemId);
    app.container.read(serviceFormControllerProvider().notifier)
      ..onChangeCatalogItem(DropdownItem(value: type.id, label: type.name))
      ..onChangeServiceValue(150);
    await settle(tester);
    // Scrolled to first: the form is taller than the viewport once a type
    // is picked and the money fields appear.
    final saveButton = find.text(KaziLocalizations.current.save);
    await tester.ensureVisible(saveButton);
    await settle(tester);
    await tester.tap(saveButton);
    await settle(tester);
  }

  /// Fills the free tier's monthly quota so the next creation is the one over
  /// the line.
  Future<void> seedMonthlyQuota(TestAppHarness app, String catalogItemId) async {
    for (var index = 0; index < freeLimits.maxServicesPerMonth; index++) {
      await app.seedService(catalogItemId: catalogItemId, date: today, value: 10);
    }
  }

  testWidgets('a free user at the monthly limit gets the paywall', (
    tester,
  ) async {
    final app = TestAppHarness(isPremium: false);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await seedMonthlyQuota(app, catalogItemId);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    expect(find.byType(PaywallView), findsOneWidget);
  });

  testWidgets('the blocked service is not written', (tester) async {
    final app = TestAppHarness(isPremium: false);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await seedMonthlyQuota(app, catalogItemId);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    final written = await app.firestore.collection('services').get();
    expect(written.docs, hasLength(freeLimits.maxServicesPerMonth));
  });

  testWidgets('a blocked creation does not count towards the ad cadence', (
    tester,
  ) async {
    final app = TestAppHarness(isPremium: false);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await seedMonthlyQuota(app, catalogItemId);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    expect(app.fakes.creationAds.creationActions, 0);
  });

  testWidgets('a free user below the limit is let through', (tester) async {
    final app = TestAppHarness(isPremium: false);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(catalogItemId: catalogItemId, date: today, value: 10);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    expect(find.byType(PaywallView), findsNothing);
    final written = await app.firestore.collection('services').get();
    expect(written.docs, hasLength(2));
    expect(app.location, AppPage.services.route);
  });

  testWidgets('a premium user is never gated', (tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await seedMonthlyQuota(app, catalogItemId);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    expect(find.byType(PaywallView), findsNothing);
    final written = await app.firestore.collection('services').get();
    expect(written.docs, hasLength(freeLimits.maxServicesPerMonth + 1));
  });

  testWidgets('with payments off nothing is gated and no paywall appears', (
    tester,
  ) async {
    // The kill switch: with no paid tier to upgrade to, a limit that blocks is
    // a limit with no way out.
    final app = TestAppHarness(isPremium: false);
    app.fakes.featureFlags.set(FeatureFlag.payments, enabled: false);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await seedMonthlyQuota(app, catalogItemId);

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillAndSave(tester, app, catalogItemId);

    expect(find.byType(PaywallView), findsNothing);
    final written = await app.firestore.collection('services').get();
    expect(written.docs, hasLength(freeLimits.maxServicesPerMonth + 1));
  });
}
