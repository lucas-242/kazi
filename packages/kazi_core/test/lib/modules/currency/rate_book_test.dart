import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  ExchangeRates ratesOn(String dateKey, double brl) => ExchangeRates(
        rates: {'USD': 1, 'BRL': brl},
        fetchedAt: DateTime.parse('${dateKey}T00:00:00Z'),
      );

  group('RateBook.forDate', () {
    test('returns the exact day when present', () {
      final book = RateBook(
        byDate: {
          '2026-03-01': ratesOn('2026-03-01', 5),
          '2026-03-10': ratesOn('2026-03-10', 6),
        },
      );

      expect(book.forDate('2026-03-10')?.rateFor(SupportedCurrency.brl), 6);
    });

    test('falls back to the closest earlier day', () {
      final book = RateBook(
        byDate: {
          '2026-03-01': ratesOn('2026-03-01', 5),
          '2026-03-10': ratesOn('2026-03-10', 6),
        },
      );

      expect(book.forDate('2026-03-07')?.rateFor(SupportedCurrency.brl), 5);
    });

    test('never uses a later day', () {
      final book = RateBook(
        byDate: {'2026-03-10': ratesOn('2026-03-10', 6)},
        latest: ratesOn('2026-03-20', 7),
      );

      // Nothing on or before the date -> latest, not the 2026-03-10 snapshot
      // reached by jumping forward.
      expect(book.forDate('2026-02-01')?.rateFor(SupportedCurrency.brl), 7);
    });

    test('falls back to latest when the history does not reach that far', () {
      final book = RateBook(latest: ratesOn('2026-03-20', 7));

      expect(book.forDate('2020-01-01')?.rateFor(SupportedCurrency.brl), 7);
    });

    test('returns null when it has nothing at all', () {
      expect(const RateBook.empty().forDate('2026-03-10'), isNull);
      expect(const RateBook.empty().isEmpty, isTrue);
    });

    test('orders keys chronologically, not by insertion', () {
      final book = RateBook(
        byDate: {
          '2026-03-10': ratesOn('2026-03-10', 6),
          '2026-02-28': ratesOn('2026-02-28', 4),
          '2026-03-01': ratesOn('2026-03-01', 5),
        },
      );

      expect(book.forDate('2026-03-05')?.rateFor(SupportedCurrency.brl), 5);
      expect(book.forDate('2026-02-29')?.rateFor(SupportedCurrency.brl), 4);
    });
  });

  group('ExchangeRates', () {
    test('dateKeyOf is UTC and zero padded', () {
      expect(ExchangeRates.dateKeyOf(DateTime.utc(2026, 3, 7)), '2026-03-07');
    });

    test('round-trips through toMap/fromMap', () {
      final original = ratesOn('2026-03-10', 5.25);
      final restored = ExchangeRates.fromMap(original.toMap());

      expect(restored, isNotNull);
      expect(restored!.rateFor(SupportedCurrency.brl), 5.25);
      expect(restored.dateKey, '2026-03-10');
      expect(restored.base, SupportedCurrency.usd);
    });

    test('rejects a payload with a non-positive rate', () {
      // The daily document is written by a client, so a tampered or corrupt
      // snapshot must be discarded rather than skewing every conversion.
      expect(
        ExchangeRates.fromMap({
          'base': 'USD',
          'rates': {'USD': 1, 'BRL': 0},
        }),
        isNull,
      );
    });

    test('rejects a payload with a non-numeric rate', () {
      expect(
        ExchangeRates.fromMap({
          'base': 'USD',
          'rates': {'USD': 1, 'BRL': 'five'},
        }),
        isNull,
      );
    });

    test('rejects an empty or missing rates map', () {
      expect(ExchangeRates.fromMap({'base': 'USD', 'rates': {}}), isNull);
      expect(ExchangeRates.fromMap({'base': 'USD'}), isNull);
      expect(ExchangeRates.fromMap(null), isNull);
    });
  });
}
