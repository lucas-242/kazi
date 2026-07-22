import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// Fetches fiat rates from the free, keyless open.er-api.com endpoint
/// (base USD). Response shape: `{ "result": "success", "rates": { "BRL": 5.1, ... } }`.
final class ApiExchangeRateRepository implements ExchangeRateRepository {
  ApiExchangeRateRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint =
      Uri.parse('https://open.er-api.com/v6/latest/USD');

  @override
  Future<ExchangeRates> getRates() async {
    try {
      final response = await _client.get(_endpoint);

      if (response.statusCode != 200) {
        throw ExternalError(
          'Error to fetch exchange rates: HTTP ${response.statusCode}',
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final rawRates = body['rates'] as Map<String, dynamic>?;

      if (rawRates == null) {
        throw ExternalError('Error to fetch exchange rates: missing rates');
      }

      final rates = <String, double>{};
      for (final currency in SupportedCurrency.values) {
        final value = rawRates[currency.isoCode];
        if (value is num) {
          rates[currency.isoCode] = value.toDouble();
        }
      }

      return ExchangeRates(rates: rates);
    } on AppError {
      rethrow;
    } catch (error, trace) {
      throw ExternalError('Error to fetch exchange rates', trace: trace);
    }
  }
}
