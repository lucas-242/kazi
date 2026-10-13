import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service_status.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_form_page.dart';
import 'package:kazi/features/services/presenter/pages/service_landing_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// Registering a service, from the tab to the list showing it.
///
/// The screens own the navigation and the controllers own the data, so this
/// drives the form through its controller and everything else through the UI —
/// which is the seam that actually breaks: the route, the confirm button, the
/// pop back, and the two lists that have to notice the new row.
void main() {
  // The clock is deliberately not pinned here. `Service`'s constructor
  // defaults `date` to the real `DateTime.now()` rather than going through
  // `TimeService`, so a pinned harness clock would move the list's date range
  // without moving the date the form stamps on a new service, and every
  // creation would land outside the window it is supposed to appear in.
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  /// Walks from the home tab to the service form the way a person does.
  Future<void> openTheForm(WidgetTester tester, TestAppHarness app) async {
    await tester.tap(find.byIcon(LucideIcons.list));
    await settle(tester);
    expect(app.location, AppPage.services.route);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
  }

  ServiceFormController formOf(TestAppHarness app) =>
      app.container.read(serviceFormControllerProvider().notifier);

  /// Picks [catalogItemId] in the form and types a value.
  ///
  /// Done through the controller rather than the widgets: the form's money and
  /// date fields are driven by masked controllers, and reproducing their
  /// keystrokes would test `KaziMoneyMaskedTextController`, not this flow.
  Future<void> fillForm(
    WidgetTester tester,
    TestAppHarness app, {
    required String catalogItemId,
    double value = 150,
  }) async {
    final types = app.container
        .read(serviceFormControllerProvider())
        .requireValue
        .catalogItems;
    final type = types.firstWhere(
      (catalogItem) => catalogItem.id == catalogItemId,
    );
    formOf(app)
      ..onChangeCatalogItem(DropdownItem(value: type.id, label: type.name))
      // After the type, never before: picking a type resets the value to the
      // type's default.
      ..onChangeServiceValue(value);
    await settle(tester);
  }

  // Matched inside the footer, not by the button's type: the screen's title
  // carries the same words, and the bar owns which button it draws.
  Finder saveButton() => find.descendant(
    of: find.byType(KaziFormFooter),
    matching: find.text(KaziLocalizations.current.registerService),
  );

  Future<void> save(WidgetTester tester) async {
    await tester.tap(saveButton());
    await settle(tester);
  }

  testWidgets('the services tab lists what is already there', (tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      value: 80,
    );

    await app.pump(tester);
    await tester.tap(find.byIcon(LucideIcons.list));
    await settle(tester);

    expect(find.byType(ServiceLandingPage), findsOneWidget);
    expect(
      app.container.read(serviceLandingControllerProvider).services,
      hasLength(1),
    );
  });

  testWidgets('the FAB opens the service form', (tester) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');

    await app.pump(tester);
    await openTheForm(tester, app);

    expect(app.location, AppPage.addServices.route);
    expect(find.byType(ServiceFormPage), findsOneWidget);
  });

  testWidgets('saving writes the service and returns to the list', (
    tester,
  ) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

    await app.pump(tester);
    await openTheForm(tester, app);

    await fillForm(tester, app, catalogItemId: catalogItemId);
    await save(tester);

    final written = await app.firestore.collection('services').get();
    expect(written.docs, hasLength(1));
    expect(written.docs.single.data()['value'], 150);
    expect(written.docs.single.data()['typeId'], catalogItemId);

    // Back on the list, which now has the row without a refetch of its own.
    expect(app.location, AppPage.services.route);
    expect(
      app.container.read(serviceLandingControllerProvider).services,
      hasLength(1),
    );
  });

  testWidgets('the dashboard picks the new service up too', (tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

    await app.pump(tester);
    expect(app.container.read(dashboardControllerProvider).services, isEmpty);

    await openTheForm(tester, app);
    await fillForm(tester, app, catalogItemId: catalogItemId);
    await save(tester);

    expect(
      app.container.read(dashboardControllerProvider).services,
      hasLength(1),
    );
  });

  testWidgets('a service with no type is refused and nothing is written', (
    tester,
  ) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');

    await app.pump(tester);
    await openTheForm(tester, app);

    formOf(app).onChangeServiceValue(150);
    await settle(tester);
    await save(tester);

    expect(await app.firestore.collection('services').get(), _isEmptyQuery);
    // Still on the form: a refused save must not look like a successful one.
    expect(app.location, AppPage.addServices.route);
  });

  testWidgets('a creation counts towards the interstitial cadence', (
    tester,
  ) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillForm(tester, app, catalogItemId: catalogItemId);
    await save(tester);

    expect(app.fakes.creationAds.creationActions, 1);
  });

  group('the status field', () {
    testWidgets('opens on pending, and saves nothing to say so', (
      tester,
    ) async {
      final app = TestAppHarness();
      final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

      await app.pump(tester);
      await openTheForm(tester, app);
      expect(
        find.text(KaziLocalizations.current.statusPending),
        findsOneWidget,
      );

      await fillForm(tester, app, catalogItemId: catalogItemId);
      await save(tester);

      final stored = await app.firestore.collection('services').get();
      expect(stored.docs.single.data()['receivedAt'], isNull);
      expect(stored.docs.single.data()['cancelledAt'], isNull);
    });

    testWidgets('registers a service straight into received', (tester) async {
      final app = TestAppHarness();
      final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

      await app.pump(tester);
      await openTheForm(tester, app);
      await fillForm(tester, app, catalogItemId: catalogItemId);
      await tester.tap(find.text(KaziLocalizations.current.received));
      await settle(tester);
      await save(tester);

      final stored = await app.firestore.collection('services').get();
      expect(stored.docs.single.data()['receivedAt'], isNotNull);
      expect(stored.docs.single.data()['cancelledAt'], isNull);
    });

    /// A service can be registered already called off — and it must then stay
    /// out of the list's money, the same as one cancelled later.
    testWidgets('registers a service straight into cancelled', (tester) async {
      final app = TestAppHarness();
      final catalogItemId = await app.seedCatalogItem(name: 'Manicure');

      await app.pump(tester);
      await openTheForm(tester, app);
      await fillForm(tester, app, catalogItemId: catalogItemId);
      formOf(app).onChangeServiceStatus(ServiceStatus.cancelled);
      await settle(tester);
      await save(tester);

      final stored = await app.firestore.collection('services').get();
      expect(stored.docs.single.data()['cancelledAt'], isNotNull);
      expect(
        app.container.read(serviceLandingControllerProvider).totals.commission,
        0,
      );
    });
  });

  group('the schedule fields', () {
    final quantityField = find.byWidgetPredicate(
      (widget) =>
          widget is KaziFieldInput &&
          widget.label == KaziLocalizations.current.quantity,
    );

    Future<void> openWithItem(
      WidgetTester tester,
      TestAppHarness app, {
      Duration? defaultDuration = const Duration(minutes: 90),
    }) async {
      final catalogItemId = await app.seedCatalogItem(
        name: 'Manicure',
        defaultDuration: defaultDuration,
      );
      await app.pump(tester);
      await openTheForm(tester, app);
      await fillForm(tester, app, catalogItemId: catalogItemId);
    }

    testWidgets('a service opens untimed, and saves no booking', (
      tester,
    ) async {
      final app = TestAppHarness();
      await openWithItem(tester, app);

      expect(find.text(KaziLocalizations.current.noTime), findsOneWidget);
      expect(find.byType(KaziDurationPicker), findsNothing);
      expect(quantityField, findsOneWidget);

      await save(tester);

      final stored = (await app.firestore.collection('services').get())
          .docs
          .single
          .data();
      expect(stored['startMinutes'], isNull);
    });

    testWidgets("a booking shows the item's length and where it ends", (
      tester,
    ) async {
      final app = TestAppHarness();
      await openWithItem(tester, app);

      formOf(app).onChangeServiceStartTime(const ClockTime(14, 0));
      await settle(tester);

      expect(find.text('14:00'), findsOneWidget);
      expect(find.byType(KaziDurationPicker), findsOneWidget);
      expect(
        find.text(KaziLocalizations.current.endsAtTime('15:30')),
        findsOneWidget,
      );
      expect(
        quantityField,
        findsNothing,
        reason: 'a booking is one appointment',
      );

      await save(tester);

      final stored = (await app.firestore.collection('services').get())
          .docs
          .single
          .data();
      expect(stored['startMinutes'], 840);
      expect(stored['durationMinutes'], 90);
      expect(stored['multiDay'], isFalse);
    });

    testWidgets('a new length moves the end and leaves the item alone', (
      tester,
    ) async {
      final app = TestAppHarness();
      await openWithItem(tester, app);
      formOf(app).onChangeServiceStartTime(const ClockTime(14, 0));
      await settle(tester);

      await tester.tap(
        find.text(DurationFormatUtils.short(const Duration(hours: 2))),
      );
      await settle(tester);

      expect(
        find.text(KaziLocalizations.current.endsAtTime('16:00')),
        findsOneWidget,
      );
      await save(tester);

      final item = (await app.firestore.collection('serviceTypes').get())
          .docs
          .single
          .data();
      expect(item['defaultDurationMinutes'], 90);
      final stored = (await app.firestore.collection('services').get())
          .docs
          .single
          .data();
      expect(stored['durationMinutes'], 120);
    });

    testWidgets('a booking with no length asks for one', (tester) async {
      final app = TestAppHarness();
      await openWithItem(tester, app, defaultDuration: null);

      formOf(app).onChangeServiceStartTime(const ClockTime(14, 0));
      await settle(tester);

      expect(
        find.text(KaziLocalizations.current.addDurationToBlockAgenda),
        findsOneWidget,
      );
    });

    testWidgets('"no time" unbooks it', (tester) async {
      final app = TestAppHarness();
      await openWithItem(tester, app);
      formOf(app).onChangeServiceStartTime(const ClockTime(14, 0));
      await settle(tester);

      await tester.tap(find.text(KaziLocalizations.current.noTime));
      await settle(tester);

      expect(find.byType(KaziDurationPicker), findsNothing);
      expect(
        app.container
            .read(serviceFormControllerProvider())
            .requireValue
            .service
            .startTime,
        isNull,
      );
    });

    testWidgets('a finished service offers cancelling disabled', (
      tester,
    ) async {
      final app = TestAppHarness();
      await openWithItem(tester, app);
      final service = app.container
          .read(serviceFormControllerProvider())
          .requireValue
          .service;
      formOf(app).onChangeService(service.markedFinishedAt(DateTime.now()));
      await settle(tester);

      final cancelled = tester.widget<KaziChip>(
        find.widgetWithText(
          KaziChip,
          KaziLocalizations.current.statusCancelled,
        ),
      );
      expect(cancelled.onTap, isNull);
    });
  });
}

final Matcher _isEmptyQuery = predicate(
  (query) => (query as dynamic).docs.isEmpty,
  'an empty query result',
);
