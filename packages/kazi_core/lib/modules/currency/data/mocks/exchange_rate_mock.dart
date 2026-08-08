import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_history_repository.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';

/// Fixed rates (units per 1 USD) for tests and kazi_companies. Approximate.
abstract class ExchangeRateMock {
  static final Map<String, double> rates = {
    'USD': 1,
    'BRL': 5.2,
    'CAD': 1.37,
    'ARS': 1497,
    'BOB': 12.12,
    'CLP': 914,
    'COP': 3180,
    'CRC': 454,
    'CUP': 24,
    'DOP': 58.27,
    'GTQ': 7.63,
    'HNL': 26.82,
    'HTG': 130.77,
    'MXN': 17.22,
    'NIO': 36.79,
    'PAB': 1,
    'PEN': 3.38,
    'PYG': 7500,
    'UYU': 40.23,
    'VES': 756.71,
    'ZAR': 16.34,
    'NGN': 1600,
    'XOF': 568.93,
    'XAF': 568.93,
    'KES': 129,
    'UGX': 3700,
    'MAD': 9.32,
    'ETB': 161.2,
    'AOA': 925.42,
    'GHS': 11.74,
    'EUR': 0.87,
    'GBP': 0.74,
    'CHF': 0.81,
    'JPY': 158.21,
    'CNY': 6.76,
    'KRW': 1423.48,
    'SGD': 1.28,
    'INR': 83,
    'AED': 3.6725,
    'SAR': 3.75,
    'TRY': 47.65,
    'RUB': 81.29,
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

/// In-memory daily history. Also the kazi_core default, so an app without a
/// shared rate store (kazi_companies) still resolves today's rates from the API
/// instead of blowing up on an unimplemented provider.
final class InMemoryExchangeRateHistoryRepository
    implements ExchangeRateHistoryRepository {
  InMemoryExchangeRateHistoryRepository([
    Map<String, ExchangeRates>? seed,
  ]) : _byDate = {...?seed};

  final Map<String, ExchangeRates> _byDate;

  @override
  Future<Map<String, ExchangeRates>> getRange(Iterable<String> dateKeys) async {
    return {
      for (final key in dateKeys)
        if (_byDate[key] != null) key: _byDate[key]!,
    };
  }

  @override
  Future<ExchangeRates?> getNearestBefore(String dateKey) async {
    final keys = _byDate.keys
        .where((key) => key.compareTo(dateKey) <= 0)
        .toList()
      ..sort();
    return keys.isEmpty ? null : _byDate[keys.last];
  }

  @override
  Future<void> putIfAbsent(String dateKey, ExchangeRates rates) async {
    _byDate.putIfAbsent(dateKey, () => rates);
  }
}
