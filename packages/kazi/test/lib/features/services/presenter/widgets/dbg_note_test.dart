import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/presenter/widgets/add_client_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_app.dart';
import '../../../../../utils/test_helper.dart';

void main() {
  TestHelper.loadAppLocalizations();

  testWidgets('debug', (tester) async {
    final app = TestAppHarness();
    await app.seedCatalogItem(name: 'Manicure');
    await app.pump(tester);
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.newShort).at(1));
    await settle(tester);

    final id = await app.seedClient(name: 'Ana Maria');
    await app.firestore.collection('clients').doc(id).update({
      'servicesCount': 12,
      'lastServiceName': 'Manicure',
      'lastServiceDate': Timestamp.fromDate(DateTime(2026, 3, 14)),
    });

    final fields = find.descendant(
      of: find.byType(AddClientSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Ana Maria');
    await tester.enterText(fields.at(1), '11988887777');
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.createAndUse));
    await settle(tester);

    debugPrint('screen: ${app.surfaceSize}');
    final note = find.byType(KaziNote);
    debugPrint('notes: ${note.evaluate().length}');
    if (note.evaluate().isNotEmpty) {
      debugPrint('rect: ${tester.getRect(note)}');
      final text = find.descendant(of: note, matching: find.byType(Text));
      debugPrint('text: "${(text.evaluate().first.widget as Text).data}"');
      debugPrint('textRect: ${tester.getRect(text)}');
    }
    debugPrint('overflow: ${tester.takeException()}');
  });
}
