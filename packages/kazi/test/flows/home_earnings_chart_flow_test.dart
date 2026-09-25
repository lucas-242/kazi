import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The home's sparkline buckets the cycle by hand instead of going through
/// `ServiceTotals`, so it is the one aggregation that can start counting
/// cancelled work as money still coming without any other total moving.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  String amount(double value) =>
      NumberFormatUtils.formatCurrencyIn(value, SupportedCurrency.usd);

  Future<TestAppHarness> pumpWithACancelledService(WidgetTester tester) async {
    final app = TestAppHarness();
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
    );
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      value: 700,
      cancelledAt: today,
    );
    await app.pump(tester);
    return app;
  }

  testWidgets('the sparkline leaves cancelled work out of its buckets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpWithACancelledService(tester);
    await settle(tester);

    // Opening already named: the untouched hint is what an unselected chart
    // reads out, and today's bucket is selected before anyone touches it.
    expect(
      find.bySemanticsLabel(KaziLocalizations.current.earningsChartHint),
      findsNothing,
    );

    // The chart opens on today's bucket, so the figure behind today's bar is
    // already stated and no touch is needed. The caption is "<dia> · <valor>",
    // and it is what the chart also reads out — the amounts elsewhere on the
    // screen carry no separator.
    Finder captionEndingIn(double value) => find.bySemanticsLabel(
      RegExp('${RegExp.escape(' · ${amount(value)}')}\$'),
    );

    expect(captionEndingIn(100), findsWidgets);
    expect(captionEndingIn(800), findsNothing);
    expect(captionEndingIn(700), findsNothing);

    semantics.dispose();
  });
}
