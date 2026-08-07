import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_history_repository.dart';
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
