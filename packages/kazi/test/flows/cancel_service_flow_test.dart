import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// Calling a service off from the details screen.
///
/// The write is field-scoped and the lists are patched in memory, exactly as
/// the payment stamp is — so what this checks is that one tap reaches Firestore
/// once, leaves the row on screen, takes the money out of the totals, and can
/// be undone from its own snackbar.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<void> openTheServicesTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
  }

  Future<void> openTheDetails(WidgetTester tester) async {
    await openTheServicesTab(tester);
    await tester.tap(find.text('Manicure').first);
    await settle(tester);
  }

  Future<void> openTheMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_horiz));
    await settle(tester);
  }

  Service landingService(TestAppHarness app) =>
      app.container.read(serviceLandingControllerProvider).services.single;

  Service dashboardService(TestAppHarness app) =>
      app.container.read(dashboardControllerProvider).services.single;

  Future<TestAppHarness> appWithOneService(
    WidgetTester tester, {
    DateTime? cancelledAt,
  }) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      cancelledAt: cancelledAt,
    );
    await app.pump(tester);
    return app;
  }

  Future<void> cancelFromTheMenu(WidgetTester tester) async {
    await openTheMenu(tester);
    await tester.tap(find.text(KaziLocalizations.current.cancelService).last);
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.cancelService).last);
    await settle(tester);
  }

  testWidgets('the menu asks before calling a service off', (tester) async {
    await appWithOneService(tester);
    await openTheDetails(tester);

    await openTheMenu(tester);
    await tester.tap(find.text(KaziLocalizations.current.cancelService).last);
    await settle(tester);

    expect(
      find.text(KaziLocalizations.current.cancelServiceTitle('Manicure')),
      findsOneWidget,
    );
  });

  testWidgets('confirming writes the cancellation once', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester);

    await cancelFromTheMenu(tester);

    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['cancelledAt'], isNotNull);
    expect(landingService(app).isCancelled, isTrue);
    expect(dashboardService(app).isCancelled, isTrue);
  });

  /// The record stays in the list that feeds the rows; it is the money that
  /// leaves.
  testWidgets('the service stays listed and the totals drop it', (
    tester,
  ) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester);

    await cancelFromTheMenu(tester);

    final landing = app.container.read(serviceLandingControllerProvider);
    expect(landing.visibleServices.single.id, landingService(app).id);
    expect(landing.totals.commission, 0);
    expect(landing.totals.value, 0);
  });

  testWidgets('the cancellation is undone from its snackbar', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester);
    await cancelFromTheMenu(tester);

    await tester.tap(find.text(KaziLocalizations.current.undo));
    await settle(tester);

    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['cancelledAt'], isNull);
    expect(landingService(app).isCancelled, isFalse);
    expect(dashboardService(app).isCancelled, isFalse);
  });

  /// A cancelled service is owed nothing, so the screen's one CTA goes away and
  /// the menu offers the way back instead.
  testWidgets('a cancelled service offers reopening, not receiving', (
    tester,
  ) async {
    final app = await appWithOneService(tester, cancelledAt: today);
    await openTheDetails(tester);

    expect(
      find.widgetWithText(
        KaziElevatedButton,
        KaziLocalizations.current.markAsReceived,
      ),
      findsNothing,
    );

    await openTheMenu(tester);
    await tester.tap(find.text(KaziLocalizations.current.reopenService).last);
    await settle(tester);

    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['cancelledAt'], isNull);
    expect(landingService(app).isCancelled, isFalse);
  });
}
