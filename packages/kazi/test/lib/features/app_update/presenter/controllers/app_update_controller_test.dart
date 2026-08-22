import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/app_update/domain/models/app_update_info.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';
import 'package:kazi/features/app_update/presenter/controllers/app_update_controller.dart';
import 'package:kazi/features/app_update/presenter/controllers/app_update_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/test_helper.dart';
import 'app_update_controller_test.mocks.dart';

@GenerateMocks([AppUpdateService, KaziLocalStorageService])
void main() {
  late MockAppUpdateService appUpdateService;
  late MockKaziLocalStorageService storage;
  late ProviderContainer container;

  const optionalInfo = AppUpdateInfo(
    status: AppUpdateStatus.optional,
    latestVersion: '1.4.0',
    storeUrl: 'https://store',
  );
  const mandatoryInfo = AppUpdateInfo(
    status: AppUpdateStatus.mandatory,
    latestVersion: '1.4.0',
    storeUrl: 'https://store',
  );

  TestHelper.loadAppLocalizations();

  AppUpdateController controller() =>
      container.read(appUpdateControllerProvider.notifier);
  AppUpdateState state() => container.read(appUpdateControllerProvider);

  setUp(() {
    appUpdateService = MockAppUpdateService();
    storage = MockKaziLocalStorageService();

    when(
      storage.write<String>(any, any),
    ).thenAnswer((_) => Future<void>.value());
    when(storage.read<String>(any)).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        appUpdateServiceProvider.overrideWithValue(appUpdateService),
        localStorageProvider.overrideWith((ref) async => storage),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('check', () {
    test('stores optional info and ends in success', () async {
      when(
        appUpdateService.checkForUpdate(),
      ).thenAnswer((_) async => optionalInfo);

      await controller().check();

      expect(state().status, BaseStateStatus.success);
      expect(state().isOptional, isTrue);
      expect(state().isMandatory, isFalse);
      expect(state().info.latestVersion, '1.4.0');
    });

    test('flags mandatory update', () async {
      when(
        appUpdateService.checkForUpdate(),
      ).thenAnswer((_) async => mandatoryInfo);

      await controller().check();

      expect(state().isMandatory, isTrue);
    });

    test(
      'ends in error with unknown message on unexpected exception',
      () async {
        when(appUpdateService.checkForUpdate()).thenThrow(Exception());

        await controller().check();

        expect(state().status, BaseStateStatus.error);
        expect(
          state().callbackMessage,
          KaziLocalizations.current.errorUnknowError,
        );
      },
    );
  });

  group('shouldShowOptionalDialog', () {
    test('false when there is no optional update', () async {
      when(
        appUpdateService.checkForUpdate(),
      ).thenAnswer((_) async => const AppUpdateInfo.upToDate());
      await controller().check();

      expect(await controller().shouldShowOptionalDialog(), isFalse);
    });

    test('true and records the date when never prompted', () async {
      when(
        appUpdateService.checkForUpdate(),
      ).thenAnswer((_) async => optionalInfo);
      await controller().check();

      expect(await controller().shouldShowOptionalDialog(), isTrue);
      verify(
        storage.write<String>(StorageKeys.lastOptionalUpdatePromptDate, any),
      ).called(1);
    });

    test('false when already prompted within the last day', () async {
      when(
        appUpdateService.checkForUpdate(),
      ).thenAnswer((_) async => optionalInfo);
      when(
        storage.read<String>(StorageKeys.lastOptionalUpdatePromptDate),
      ).thenAnswer((_) async => DateTime.now().toIso8601String());
      await controller().check();

      expect(await controller().shouldShowOptionalDialog(), isFalse);
    });
  });
}
