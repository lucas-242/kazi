import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';

extension SupportedCurrencyL10n on SupportedCurrency {
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
      case SupportedCurrency.ngn:
        return l10n.currencyNGN;
      case SupportedCurrency.kes:
        return l10n.currencyKES;
      case SupportedCurrency.ugx:
        return l10n.currencyUGX;
      case SupportedCurrency.pyg:
        return l10n.currencyPYG;
      case SupportedCurrency.inr:
        return l10n.currencyINR;
    }
  }
}
