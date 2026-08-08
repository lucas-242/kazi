import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';

extension SupportedCurrencyL10n on SupportedCurrency {
  /// Whether this currency answers to [query] in a picker search. Matches the
  /// ISO code, the symbol and the localized name, so "BRL", r"R$" and "real"
  /// all find the same row. An empty query matches everything.
  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return '$isoCode $symbol $localizedName'
        .toLowerCase()
        .contains(normalized);
  }

  /// Full name in the user's language, for pickers where the ISO code alone is
  /// not enough to choose confidently.
  String get localizedName {
    final l10n = KaziLocalizations.current;
    switch (this) {
      case SupportedCurrency.brl:
        return l10n.currencyBRL;
      case SupportedCurrency.usd:
        return l10n.currencyUSD;
      case SupportedCurrency.cad:
        return l10n.currencyCAD;
      case SupportedCurrency.ars:
        return l10n.currencyARS;
      case SupportedCurrency.bob:
        return l10n.currencyBOB;
      case SupportedCurrency.clp:
        return l10n.currencyCLP;
      case SupportedCurrency.cop:
        return l10n.currencyCOP;
      case SupportedCurrency.crc:
        return l10n.currencyCRC;
      case SupportedCurrency.cup:
        return l10n.currencyCUP;
      case SupportedCurrency.dop:
        return l10n.currencyDOP;
      case SupportedCurrency.gtq:
        return l10n.currencyGTQ;
      case SupportedCurrency.hnl:
        return l10n.currencyHNL;
      case SupportedCurrency.htg:
        return l10n.currencyHTG;
      case SupportedCurrency.mxn:
        return l10n.currencyMXN;
      case SupportedCurrency.nio:
        return l10n.currencyNIO;
      case SupportedCurrency.pab:
        return l10n.currencyPAB;
      case SupportedCurrency.pen:
        return l10n.currencyPEN;
      case SupportedCurrency.pyg:
        return l10n.currencyPYG;
      case SupportedCurrency.uyu:
        return l10n.currencyUYU;
      case SupportedCurrency.ves:
        return l10n.currencyVES;
      case SupportedCurrency.zar:
        return l10n.currencyZAR;
      case SupportedCurrency.ngn:
        return l10n.currencyNGN;
      case SupportedCurrency.xof:
        return l10n.currencyXOF;
      case SupportedCurrency.xaf:
        return l10n.currencyXAF;
      case SupportedCurrency.kes:
        return l10n.currencyKES;
      case SupportedCurrency.ugx:
        return l10n.currencyUGX;
      case SupportedCurrency.mad:
        return l10n.currencyMAD;
      case SupportedCurrency.etb:
        return l10n.currencyETB;
      case SupportedCurrency.aoa:
        return l10n.currencyAOA;
      case SupportedCurrency.ghs:
        return l10n.currencyGHS;
      case SupportedCurrency.eur:
        return l10n.currencyEUR;
      case SupportedCurrency.gbp:
        return l10n.currencyGBP;
      case SupportedCurrency.chf:
        return l10n.currencyCHF;
      case SupportedCurrency.jpy:
        return l10n.currencyJPY;
      case SupportedCurrency.cny:
        return l10n.currencyCNY;
      case SupportedCurrency.krw:
        return l10n.currencyKRW;
      case SupportedCurrency.sgd:
        return l10n.currencySGD;
      case SupportedCurrency.inr:
        return l10n.currencyINR;
      case SupportedCurrency.aed:
        return l10n.currencyAED;
      case SupportedCurrency.sar:
        return l10n.currencySAR;
      case SupportedCurrency.tryLira:
        return l10n.currencyTRY;
      case SupportedCurrency.rub:
        return l10n.currencyRUB;
    }
  }
}
