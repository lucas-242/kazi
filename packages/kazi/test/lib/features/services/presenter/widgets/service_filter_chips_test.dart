import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/presenter/widgets/service_view_switch.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_app.dart';

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
    await tester.tap(find.byIcon(LucideIcons.list));
    await settle(tester);
    return app;
  }

  testWidgets('the first chip lines up with the page gutter', (tester) async {
    await pumpServicesTab(tester);

    // The switch above is full width, bounded by the same page padding, so
    // its own left edge is the gutter every other control in this header
    // lines up against.
    final gutter = tester.getTopLeft(find.byType(ServiceViewSwitch)).dx;

    expect(
      tester.getTopLeft(find.byType(KaziChip).first).dx,
      moreOrLessEquals(gutter, epsilon: 0.5),
    );
  });
}
