import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';

class _FakeStorage implements KaziLocalStorageService {
  _FakeStorage([Map<String, Object?> initialValues = const {}])
      : values = Map.of(initialValues);

  final Map<String, Object?> values;

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<T?> read<T>(String key) async => values[key] as T?;

  @override
  Future<void> write<T>(String key, T value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

class _FakeRemoteStore implements KaziRemoteCurrencyStore {
  _FakeRemoteStore({this.stored, this.writeFails = false});

  SupportedCurrency? stored;
  bool writeFails;

  @override
  Future<SupportedCurrency?> read() async => stored;

  @override
  Future<void> write(SupportedCurrency currency) async {
    if (writeFails) throw ExternalError('offline');
    stored = currency;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerWith({
    required _FakeStorage storage,
    KaziRemoteCurrencyStore? remote,
  }) {
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWith((ref) async => storage),
        kaziRemoteCurrencyStoreProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  String? cached(_FakeStorage storage) =>
      storage.values[KaziStorageKeys.defaultCurrencyCode] as String?;

  group('KaziCurrencyController', () {
    test('Should prefer the currency stored on the account over the cache',
        () async {
      final storage = _FakeStorage({
        KaziStorageKeys.defaultCurrencyCode: SupportedCurrency.brl.isoCode,
      });
      final container = containerWith(
        storage: storage,
        remote: _FakeRemoteStore(stored: SupportedCurrency.eur),
      );

      final currency = await container.read(
        kaziCurrencyControllerProvider.future,
      );

      expect(currency, SupportedCurrency.eur);
      expect(cached(storage), SupportedCurrency.eur.isoCode);
    });

    test('Should fall back to the cache when the account has no currency yet',
        () async {
      final storage = _FakeStorage({
        KaziStorageKeys.defaultCurrencyCode: SupportedCurrency.brl.isoCode,
      });
      final container = containerWith(
        storage: storage,
        remote: _FakeRemoteStore(),
      );

      final currency = await container.read(
        kaziCurrencyControllerProvider.future,
      );

      expect(currency, SupportedCurrency.brl);
    });

    test('Should save the choice on the account', () async {
      final storage = _FakeStorage();
      final remote = _FakeRemoteStore();
      final container = containerWith(storage: storage, remote: remote);
      await container.read(kaziCurrencyControllerProvider.future);

      await container
          .read(kaziCurrencyControllerProvider.notifier)
          .selectCurrency(SupportedCurrency.mxn);

      expect(remote.stored, SupportedCurrency.mxn);
      expect(cached(storage), SupportedCurrency.mxn.isoCode);
    });

    // The device must never end up believing in a currency the account does
    // not have: that is how amounts get relabelled on one device only.
    test('Should not cache the choice when the account write fails', () async {
      final storage = _FakeStorage({
        KaziStorageKeys.defaultCurrencyCode: SupportedCurrency.brl.isoCode,
      });
      final container = containerWith(
        storage: storage,
        remote: _FakeRemoteStore(stored: SupportedCurrency.brl, writeFails: true),
      );
      await container.read(kaziCurrencyControllerProvider.future);

      await expectLater(
        container
            .read(kaziCurrencyControllerProvider.notifier)
            .selectCurrency(SupportedCurrency.mxn),
        throwsA(isA<ExternalError>()),
      );

      expect(cached(storage), SupportedCurrency.brl.isoCode);
      expect(container.read(kaziDefaultCurrencyProvider), SupportedCurrency.brl);
    });
  });
}
