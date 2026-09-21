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

  /// The default billing cycle is the calendar month, and a month is bucketed
  /// by day — so today's bar is the one at `day - 1`.
  ({int index, int count}) todaysBucket() {
    final start = DateTime(today.year, today.month);
    final end = DateTime(today.year, today.month + 1, 0);
    return (index: today.day - 1, count: end.difference(start).inDays + 1);
  }

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

    final chart = find.bySemanticsLabel(
      KaziLocalizations.current.earningsChartHint,
    );
    await tester.ensureVisible(chart);
    await settle(tester);

    // Touching a bar is the only way the figure behind it is ever stated.
    final rect = tester.getRect(chart);
    final bucket = todaysBucket();
    final slot = rect.width / bucket.count;
    await tester.tapAt(
      Offset(rect.left + (bucket.index + 0.5) * slot, rect.center.dy),
    );
    await settle(tester);

    // The caption is "<dia> · <valor>", and it is what the chart also reads
    // out — the amounts elsewhere on the screen carry no separator.
    Finder captionEndingIn(double value) => find.bySemanticsLabel(
      RegExp('${RegExp.escape(' \u00b7 ${amount(value)}')}\$'),
    );

    expect(captionEndingIn(100), findsWidgets);
    expect(captionEndingIn(800), findsNothing);
    expect(captionEndingIn(700), findsNothing);

    semantics.dispose();
  });
}
