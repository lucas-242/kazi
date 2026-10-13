import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// Marking a service finished from the details screen — and taking it back.
///
/// Field-scoped and patched in memory like the other two stamps, so what this
/// checks is the screen: the button, the row the stamp shows in, the undo, and
/// that cancelling and finishing never both stay on offer.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<void> openTheDetails(WidgetTester tester) async {
    await tester.tap(find.byIcon(LucideIcons.list));
    await settle(tester);
    await tester.tap(find.text('Manicure').first);
    await settle(tester);
  }

  Future<void> openTheMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
    await settle(tester);
  }

  Service landingService(TestAppHarness app) =>
      app.container.read(serviceLandingControllerProvider).services.single;

  Service dashboardService(TestAppHarness app) =>
      app.container.read(dashboardControllerProvider).services.single;

  Future<Map<String, dynamic>> stored(TestAppHarness app) async =>
      (await app.firestore.collection('services').get()).docs.single.data();

  Future<TestAppHarness> appWithOneService(
    WidgetTester tester, {
    DateTime? cancelledAt,
    DateTime? finishedAt,
    ClockTime? startTime,
    Duration? duration,
  }) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      cancelledAt: cancelledAt,
      finishedAt: finishedAt,
      startTime: startTime,
      duration: duration,
    );
    await app.pump(tester);
    return app;
  }

  Finder markAsFinished() =>
      find.text(KaziLocalizations.current.markAsFinished);

  testWidgets('marking writes the stamp once and shows where it landed', (
    tester,
  ) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester);

    await tester.tap(markAsFinished());
    await settle(tester);

    expect((await stored(app))['finishedAt'], isNotNull);
    expect(landingService(app).isFinished, isTrue);
    expect(dashboardService(app).isFinished, isTrue);
    expect(
      find.text(KaziLocalizations.current.finishedAtLabel),
      findsOneWidget,
    );
    expect(
      find.text(KaziLocalizations.current.unmarkAsFinished),
      findsOneWidget,
    );
  });

  testWidgets('the mark is undone from its snackbar', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester);
    await tester.tap(markAsFinished());
    await settle(tester);

    await tester.tap(find.text(KaziLocalizations.current.undo));
    await settle(tester);

    expect((await stored(app))['finishedAt'], isNull);
    expect(landingService(app).isFinished, isFalse);
  });

  testWidgets('unmarking puts it back, and undoing restores the stamp', (
    tester,
  ) async {
    final stamp = today.add(const Duration(minutes: 1));
    final app = await appWithOneService(tester, finishedAt: stamp);
    await openTheDetails(tester);

    await tester.tap(find.text(KaziLocalizations.current.unmarkAsFinished));
    await settle(tester);
    expect((await stored(app))['finishedAt'], isNull);

    await tester.tap(find.text(KaziLocalizations.current.undo));
    await settle(tester);
    expect(landingService(app).finishedAt, stamp);
  });

  testWidgets('a finished service offers no cancelling', (tester) async {
    await appWithOneService(tester, finishedAt: today);
    await openTheDetails(tester);

    await openTheMenu(tester);

    expect(find.text(KaziLocalizations.current.cancelService), findsNothing);
    expect(find.text(KaziLocalizations.current.delete), findsOneWidget);
  });

  testWidgets('a cancelled service offers no finishing', (tester) async {
    await appWithOneService(tester, cancelledAt: today);
    await openTheDetails(tester);

    expect(markAsFinished(), findsNothing);
  });

  testWidgets('a booked service shows its slot and length', (tester) async {
    await appWithOneService(
      tester,
      startTime: const ClockTime(0, 0),
      duration: const Duration(minutes: 90),
    );
    await openTheDetails(tester);

    expect(
      find.text(
        '00:00 – 01:30 · '
        '${DurationFormatUtils.short(const Duration(minutes: 90))}',
      ),
      findsOneWidget,
    );
  });
}
