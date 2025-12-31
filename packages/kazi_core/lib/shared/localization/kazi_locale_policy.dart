import 'package:flutter/widgets.dart';

/// Policy for handling locale selection.
final class KaziLocalePolicy {
  const KaziLocalePolicy({
    required this.supportedLocales,
    this.fallbackLocale = const Locale('en'),
  });

  final List<Locale> supportedLocales;
  final Locale fallbackLocale;

  Locale resolveDeviceLocale(Locale? deviceLocale) {
    final locale = deviceLocale ?? fallbackLocale;

    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return Locale(supported.languageCode);
      }
    }

    return fallbackLocale;
  }

  bool shouldPersistOverride({
    required String selectedLanguageCode,
    required Locale deviceLocale,
  }) {
    final defaultLocale = resolveDeviceLocale(deviceLocale);
    return defaultLocale.languageCode != selectedLanguageCode;
  }

  bool isSupportedLanguageCode(String languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) return true;
    }
    return false;
  }
}
