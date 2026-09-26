import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';

/// Caches the user's chosen default currency in local storage.
final class KaziCurrencyManager {
  const KaziCurrencyManager({required KaziLocalStorageService storage})
      : _storage = storage;

  final KaziLocalStorageService _storage;

  /// The cached currency, or null when the user never picked one on this
  /// device. Null is meaningful: it lets callers tell "no choice yet" from
  /// "chose the device default", which the migration relies on.
  Future<SupportedCurrency?> readCached() async {
    final stored = await _storage.read<String>(
      KaziStorageKeys.defaultCurrencyCode,
    );

    if (stored == null || stored.isEmpty) return null;

    return SupportedCurrency.fromCode(stored);
  }

  Future<SupportedCurrency> loadDefaultCurrency({
    required String deviceCountryCode,
  }) async =>
      await readCached() ?? deviceDefault(deviceCountryCode);

  Future<SupportedCurrency> selectCurrency(SupportedCurrency currency) async {
    await _storage.write<String>(
      KaziStorageKeys.defaultCurrencyCode,
      currency.isoCode,
    );
    return currency;
  }

  static SupportedCurrency deviceDefault(String deviceCountryCode) =>
      SupportedCurrency.fromCountryCode(deviceCountryCode);
}
