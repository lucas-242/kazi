import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/presenter/pages/billing_cycle_page.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_group.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The menu's four groups are ordered by what they are for: what defines your
/// earnings, what adjusts the app, what you decide about your data, what talks
/// about the app.
void main() {
  Future<TestAppHarness> openTheMenu(WidgetTester tester) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');
    await app.seedCatalogItem(name: 'Pedicure');
    await app.pump(tester);
    // The catalogue count comes from the keepAlive controller, which any
    // screen that reads the catalogue fills. The menu states it, it does not
    // fetch it.
    await app.container.read(catalogControllerProvider.notifier).onInit();
    await tester.tap(find.byIcon(Icons.tune));
    await settle(tester);
    return app;
  }

  /// Where a row sits on screen, so the order can be asserted without knowing
  /// how the list is built.
  double topOf(WidgetTester tester, String label) =>
      tester.getTopLeft(find.text(label)).dy;

  testWidgets('the pay cycle sits under "my work", not under preferences', (
    tester,
  ) async {
    await openTheMenu(tester);

    // Group titles are upper-cased at the call site.
    final myWork = topOf(
      tester,
      KaziLocalizations.current.myWork.toUpperCase(),
    );
    final preferences = topOf(
      tester,
      KaziLocalizations.current.preferences.toUpperCase(),
    );
    final cycle = topOf(tester, KaziLocalizations.current.billingCycle);

    expect(cycle, greaterThan(myWork));
    expect(cycle, lessThan(preferences));
  });

  testWidgets('the catalogue row states how many items it holds', (
    tester,
  ) async {
    await openTheMenu(tester);

    expect(find.text(KaziLocalizations.current.itemsCount(2)), findsOneWidget);
  });

  // The label is the contract: "how to use" comes before the rating ask, which
  // comes before the way out.
  testWidgets('the about group runs how-to, rate, sign out', (tester) async {
    await openTheMenu(tester);

    expect(
      topOf(tester, KaziLocalizations.current.howToUseKazi),
      lessThan(topOf(tester, KaziLocalizations.current.rateApp)),
    );
    expect(
      topOf(tester, KaziLocalizations.current.rateApp),
      lessThan(topOf(tester, KaziLocalizations.current.signOut)),
    );
  });

  // Registered as a top-level route, outside the shell's stateful branch —
  // like the currency migration gate — so it pushes over the whole app
  // rather than inside the menu tab's own navigator, which would leave the
  // bottom bar reachable mid-edit of the cycle that drives the home total.
  testWidgets('the pay cycle page pushes over the whole app, not the tab', (
    tester,
  ) async {
    final app = await openTheMenu(tester);

    await tester.tap(find.text(KaziLocalizations.current.billingCycle));
    await settle(tester);

    expect(app.location, AppPage.billingCycle.route);
    expect(find.byType(BillingCyclePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await settle(tester);

    expect(app.location, AppPage.settings.route);
  });

  // 31 is the sentinel for "the last day of the month", which is not always
  // the 31st — the row must not present it as a literal day number.
  testWidgets('the pay cycle row shows "Last" for the sentinel anchor day', (
    tester,
  ) async {
    final app = TestAppHarness();
    await app.firestore
        .collection('users')
        .doc(TestAppHarness.testUser.uid)
        .set(const MonthlyCycle(anchorDay: BillingCycle.lastDayAnchor).toMap());
    await app.pump(tester);
    await tester.tap(find.byIcon(Icons.tune));
    await settle(tester);

    expect(
      find.text(KaziLocalizations.current.billingCycleLastDay),
      findsOneWidget,
    );
    expect(
      find.text(KaziLocalizations.current.billingCycleDay(31)),
      findsNothing,
    );
  });

  // The four the document names, in order. A debug-only fifth group rides
  // along in tests, so this names the ones that ship rather than counting.
  testWidgets('the four groups render in order', (tester) async {
    await openTheMenu(tester);

    final titles = [
      KaziLocalizations.current.myWork,
      KaziLocalizations.current.preferences,
      KaziLocalizations.current.privacy,
      KaziLocalizations.current.about,
    ].map((title) => topOf(tester, title.toUpperCase())).toList();

    expect(find.byType(SettingsGroup), findsAtLeastNWidgets(4));
    expect(titles, orderedEquals(([...titles]..sort())));
  });
}
