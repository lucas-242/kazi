import 'package:equatable/equatable.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';

class ExchangeRates extends Equatable {
  ExchangeRates({
    required this.rates,
    DateTime? fetchedAt,
    this.base = SupportedCurrency.base,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  /// Rebuilds a snapshot persisted by [toMap]. Returns null when the payload is
  /// missing rates or carries an unusable value, so a tampered/corrupt shared
  /// document is discarded instead of silently skewing conversions.
  static ExchangeRates? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    final rawRates = map['rates'];
    if (rawRates is! Map) return null;

    final rates = <String, double>{};
    for (final entry in rawRates.entries) {
      final value = entry.value;
      if (value is! num) return null;
      final rate = value.toDouble();
      if (!rate.isFinite || rate <= 0) return null;
      rates[entry.key.toString()] = rate;
    }

    if (rates.isEmpty) return null;

    return ExchangeRates(
      rates: rates,
      // fromCode already falls back to SupportedCurrency.base.
      base: SupportedCurrency.fromCode(map['base'] as String?),
      fetchedAt: DateTime.tryParse(map['fetchedAt'] as String? ?? '')?.toUtc(),
    );
  }

  /// Builds the `yyyy-MM-dd` key used to address a daily snapshot. Always UTC,
  /// so every device resolves the same document for the same instant.
  static String dateKeyOf(DateTime date) {
    final utc = date.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  final SupportedCurrency base;
  final Map<String, double> rates;
  final DateTime fetchedAt;

  /// The daily-snapshot key this instance belongs to.
  String get dateKey => dateKeyOf(fetchedAt);

  /// Rate for [currency] (units per one [base]). Base returns 1; unknown
  /// currencies return null so callers can decide how to degrade.
  double? rateFor(SupportedCurrency currency) {
    if (currency == base) return 1;
    return rates[currency.isoCode];
  }

  Map<String, dynamic> toMap() => {
        'base': base.isoCode,
        'rates': rates,
        'fetchedAt': fetchedAt.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [base, rates, fetchedAt];
}
