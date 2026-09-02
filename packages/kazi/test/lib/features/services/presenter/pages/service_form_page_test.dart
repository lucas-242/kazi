import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_app.dart';

/// The form's own shape: the bar that leaves it, the footer that submits it,
/// and the date row that replaces its own chip with the day it picked.
void main() {
  Future<TestAppHarness> openTheForm(WidgetTester tester) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');
    await app.pump(tester);

    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    return app;
  }

  ServiceFormController formOf(TestAppHarness app) =>
      app.container.read(serviceFormControllerProvider().notifier);

  testWidgets('it is closed with a cross, never a chevron', (tester) async {
    await openTheForm(tester);

    expect(find.byType(KaziCloseButton), findsOneWidget);
    expect(find.byType(KaziBackButton), findsNothing);
  });

  testWidgets('the button that registers is in the footer, not in the form', (
    tester,
  ) async {
    await openTheForm(tester);

    final button = find.descendant(
      of: find.byType(KaziFormFooter),
      matching: find.text(KaziLocalizations.current.registerService),
    );
    expect(button, findsOneWidget);
    // Reachable without scrolling, which is the point of it sitting there.
    expect(tester.getCenter(button).dy, greaterThan(0));
  });

  testWidgets('the date is three chips, today picked', (tester) async {
    await openTheForm(tester);

    expect(find.text(KaziLocalizations.current.today), findsOneWidget);
    expect(find.text(KaziLocalizations.current.yesterday), findsOneWidget);
    expect(find.text(KaziLocalizations.current.pickDate), findsOneWidget);
    // The calendar only exists behind the third chip.
    expect(find.byType(KaziDatePicker), findsNothing);
  });

  testWidgets('picking a day replaces the chip label with that day', (
    tester,
  ) async {
    final app = await openTheForm(tester);

    final picked = DateTime(DateTime.now().year, 3, 14);
    formOf(app).onChangeServiceDate(picked);
    await settle(tester);

    expect(find.text(KaziLocalizations.current.pickDate), findsNothing);
    expect(find.text(DateFormat.MMMd().format(picked)), findsOneWidget);
  });

  testWidgets('the note field is labelled Observação', (tester) async {
    await openTheForm(tester);

    expect(
      find.text(KaziLocalizations.current.observation.toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text(KaziLocalizations.current.description.toUpperCase()),
      findsNothing,
    );
  });
}
