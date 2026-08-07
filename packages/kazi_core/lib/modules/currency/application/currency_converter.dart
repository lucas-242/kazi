import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';

/// Pure currency conversion using a base-relative rates snapshot.
///
/// Rates are units per one [ExchangeRates.base]. Converting `from -> to` is
/// `value / rate(from) * rate(to)`. When [from] equals [to] the value is
/// returned untouched (no rounding drift from a round trip).
///
/// A missing or invalid rate returns **null**, never the original value:
/// handing back an unconverted amount makes an amount in one currency look like
/// an amount in another, which is how mixed-currency totals silently went wrong.
/// Callers must surface the null instead of showing a number.
abstract class CurrencyConverter {
  static double? convert({
    required double value,
    required SupportedCurrency from,
    required SupportedCurrency to,
    required ExchangeRates rates,
  }) {
    if (from == to) return value;

    final fromRate = rates.rateFor(from);
    final toRate = rates.rateFor(to);

    if (fromRate == null || toRate == null || fromRate <= 0 || toRate <= 0) {
      return null;
    }

    return value / fromRate * toRate;
  }
}
