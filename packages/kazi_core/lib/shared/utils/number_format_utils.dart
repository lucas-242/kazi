import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/extensions/double_extensions.dart';

abstract class NumberFormatUtils {
  /// Formats [value] in an explicit [currency] (symbol + decimal digits), while
  /// separators/grouping still follow the user's [locale] (or device locale).
  static String formatCurrencyIn(
    num? value,
    SupportedCurrency currency, {
    Locale? locale,
  }) {
    final stringLocale = locale != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : getCurrentLocale();
    return NumberFormat.currency(
      locale: stringLocale,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    ).format(value ?? 0);
  }

  static String formatPercent([double? value, Locale? locale]) {
    final valueWithoutZero = value?.removeDecimalPoint() ?? '0';
    var decimalDigits = 0;
    final splitted = valueWithoutZero.split('.');
    if (splitted.length > 1) {
      decimalDigits = splitted[1].length;
    }

    final stringLocale = locale != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : getCurrentLocale();
    return NumberFormat.decimalPercentPattern(
      locale: stringLocale,
      decimalDigits: decimalDigits,
    ).format((double.tryParse(valueWithoutZero) ?? 0) / 100);
  }

  static String getCurrentLocale() {
    final locale = PlatformDispatcher.instance.locale;
    final joined = '${locale.languageCode}_${locale.countryCode}';
    if (numberFormatSymbols.keys.contains(joined)) {
      return joined;
    }
    return locale.languageCode;
  }

  static String getDecimalSeparator() {
    return numberFormatSymbols[getCurrentLocale()]?.DECIMAL_SEP ?? ',';
  }

  static String getThousandSeparator() {
    return numberFormatSymbols[getCurrentLocale()]?.GROUP_SEP ?? '.';
  }
}
