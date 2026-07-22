/// Currencies the app can register services in.
enum SupportedCurrency {
  brl(isoCode: 'BRL', symbol: r'R$', decimalDigits: 2),
  usd(isoCode: 'USD', symbol: r'$', decimalDigits: 2),
  cad(isoCode: 'CAD', symbol: r'CA$', decimalDigits: 2),
  ngn(isoCode: 'NGN', symbol: '₦', decimalDigits: 2),
  kes(isoCode: 'KES', symbol: 'KSh', decimalDigits: 2),
  ugx(isoCode: 'UGX', symbol: 'USh', decimalDigits: 0),
  pyg(isoCode: 'PYG', symbol: '₲', decimalDigits: 0),
  inr(isoCode: 'INR', symbol: '₹', decimalDigits: 2);

  const SupportedCurrency({
    required this.isoCode,
    required this.symbol,
    required this.decimalDigits,
  });

  final String isoCode;
  final String symbol;
  final int decimalDigits;

  /// Currency used as the conversion base for stored exchange-rate snapshots.
  static const SupportedCurrency base = SupportedCurrency.usd;

  /// Resolves an ISO code to a currency, falling back to [fallback] (or USD)
  /// for unknown/legacy codes
  static SupportedCurrency fromCode(
    String? code, {
    SupportedCurrency fallback = SupportedCurrency.usd,
  }) {
    if (code == null || code.isEmpty) return fallback;
    final normalized = code.toUpperCase();
    for (final currency in SupportedCurrency.values) {
      if (currency.isoCode == normalized) return currency;
    }
    return fallback;
  }
}
