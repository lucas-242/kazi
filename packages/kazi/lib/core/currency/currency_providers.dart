import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'currency_providers.g.dart';

/// Rate snapshots for a single day, for screens that show one amount rather
/// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
/// the same day share one provider instance.
@riverpod
Future<RateBook> dayRateBook(Ref ref, String dateKey) async {
  final history = await ref.watch(exchangeRateHistoryServiceProvider.future);
  return history.bookFor([dateKey]);
}
