import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_details_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// Marking a service as received.
///
/// `ServiceReceiptController` is the single writer of the payment stamp, and
/// it deliberately patches the dashboard and the services list in memory
/// rather than refetching — the repository reads cache-first, so a refetch
/// could hand back the state from before the tap. That is exactly what this
/// checks: one write, both lists correct, and an undo that puts everything
/// back.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<void> openTheServicesTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
  }

  /// Opens the details of the only seeded service by tapping its row.
  Future<void> openTheDetails(WidgetTester tester, TestAppHarness app) async {
    await openTheServicesTab(tester);
    await tester.tap(find.text('Manicure').first);
    await settle(tester);
  }

  /// The receipt toggle lives in the app bar. Scoped there on purpose: the
  /// "received on <date>" row in the body uses the same outline icon, so an
  /// unscoped finder matches two widgets once the service is stamped.
  Finder receiptButton(IconData icon) =>
      find.descendant(of: find.byType(KaziAppBar), matching: find.byIcon(icon));

  Future<void> tapTheReceiptButton(
    WidgetTester tester, {
    IconData icon = Icons.check_circle_outline,
  }) async {
    await tester.tap(receiptButton(icon));
    await settle(tester);
  }

  Service landingService(TestAppHarness app) =>
      app.container.read(serviceLandingControllerProvider).services.single;

  Service dashboardService(TestAppHarness app) =>
      app.container.read(dashboardControllerProvider).services.single;

  Future<TestAppHarness> appWithOneService(
    WidgetTester tester, {
    DateTime? receivedAt,
  }) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      receivedAt: receivedAt,
    );
    await app.pump(tester);
    return app;
  }

  testWidgets('a service starts out unreceived in both lists', (tester) async {
    final app = await appWithOneService(tester);
    await openTheServicesTab(tester);

    expect(landingService(app).isReceived, isFalse);
    expect(dashboardService(app).isReceived, isFalse);
  });

  testWidgets('tapping the details button stamps the service', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester, app);
    expect(app.location, AppPage.serviceDetails.route);
    expect(find.byType(ServiceDetailsPage), findsOneWidget);

    await tapTheReceiptButton(tester);

    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['receivedAt'], isNotNull);
  });

  testWidgets('the stamp reaches the services list without a refetch', (
    tester,
  ) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester, app);

    await tapTheReceiptButton(tester);

    expect(landingService(app).isReceived, isTrue);
  });

  testWidgets('the stamp reaches the dashboard too', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester, app);

    await tapTheReceiptButton(tester);

    expect(dashboardService(app).isReceived, isTrue);
  });

  testWidgets('the details screen switches to the received button', (
    tester,
  ) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester, app);

    await tapTheReceiptButton(tester);

    expect(receiptButton(Icons.check_circle), findsOneWidget);
    expect(receiptButton(Icons.check_circle_outline), findsNothing);
  });

  testWidgets('tapping again clears the stamp everywhere', (tester) async {
    final app = await appWithOneService(tester);
    await openTheDetails(tester, app);

    await tapTheReceiptButton(tester);
    await tapTheReceiptButton(tester, icon: Icons.check_circle);

    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['receivedAt'], isNull);
    expect(landingService(app).isReceived, isFalse);
    expect(dashboardService(app).isReceived, isFalse);
  });

  testWidgets('the undo replays exactly the ids that were written', (
    tester,
  ) async {
    final app = await appWithOneService(tester);
    await openTheServicesTab(tester);

    // Re-read per call: the controller is auto-disposed, so holding the
    // notifier across an await would use a Ref that is already gone — which is
    // exactly why the screens read it fresh at every tap.
    ServiceReceiptController receipt() =>
        app.container.read(serviceReceiptControllerProvider.notifier);

    final written = await receipt().setReceived([
      landingService(app),
    ], received: true);
    await settle(tester);
    expect(written, hasLength(1));
    expect(landingService(app).isReceived, isTrue);

    await receipt().setReceivedByIds(written, received: false);
    await settle(tester);

    expect(landingService(app).isReceived, isFalse);
    expect(dashboardService(app).isReceived, isFalse);
    final stored = await app.firestore.collection('services').get();
    expect(stored.docs.single.data()['receivedAt'], isNull);
  });

  testWidgets('an already-received service opens showing it', (tester) async {
    final app = await appWithOneService(tester, receivedAt: today);
    await openTheDetails(tester, app);

    expect(receiptButton(Icons.check_circle), findsOneWidget);
    expect(landingService(app).isReceived, isTrue);
  });
}
