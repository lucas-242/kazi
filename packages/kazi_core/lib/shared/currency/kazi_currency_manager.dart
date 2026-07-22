import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';

/// Persists the user's chosen default currency in local storage.
final class KaziCurrencyManager {
  const KaziCurrencyManager({required KaziLocalStorageService storage})
      : _storage = storage;

  final KaziLocalStorageService _storage;

  static const String _defaultCurrencyKey = 'defaultCurrencyCode';

  Future<SupportedCurrency> loadDefaultCurrency({
    required String deviceCountryCode,
  }) async {
    final stored = await _storage.read<String>(_defaultCurrencyKey);

    if (stored != null && stored.isNotEmpty) {
      return SupportedCurrency.fromCode(
        stored,
        fallback: _deviceDefault(deviceCountryCode),
      );
    }

    return _deviceDefault(deviceCountryCode);
  }

  Future<SupportedCurrency> selectCurrency(SupportedCurrency currency) async {
    await _storage.write<String>(_defaultCurrencyKey, currency.isoCode);
    return currency;
  }

  SupportedCurrency _deviceDefault(String deviceCountryCode) =>
      deviceCountryCode.toUpperCase() == 'BR'
          ? SupportedCurrency.brl
          : SupportedCurrency.usd;
}
