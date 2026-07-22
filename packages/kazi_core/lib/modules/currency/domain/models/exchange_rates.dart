import 'package:equatable/equatable.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';

class ExchangeRates extends Equatable {
  ExchangeRates({
    required this.rates,
    DateTime? fetchedAt,
    this.base = SupportedCurrency.base,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  final SupportedCurrency base;
  final Map<String, double> rates;
  final DateTime fetchedAt;

  /// Rate for [currency] (units per one [base]). Base returns 1; unknown
  /// currencies return null so callers can decide how to degrade.
  double? rateFor(SupportedCurrency currency) {
    if (currency == base) return 1;
    return rates[currency.isoCode];
  }

  Map<String, dynamic> toMap() => {
        'base': base.isoCode,
        'rates': rates,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [base, rates, fetchedAt];
}
