import 'package:equatable/equatable.dart';
import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';

/// A set of daily exchange-rate snapshots, keyed by `yyyy-MM-dd`, able to
/// resolve which snapshot applies to a given date.
///
/// Resolution order is exact day, then the closest earlier day available, then
/// [latest] (today's rates) as a last resort. When nothing resolves, [forDate]
/// returns null — the signal that an amount *cannot* be converted. Callers must
/// never fall back to the raw amount, which would present a value in one
/// currency as if it were in another.
///
/// Use [forPair] when the goal is to convert: a snapshot can apply to the date
/// and still be unable to serve the currencies involved.
class RateBook extends Equatable {
  const RateBook({this.byDate = const {}, this.latest});

  const RateBook.empty() : this();

  final Map<String, ExchangeRates> byDate;
  final ExchangeRates? latest;

  bool get isEmpty => byDate.isEmpty && latest == null;

  ExchangeRates? forDate(String dateKey) {
    final exact = byDate[dateKey];
    if (exact != null) return exact;

    String? closest;
    for (final key in byDate.keys) {
      // Keys are zero-padded `yyyy-MM-dd`, so lexicographic order is
      // chronological order.
      if (key.compareTo(dateKey) > 0) continue;
      if (closest == null || key.compareTo(closest) > 0) {
        closest = key;
      }
    }

    return closest != null ? byDate[closest] : latest;
  }

  /// The snapshot for [dateKey] that can actually convert [from] into [to].
  ///
  /// Daily documents are immutable, so a currency added to the app today is
  /// absent from every snapshot written before it — permanently. Without this,
  /// adding a currency would quietly strip every older cross-currency amount
  /// out of the totals. Falling back to the newest snapshot that knows both
  /// currencies trades the historical rate for a current one, which is the same
  /// degradation already applied to dates older than the available history.
  ExchangeRates? forPair(
    String dateKey,
    SupportedCurrency from,
    SupportedCurrency to,
  ) {
    bool serves(ExchangeRates? rates) =>
        rates != null &&
        rates.rateFor(from) != null &&
        rates.rateFor(to) != null;

    final onDate = forDate(dateKey);
    if (serves(onDate)) return onDate;

    final keys = byDate.keys.toList()..sort();
    for (final key in keys.reversed) {
      final candidate = byDate[key];
      if (serves(candidate)) return candidate;
    }

    return serves(latest) ? latest : null;
  }

  RateBook merge(Map<String, ExchangeRates> other, {ExchangeRates? latest}) =>
      RateBook(
        byDate: {...byDate, ...other},
        latest: latest ?? this.latest,
      );

  @override
  List<Object?> get props => [byDate, latest];
}
