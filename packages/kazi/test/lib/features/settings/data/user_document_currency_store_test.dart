import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/data/services/kazi_firebase_auth_service.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../utils/fakes/fake_auth_service.dart';
import '../../../../utils/fakes/fake_local_storage.dart';
import '../../../../utils/test_helper.dart';
import 'user_document_currency_store_test.mocks.dart';

@GenerateMocks([UserSettingsRepository])
void main() {
  late MockUserSettingsRepository userSettings;
  late FakeAuthService auth;
  late FakeLocalStorage storage;
  late ProviderContainer container;

  final user = AppUser(uid: 'uid', name: 'Test', email: 'test@test.com');

  TestWidgetsFlutterBinding.ensureInitialized();
  TestHelper.loadAppLocalizations();

  setUp(() {
    userSettings = MockUserSettingsRepository();
    auth = FakeAuthService();
    storage = FakeLocalStorage();

    when(userSettings.get(any)).thenAnswer(
      (_) async => const UserSettings(defaultCurrency: SupportedCurrency.eur),
    );
    when(userSettings.setDefaultCurrency(any, any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        kaziAuthServiceProvider.overrideWith(
          (ref) => KaziFirebaseAuthService(auth),
        ),
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        localStorageProvider.overrideWith((ref) async => storage),
        kaziRemoteCurrencyStoreProvider.overrideWith(
          (ref) => ref.watch(appRemoteCurrencyStoreProvider),
        ),
      ],
    );
    container.listen(kaziCurrencyControllerProvider, (_, _) {});
    addTearDown(container.dispose);
    addTearDown(auth.dispose);
  });

  // The controller is kept alive and first built on the splash, before anyone
  // is signed in. Without a rebuild on sign-in it would answer with the device
  // guess until the app is restarted, which is what made the choice look like
  // a device setting rather than an account one.
  test('Should read the account currency once the user signs in', () async {
    expect(
      await container.read(kaziCurrencyControllerProvider.future),
      isNot(SupportedCurrency.eur),
    );

    auth.signInAs(user);
    await pumpEventQueue();

    expect(
      await container.read(kaziCurrencyControllerProvider.future),
      SupportedCurrency.eur,
    );
  });

  test('Should write the choice to the user document', () async {
    auth.signInAs(user);
    await pumpEventQueue();
    await container.read(kaziCurrencyControllerProvider.future);

    await container
        .read(kaziCurrencyControllerProvider.notifier)
        .selectCurrency(SupportedCurrency.mxn);

    verify(
      userSettings.setDefaultCurrency(user.uid, SupportedCurrency.mxn),
    ).called(1);
  });
}
