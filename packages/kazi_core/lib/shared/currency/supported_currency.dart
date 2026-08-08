/// Currencies the app can register services in.
///
/// Symbols follow CLDR, disambiguated whenever the bare glyph collides with
/// another supported currency (`CA$`, `MX$`, `CN¥`); `decimalDigits` comes from
/// ISO 4217. Currencies whose local glyph is not typeable on a Latin keyboard
/// (`MAD`, `AED`, `SAR`) carry the ISO code as symbol, like CLDR does.
enum SupportedCurrency {
  // Americas.
  brl(isoCode: 'BRL', symbol: r'R$', decimalDigits: 2),
  usd(isoCode: 'USD', symbol: r'$', decimalDigits: 2),
  cad(isoCode: 'CAD', symbol: r'CA$', decimalDigits: 2),
  // Prefixed like CAD: the bare `$` would be indistinguishable from USD.
  ars(isoCode: 'ARS', symbol: r'AR$', decimalDigits: 2),
  bob(isoCode: 'BOB', symbol: 'Bs', decimalDigits: 2),
  clp(isoCode: 'CLP', symbol: r'CLP$', decimalDigits: 0),
  cop(isoCode: 'COP', symbol: r'COL$', decimalDigits: 2),
  crc(isoCode: 'CRC', symbol: '₡', decimalDigits: 2),
  cup(isoCode: 'CUP', symbol: r'CUP$', decimalDigits: 2),
  dop(isoCode: 'DOP', symbol: r'RD$', decimalDigits: 2),
  gtq(isoCode: 'GTQ', symbol: 'Q', decimalDigits: 2),
  hnl(isoCode: 'HNL', symbol: 'L', decimalDigits: 2),
  htg(isoCode: 'HTG', symbol: 'G', decimalDigits: 2),
  mxn(isoCode: 'MXN', symbol: r'MX$', decimalDigits: 2),
  nio(isoCode: 'NIO', symbol: r'C$', decimalDigits: 2),
  pab(isoCode: 'PAB', symbol: 'B/.', decimalDigits: 2),
  pen(isoCode: 'PEN', symbol: 'S/', decimalDigits: 2),
  pyg(isoCode: 'PYG', symbol: '₲', decimalDigits: 0),
  uyu(isoCode: 'UYU', symbol: r'$U', decimalDigits: 2),
  // Bolivia already took the bare `Bs`.
  ves(isoCode: 'VES', symbol: 'Bs.S', decimalDigits: 2),

  // Africa.
  zar(isoCode: 'ZAR', symbol: 'R', decimalDigits: 2),
  ngn(isoCode: 'NGN', symbol: '₦', decimalDigits: 2),
  // The two CFA francs are separate currencies at different rates; CLDR splits
  // them by the space, and the localized name carries the rest of the weight.
  xof(isoCode: 'XOF', symbol: 'F CFA', decimalDigits: 0),
  xaf(isoCode: 'XAF', symbol: 'FCFA', decimalDigits: 0),
  kes(isoCode: 'KES', symbol: 'KSh', decimalDigits: 2),
  ugx(isoCode: 'UGX', symbol: 'USh', decimalDigits: 0),
  mad(isoCode: 'MAD', symbol: 'MAD', decimalDigits: 2),
  etb(isoCode: 'ETB', symbol: 'Br', decimalDigits: 2),
  aoa(isoCode: 'AOA', symbol: 'Kz', decimalDigits: 2),
  ghs(isoCode: 'GHS', symbol: 'GH₵', decimalDigits: 2),

  // Europe, Asia and the Middle East.
  eur(isoCode: 'EUR', symbol: '€', decimalDigits: 2),
  gbp(isoCode: 'GBP', symbol: '£', decimalDigits: 2),
  chf(isoCode: 'CHF', symbol: 'CHF', decimalDigits: 2),
  jpy(isoCode: 'JPY', symbol: '¥', decimalDigits: 0),
  // Prefixed: the bare `¥` would be indistinguishable from the yen.
  cny(isoCode: 'CNY', symbol: 'CN¥', decimalDigits: 2),
  krw(isoCode: 'KRW', symbol: '₩', decimalDigits: 0),
  sgd(isoCode: 'SGD', symbol: r'S$', decimalDigits: 2),
  inr(isoCode: 'INR', symbol: '₹', decimalDigits: 2),
  aed(isoCode: 'AED', symbol: 'AED', decimalDigits: 2),
  sar(isoCode: 'SAR', symbol: 'SAR', decimalDigits: 2),
  // `try` is a reserved word in Dart.
  tryLira(isoCode: 'TRY', symbol: '₺', decimalDigits: 2),
  rub(isoCode: 'RUB', symbol: '₽', decimalDigits: 2);

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

  /// Best guess from an ISO country code, used only to preselect a currency
  /// before the user picks one. Anything unmapped lands on USD — which covers
  /// the countries that actually use it (EC, SV, PA alongside the balboa).
  static SupportedCurrency fromCountryCode(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) return usd;

    return switch (countryCode.toUpperCase()) {
      // Americas.
      'BR' => brl,
      'CA' => cad,
      'AR' => ars,
      'BO' => bob,
      'CL' => clp,
      'CO' => cop,
      'CR' => crc,
      'CU' => cup,
      'DO' => dop,
      'GT' => gtq,
      'HN' => hnl,
      'HT' => htg,
      'MX' => mxn,
      'NI' => nio,
      'PA' => pab,
      'PE' => pen,
      'PY' => pyg,
      'UY' => uyu,
      'VE' => ves,
      // Africa.
      'ZA' => zar,
      'NG' => ngn,
      'BJ' || 'BF' || 'CI' || 'GW' || 'ML' || 'NE' || 'SN' || 'TG' => xof,
      'CM' || 'CF' || 'TD' || 'CG' || 'GQ' || 'GA' => xaf,
      'KE' => kes,
      'UG' => ugx,
      'MA' || 'EH' => mad,
      'ET' => etb,
      'AO' => aoa,
      'GH' => ghs,
      // Eurozone.
      'AD' ||
      'AT' ||
      'BE' ||
      'CY' ||
      'DE' ||
      'EE' ||
      'ES' ||
      'FI' ||
      'FR' ||
      'GR' ||
      'HR' ||
      'IE' ||
      'IT' ||
      'LT' ||
      'LU' ||
      'LV' ||
      'MC' ||
      'ME' ||
      'MT' ||
      'NL' ||
      'PT' ||
      'SI' ||
      'SK' ||
      'SM' ||
      'VA' ||
      'XK' =>
        eur,
      // Rest of Europe, Asia and the Middle East.
      'GB' => gbp,
      'CH' || 'LI' => chf,
      'JP' => jpy,
      'CN' => cny,
      'KR' => krw,
      'SG' => sgd,
      'IN' => inr,
      'AE' => aed,
      'SA' => sar,
      'TR' => tryLira,
      'RU' => rub,
      _ => usd,
    };
  }
}
