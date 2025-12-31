import 'package:flutter/widgets.dart';
import 'package:kazi_core/shared/localization/kazi_locale_policy.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';

/// Manages the locale of the app dealing with storage and applying policy.
final class KaziLocaleManager {
  const KaziLocaleManager({
    required KaziLocalStorageService storage,
    required KaziLocalePolicy policy,
  })  : _storage = storage,
        _policy = policy;

  final KaziLocalStorageService _storage;
  final KaziLocalePolicy _policy;

  static const String _userLanguageCodeKey = 'userLanguageCode';

  Future<Locale?> loadOverrideLocale() async {
    final languageCode = await _storage.read<String>(_userLanguageCodeKey);

    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    if (!_policy.isSupportedLanguageCode(languageCode)) {
      await _storage.remove(_userLanguageCodeKey);
      return null;
    }

    return Locale(languageCode);
  }

  Future<Locale?> selectLanguage({
    required String languageCode,
    required Locale deviceLocale,
  }) async {
    if (!_policy.isSupportedLanguageCode(languageCode)) {
      return loadOverrideLocale();
    }

    final shouldPersist = _policy.shouldPersistOverride(
      selectedLanguageCode: languageCode,
      deviceLocale: deviceLocale,
    );

    if (!shouldPersist) {
      await _storage.remove(_userLanguageCodeKey);
      return null;
    }

    await _storage.write<String>(_userLanguageCodeKey, languageCode);
    return Locale(languageCode);
  }

  Locale resolveDeviceLocale(Locale? locale) =>
      _policy.resolveDeviceLocale(locale);
}
