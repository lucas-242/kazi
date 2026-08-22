import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/presenter/widgets/service_filter_chips.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_app.dart';

/// The filter row is the one thing on the services tab that escapes the page's
/// horizontal padding, so its geometry is worth pinning down.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<TestAppHarness> pumpServicesTab(WidgetTester tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
    );
    await app.pump(tester);
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await settle(tester);
    return app;
  }

  Finder viewportOf(Finder chips) => find.descendant(
    of: chips,
    matching: find.byType(SingleChildScrollView),
  );

  testWidgets('the scroll spans the full width of the screen', (tester) async {
    final app = await pumpServicesTab(tester);
    final width = app.surfaceSize.width;

    final viewport = viewportOf(find.byType(ServiceFilterChips));

    expect(tester.getTopLeft(viewport).dx, moreOrLessEquals(0, epsilon: 0.5));
    expect(
      tester.getTopRight(viewport).dx,
      moreOrLessEquals(width, epsilon: 0.5),
    );
  });

  testWidgets('the gutter is carried by the chips, not by the scroll', (
    tester,
  ) async {
    await pumpServicesTab(tester);

    final chips = find.byType(ServiceFilterChips);
    // What the rest of the page is indented by.
    final gutter = tester.getTopLeft(chips).dx;
    expect(gutter, greaterThan(0));

    expect(
      tester.widget<SingleChildScrollView>(viewportOf(chips)).padding,
      EdgeInsets.symmetric(horizontal: gutter),
    );
    // So at rest the first chip still lines up with the header above it, and
    // the last one lands on the same margin once the row is scrolled home.
    expect(
      tester.getTopLeft(find.byType(KaziChip).first).dx,
      moreOrLessEquals(gutter, epsilon: 0.5),
    );
  });
}
