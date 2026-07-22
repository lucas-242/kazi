import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';

/// Pure currency conversion using a base-relative rates snapshot.
///
/// Rates are units per one [ExchangeRates.base]. Converting `from -> to` is
/// `value / rate(from) * rate(to)`. When [from] equals [to], or either rate is
/// missing/invalid, the original [value] is returned unchanged so callers
/// degrade gracefully (e.g. legacy services with no snapshot).
abstract class CurrencyConverter {
  static double convert({
    required double value,
    required SupportedCurrency from,
    required SupportedCurrency to,
    required ExchangeRates rates,
  }) {
    if (from == to) return value;

    final fromRate = rates.rateFor(from);
    final toRate = rates.rateFor(to);

    if (fromRate == null || toRate == null || fromRate == 0) {
      return value;
    }

    return value / fromRate * toRate;
  }
}
