import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';

/// Fixed rates (units per 1 USD) for tests and kazi_companies. Approximate.
abstract class ExchangeRateMock {
  static final Map<String, double> rates = {
    'USD': 1,
    'BRL': 5.2,
    'CAD': 1.37,
    'NGN': 1600,
    'KES': 129,
    'UGX': 3700,
    'PYG': 7500,
    'INR': 83,
  };

  static ExchangeRates get exchangeRates => ExchangeRates(
        rates: rates,
        fetchedAt: DateTime(2026),
      );
}

final class MockExchangeRateRepository implements ExchangeRateRepository {
  @override
  Future<ExchangeRates> getRates() async => ExchangeRateMock.exchangeRates;
}
