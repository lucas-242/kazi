import 'package:equatable/equatable.dart';
import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';

/// A set of daily exchange-rate snapshots, keyed by `yyyy-MM-dd`, able to
/// resolve which snapshot applies to a given date.
///
/// Resolution order is exact day, then the closest earlier day available, then
/// [latest] (today's rates) as a last resort. When nothing resolves, [forDate]
/// returns null — the signal that an amount *cannot* be converted. Callers must
/// never fall back to the raw amount, which would present a value in one
/// currency as if it were in another.
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

  RateBook merge(Map<String, ExchangeRates> other, {ExchangeRates? latest}) =>
      RateBook(
        byDate: {...byDate, ...other},
        latest: latest ?? this.latest,
      );

  @override
  List<Object?> get props => [byDate, latest];
}
