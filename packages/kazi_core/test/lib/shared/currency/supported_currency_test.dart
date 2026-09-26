import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  setUpAll(() => KaziLocalizations.load(const Locale('en')));

  group('SupportedCurrency.matchesSearch', () {
    test('matches the ISO code, the symbol and the localized name', () {
      expect(SupportedCurrency.brl.matchesSearch('brl'), isTrue);
      expect(SupportedCurrency.brl.matchesSearch(r'R$'), isTrue);
      expect(SupportedCurrency.brl.matchesSearch('real'), isTrue);
      expect(SupportedCurrency.brl.matchesSearch('  REAL '), isTrue);
    });

    test('an empty query matches everything', () {
      for (final currency in SupportedCurrency.values) {
        expect(currency.matchesSearch(''), isTrue);
        expect(currency.matchesSearch('   '), isTrue);
      }
    });

    test('does not match an unrelated currency', () {
      expect(SupportedCurrency.brl.matchesSearch('euro'), isFalse);
      expect(SupportedCurrency.eur.matchesSearch('brl'), isFalse);
    });
  });

  group('SupportedCurrency', () {
    test('every currency has a rate in the mock, so pickers never dead-end',
        () {
      for (final currency in SupportedCurrency.values) {
        expect(
          ExchangeRateMock.rates[currency.isoCode],
          isNotNull,
          reason: 'missing mock rate for ${currency.isoCode}',
        );
      }
    });

    test('ISO codes and symbols are unique', () {
      final codes = SupportedCurrency.values.map((c) => c.isoCode).toSet();
      final symbols = SupportedCurrency.values.map((c) => c.symbol).toSet();

      expect(codes, hasLength(SupportedCurrency.values.length));
      expect(symbols, hasLength(SupportedCurrency.values.length));
    });

    test('fromCode falls back for unknown and empty codes', () {
      expect(SupportedCurrency.fromCode('MXN'), SupportedCurrency.mxn);
      expect(SupportedCurrency.fromCode('mxn'), SupportedCurrency.mxn);
      expect(SupportedCurrency.fromCode('ZZZ'), SupportedCurrency.usd);
      expect(SupportedCurrency.fromCode(null), SupportedCurrency.usd);
      expect(
        SupportedCurrency.fromCode('', fallback: SupportedCurrency.brl),
        SupportedCurrency.brl,
      );
    });

    test('fromCountryCode maps the shared-currency blocks', () {
      expect(SupportedCurrency.fromCountryCode('SN'), SupportedCurrency.xof);
      expect(SupportedCurrency.fromCountryCode('ml'), SupportedCurrency.xof);
      expect(SupportedCurrency.fromCountryCode('CM'), SupportedCurrency.xaf);
      expect(SupportedCurrency.fromCountryCode('PT'), SupportedCurrency.eur);
      expect(SupportedCurrency.fromCountryCode('TR'), SupportedCurrency.tryLira);
      // Unmapped and dollarized countries land on USD.
      expect(SupportedCurrency.fromCountryCode('EC'), SupportedCurrency.usd);
      expect(SupportedCurrency.fromCountryCode(null), SupportedCurrency.usd);
    });
  });
}
