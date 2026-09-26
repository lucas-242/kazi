import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';

/// Shared, append-only store of daily exchange-rate snapshots.
///
/// Snapshots are global (not per user) and addressed by a `yyyy-MM-dd` UTC key,
/// so the whole rate history costs one document per day for the entire app
/// instead of one embedded copy per registered service.
abstract class ExchangeRateHistoryRepository {
  /// Snapshots for the requested keys. Missing days are simply absent from the
  /// result — implementations must not throw for them.
  Future<Map<String, ExchangeRates>> getRange(Iterable<String> dateKeys);

  /// The most recent snapshot on or before [dateKey], or null when the history
  /// does not reach that far back.
  Future<ExchangeRates?> getNearestBefore(String dateKey);

  /// Writes the snapshot for [dateKey] only if it does not exist yet. Losing
  /// the race against another client is not an error.
  Future<void> putIfAbsent(String dateKey, ExchangeRates rates);
}
