import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';

abstract interface class ExchangeRateRepository {
  /// Fetches the latest exchange rates (base = [SupportedCurrency.base]).
  Future<ExchangeRates> getRates();
}
