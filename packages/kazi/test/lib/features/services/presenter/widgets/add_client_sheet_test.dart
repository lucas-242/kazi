import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/widgets/add_client_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_app.dart';
import '../../../../../utils/test_helper.dart';

/// The quick-add sheet's namesake warning: what it says, and what each of the
/// two answers does. See features/services/README.md.
void main() {
  TestHelper.loadAppLocalizations();

  KaziLocalizations l10n() => KaziLocalizations.current;

  /// Opens the service form and the client quick-add sheet over it.
  Future<TestAppHarness> openTheSheet(WidgetTester tester) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');
    await app.pump(tester);

    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    // The second "+ New" is the client's; the first belongs to the catalog.
    await tester.tap(find.text(l10n().newShort).at(1));
    await settle(tester);
    return app;
  }

  Finder sheetFields() => find.descendant(
    of: find.byType(AddClientSheet),
    matching: find.byType(TextField),
  );

  Future<void> fillAndConfirm(
    WidgetTester tester, {
    required String name,
  }) async {
    await tester.enterText(sheetFields().at(0), name);
    await tester.enterText(sheetFields().at(1), '11988887777');
    await settle(tester);
    await tester.tap(find.text(l10n().createAndUse));
    await settle(tester);
  }

  testWidgets('a namesake stops the creation and offers the two answers', (
    tester,
  ) async {
    final app = await openTheSheet(tester);
    await app.seedClient(name: 'Ana Maria');

    await fillAndConfirm(tester, name: 'Ana Maria');

    expect(find.byType(KaziNote), findsOneWidget);
    // Nothing was written: the tap asked the question rather than answering it.
    expect((await app.firestore.collection('clients').get()).docs, hasLength(1));

    // Both answers are radios, one of them chosen, and "create anyway" is the
    // one the sheet was already on its way to giving.
    final options = find.byType(OptionTile);
    expect(options, findsNWidgets(2));
    expect(find.text(l10n().useExistingClient('Ana Maria')), findsOneWidget);
    expect(find.text(l10n().createAnyway), findsOneWidget);
    expect(
      tester.widgetList<OptionTile>(options).map((tile) => tile.mark),
      everyElement(OptionMark.radio),
    );
    expect(
      tester.widgetList<OptionTile>(options).where((tile) => tile.selected),
      hasLength(1),
    );
  });

  testWidgets('the warning counts the services when the client has them', (
    tester,
  ) async {
    final app = await openTheSheet(tester);
    final clientId = await app.seedClient(name: 'Ana Maria');
    // Written straight onto the document: the counters are denormalized there
    // and the warning must read them without a second query.
    await app.firestore.collection('clients').doc(clientId).update({
      'servicesCount': 12,
    });

    await fillAndConfirm(tester, name: 'Ana Maria');

    expect(find.text(l10n().clientNamesake(12, 'Ana Maria')), findsOneWidget);
  });

  testWidgets('it counts the services when the counters never ran', (
    tester,
  ) async {
    final app = await openTheSheet(tester);
    final catalogItemId = await app.seedCatalogItem(name: 'Pedicure');
    final clientId = await app.seedClient(name: 'Ana Maria');
    // No `servicesCount` on the document — a client whose services predate the
    // counters. The aggregate is what keeps the name qualified.
    for (var index = 0; index < 3; index++) {
      await app.seedService(
        catalogItemId: catalogItemId,
        date: DateTime.now(),
        clientId: clientId,
      );
    }

    await fillAndConfirm(tester, name: 'Ana Maria');

    expect(find.text(l10n().clientNamesake(3, 'Ana Maria')), findsOneWidget);
  });

  testWidgets('it names the last service when there is no count', (
    tester,
  ) async {
    final app = await openTheSheet(tester);
    final clientId = await app.seedClient(name: 'Ana Maria');
    await app.firestore.collection('clients').doc(clientId).update({
      'lastServiceName': 'Manicure',
      'lastServiceDate': Timestamp.fromDate(DateTime(2026, 3, 14)),
    });

    await fillAndConfirm(tester, name: 'Ana Maria');

    expect(
      find.text(
        l10n().clientNamesakeLastService(
          'Ana Maria',
          'Manicure',
          DateFormatUtils.day(DateTime(2026, 3, 14), locale: 'en'),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a client with neither is named on its own', (tester) async {
    final app = await openTheSheet(tester);
    await app.seedClient(name: 'Ana Maria');

    await fillAndConfirm(tester, name: 'Ana Maria');

    expect(find.text(l10n().clientNamesakePlain('Ana Maria')), findsOneWidget);
  });

  testWidgets('choosing the existing client selects it and writes nothing', (
    tester,
  ) async {
    final app = await openTheSheet(tester);
    await app.seedClient(name: 'Ana Maria');

    await fillAndConfirm(tester, name: 'Ana Maria');
    await tester.tap(find.text(l10n().useExistingClient('Ana Maria')));
    await settle(tester);
    await tester.tap(find.text(l10n().confirm));
    await settle(tester);

    expect(find.byType(AddClientSheet), findsNothing);
    expect((await app.firestore.collection('clients').get()).docs, hasLength(1));

    final state = app.container
        .read(serviceFormControllerProvider())
        .requireValue;
    expect(state.service.clientName, 'Ana Maria');
  });

  testWidgets('creating anyway writes the second client', (tester) async {
    final app = await openTheSheet(tester);
    await app.seedClient(name: 'Ana Maria');

    await fillAndConfirm(tester, name: 'Ana Maria');
    // The second tap is the decision: the warning has been seen and answered.
    await tester.tap(find.text(l10n().createAndUse));
    await settle(tester);

    expect(find.byType(AddClientSheet), findsNothing);
    expect((await app.firestore.collection('clients').get()).docs, hasLength(2));
  });
}
