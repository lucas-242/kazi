import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_event_tile.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/presenter/pages/service_details_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The agenda tab end to end: a booked service drawn on its day, opened from
/// the grid, and the details' writes coming back to it.
void main() {
  // The fake clock reads the start of the day, so the booking starts then:
  // the details offer finishing only once a service has started.
  final today = DateTime(2026, 10, 22);

  Future<TestAppHarness> appWithOneBooking(WidgetTester tester) async {
    final app = TestAppHarness(now: today);
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      startTime: const ClockTime(0, 0),
      duration: const Duration(hours: 1),
    );
    await app.pump(tester);
    return app;
  }

  Future<void> openTheAgenda(WidgetTester tester) async {
    await tester.tap(find.byIcon(LucideIcons.calendar));
    await settle(tester);
  }

  Future<void> openTheBooking(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AgendaEventTile),
        matching: find.text('Manicure'),
      ),
    );
    await settle(tester);
  }

  testWidgets('the tab draws the day and opens a booking from the grid', (
    tester,
  ) async {
    final app = await appWithOneBooking(tester);

    await openTheAgenda(tester);
    expect(app.location, AppPage.agenda.route);
    expect(find.byType(AgendaEventTile), findsOneWidget);

    await openTheBooking(tester);
    expect(app.location, AppPage.serviceDetails.route);
    expect(find.byType(ServiceDetailsPage), findsOneWidget);
  });

  testWidgets('finishing in the details repaints the tile', (tester) async {
    final app = await appWithOneBooking(tester);
    await openTheAgenda(tester);
    await openTheBooking(tester);

    await tester.tap(find.text(KaziLocalizations.current.markAsFinished));
    await settle(tester);
    await tester.tap(find.byType(KaziBackButton));
    await settle(tester);

    expect(
      app.container.read(agendaControllerProvider).services.single.isFinished,
      isTrue,
    );
    expect(
      find.descendant(
        of: find.byType(AgendaEventTile),
        matching: find.byIcon(LucideIcons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('deleting in the details lands back on the agenda', (
    tester,
  ) async {
    final app = await appWithOneBooking(tester);
    await openTheAgenda(tester);
    await openTheBooking(tester);

    await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.delete));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.deletePermanently));
    await settle(tester);

    expect(app.location, AppPage.agenda.route);
    expect(find.byType(AgendaEventTile), findsNothing);
    expect(
      (await app.firestore.collection('services').get()).docs,
      isEmpty,
    );
  });
}
