import 'package:kazi_core/shared/currency/supported_currency.dart';

/// Per-user, cross-device home for the default currency.
///
/// Local storage is only a cache: it is wiped on sign-out, so a user coming back
/// would otherwise fall back to the device default and read every amount in the
/// wrong currency. Apps that have a backend for it (kazi, via the user document)
/// override `kaziRemoteCurrencyStoreProvider`; apps that do not leave it null and
/// keep the local-only behaviour.
abstract class KaziRemoteCurrencyStore {
  /// The stored currency, or null when the user has none yet. Implementations
  /// must return null instead of throwing when offline or signed out, so the
  /// local cache can answer.
  Future<SupportedCurrency?> read();

  Future<void> write(SupportedCurrency currency);
}
