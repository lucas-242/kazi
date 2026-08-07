import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  final rates = ExchangeRates(
    rates: const {
      'USD': 1,
      'BRL': 5,
      'CAD': 2,
      'UGX': 4000,
    },
  );

  double? convert(SupportedCurrency from, SupportedCurrency to, double value) =>
      CurrencyConverter.convert(
        value: value,
        from: from,
        to: to,
        rates: rates,
      );

  group('CurrencyConverter', () {
    test('returns the same value when from == to', () {
      expect(
        convert(SupportedCurrency.brl, SupportedCurrency.brl, 42),
        42,
      );
    });

    test('converts from base (USD) to another currency', () {
      expect(convert(SupportedCurrency.usd, SupportedCurrency.brl, 10), 50);
    });

    test('converts to base (USD) from another currency', () {
      expect(convert(SupportedCurrency.brl, SupportedCurrency.usd, 50), 10);
    });

    test('converts between two non-base currencies', () {
      // 10 BRL -> 2 USD -> 4 CAD
      expect(convert(SupportedCurrency.brl, SupportedCurrency.cad, 10), 4);
    });

    test('handles a zero-decimal currency numerically', () {
      // 1 USD -> 4000 UGX
      expect(convert(SupportedCurrency.usd, SupportedCurrency.ugx, 1), 4000);
    });

    test('returns null when a rate is missing', () {
      final partial = ExchangeRates(rates: const {'USD': 1});
      expect(
        CurrencyConverter.convert(
          value: 99,
          from: SupportedCurrency.usd,
          to: SupportedCurrency.ngn,
          rates: partial,
        ),
        isNull,
      );
    });

    test('returns null when a rate is zero or negative', () {
      final broken = ExchangeRates(rates: const {'USD': 1, 'BRL': 0});
      expect(
        CurrencyConverter.convert(
          value: 99,
          from: SupportedCurrency.brl,
          to: SupportedCurrency.usd,
          rates: broken,
        ),
        isNull,
      );
    });
  });
}
