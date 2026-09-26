import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
import 'package:kazi_core/kazi_core.dart';

/// The counters are read far more often than they are written, and the read is
/// where the currency rule can quietly break.
void main() {
  const usd = SupportedCurrency.usd;
  const brl = SupportedCurrency.brl;
  const dateKey = '2026-08-20';

  final rates = RateBook(
    byDate: {
      dateKey: ExchangeRates(rates: {'USD': 1, 'BRL': 5}),
    },
  );

  RecordCounters counters({
    int count = 0,
    Map<String, ({double generated, double commission})> byCurrency = const {},
    Map<String, int> byCatalogItem = const {},
  }) => RecordCounters(
    count: count,
    byCurrency: byCurrency,
    byCatalogItem: byCatalogItem,
  );

  group('fromMap', () {
    test('Should read what the writes put there', () {
      final result = RecordCounters.fromMap({
        'servicesCount': 12,
        'totals': {
          'USD': {'generated': 4280, 'commission': 1712},
        },
        'mostUsedServices': {'item-1': 7},
      }, 'servicesCount');

      expect(result.count, 12);
      expect(result.byCurrency['USD']?.commission, 1712);
      expect(result.byCatalogItem['item-1'], 7);
    });

    // A record written before the counters existed simply has none.
    test('Should read a document with no counters as missing', () {
      final result = RecordCounters.fromMap({'name': 'Marina'}, 'servicesCount');

      expect(result.isMissing, isTrue);
      expect(result.count, 0);
    });

    test('Should tell a real zero apart from an absent one', () {
      final result = RecordCounters.fromMap({
        'servicesCount': 0,
        'totals': {
          'USD': {'generated': 0, 'commission': 0},
        },
      }, 'servicesCount');

      expect(result.isMissing, isFalse);
    });
  });

  group('converting', () {
    test('Should add a currency that needs no conversion as it is', () {
      final result = counters(
        byCurrency: {'USD': (generated: 100, commission: 40)},
      ).commissionIn(
        usd,
        rateBook: rates,
        legacyCurrency: usd,
        dateKey: dateKey,
      );

      expect(result.amount, 40);
      expect(result.unconverted, 0);
    });

    test('Should convert every currency before adding them', () {
      final result = counters(
        byCurrency: {
          'USD': (generated: 100, commission: 40),
          'BRL': (generated: 500, commission: 200),
        },
      ).commissionIn(
        usd,
        rateBook: rates,
        legacyCurrency: usd,
        dateKey: dateKey,
      );

      // 40 USD + 200 BRL at 5:1 = 40 + 40.
      expect(result.amount, 80);
      expect(result.unconverted, 0);
    });

    // The whole reason the totals are stored split: 100 BRL must never enter a
    // USD total as 100.
    test('Should leave out a currency it has no rate for', () {
      final result = counters(
        byCurrency: {
          'USD': (generated: 100, commission: 40),
          'BRL': (generated: 500, commission: 200),
        },
      ).commissionIn(
        usd,
        rateBook: const RateBook.empty(),
        legacyCurrency: usd,
        dateKey: dateKey,
      );

      expect(result.amount, 40);
      expect(result.unconverted, 1);
    });

    // A service registered before currencies existed reads as the profile
    // default, exactly as `Service.currencyOr` reads it.
    test('Should read the legacy key as the default currency', () {
      final result = counters(
        byCurrency: {
          RecordCounters.legacyCurrencyKey: (generated: 100, commission: 40),
        },
      ).commissionIn(
        brl,
        rateBook: rates,
        legacyCurrency: brl,
        dateKey: dateKey,
      );

      expect(result.amount, 40);
      expect(result.unconverted, 0);
    });

    test('Should convert the gross by the same rules', () {
      final result = counters(
        byCurrency: {'BRL': (generated: 500, commission: 200)},
      ).generatedIn(
        usd,
        rateBook: rates,
        legacyCurrency: usd,
        dateKey: dateKey,
      );

      expect(result.amount, 100);
    });
  });

  group('topCatalogItemId', () {
    test('Should name the item with the most services', () {
      final result = counters(
        byCatalogItem: {'item-1': 3, 'item-2': 9, 'item-3': 1},
      );

      expect(result.topCatalogItemId, 'item-2');
    });

    test('Should be null when nothing has been tallied', () {
      expect(counters().topCatalogItemId, isNull);
    });
  });
}
