import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// In-memory stand-in for the `users/{uid}` currency document.
class FakeRemoteCurrencyStore implements KaziRemoteCurrencyStore {
  FakeRemoteCurrencyStore([this.currency]);

  SupportedCurrency? currency;

  @override
  Future<SupportedCurrency?> read() async => currency;

  @override
  Future<void> write(SupportedCurrency value) async => currency = value;
}
