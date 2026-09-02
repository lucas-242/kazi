import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_landing_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// No shortcut in the app opens a screen of its own: every one of them lands
/// on the services tab with a filter applied and visible in the chips, so the
/// filters are learned once and stay editable where the rows are.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<TestAppHarness> pumpWithData(WidgetTester tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
    );
    await app.pump(tester);
    return app;
  }

  Future<void> tapShortcut(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await settle(tester);
    await tester.tap(button);
    await settle(tester);
  }

  testWidgets('"see in the list" lands on the list, filtered to today', (
    tester,
  ) async {
    final app = await pumpWithData(tester);

    await tapShortcut(tester, KaziLocalizations.current.seeInList);

    expect(app.location, AppPage.services.route);
    expect(find.byType(ServiceLandingPage), findsOneWidget);

    final landing = app.container.read(serviceLandingControllerProvider);
    expect(landing.view, ServiceView.list);
    expect(landing.fastSearch, FastSearch.today);
  });

  testWidgets('"see the summary" lands on the summary', (tester) async {
    final app = await pumpWithData(tester);

    // The label names the cycle's month, so it is rebuilt the way the row
    // builds it.
    final month = DateFormat.MMMM().format(
      app.container.read(dashboardControllerProvider).cycleRange!.start,
    );
    final summaryRow = find.text(
      KaziLocalizations.current.seeSummaryOf(
        '${month[0].toUpperCase()}${month.substring(1)}',
      ),
    );
    await tester.ensureVisible(summaryRow);
    await settle(tester);
    await tester.tap(summaryRow);
    await settle(tester);

    expect(app.location, AppPage.services.route);
    expect(
      app.container.read(serviceLandingControllerProvider).view,
      ServiceView.summary,
    );
  });

  // The chips are what makes an applied filter undoable where the rows are.
  testWidgets('the applied period is visible as a chip', (tester) async {
    await pumpWithData(tester);

    await tapShortcut(tester, KaziLocalizations.current.seeInList);

    expect(
      find.widgetWithText(KaziChip, KaziLocalizations.current.today),
      findsOneWidget,
    );
  });
}
