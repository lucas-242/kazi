import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:kazi_core/modules/currency/data/api_exchange_rate_repository.dart';

void main() {
  ApiExchangeRateRepository repositoryReturning(
    int statusCode,
    Object body,
  ) {
    final client = MockClient(
      (_) async => http.Response(json.encode(body), statusCode),
    );
    return ApiExchangeRateRepository(client: client);
  }

  group('ApiExchangeRateRepository.getRates', () {
    test('parses only supported currencies from a successful response',
        () async {
      final repo = repositoryReturning(200, {
        'result': 'success',
        'rates': {
          'USD': 1,
          'BRL': 5.2,
          'NGN': 1600,
          // Unsupported currency must be ignored.
          'THB': 33.09,
        },
      });

      final rates = await repo.getRates();

      expect(rates.base, SupportedCurrency.usd);
      expect(rates.rateFor(SupportedCurrency.brl), 5.2);
      expect(rates.rateFor(SupportedCurrency.ngn), 1600);
      expect(rates.rates.containsKey('THB'), isFalse);
    });

    test('throws ExternalError on non-200 status', () async {
      final repo = repositoryReturning(500, {'result': 'error'});
      expect(repo.getRates(), throwsA(isA<ExternalError>()));
    });

    test('throws ExternalError when rates are missing', () async {
      final repo = repositoryReturning(200, {'result': 'success'});
      expect(repo.getRates(), throwsA(isA<ExternalError>()));
    });
  });
}
