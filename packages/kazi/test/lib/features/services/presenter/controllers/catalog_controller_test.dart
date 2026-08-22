import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/fakes/fake_analytics_service.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fake_creation_ad_coordinator.dart';
import '../../../../../utils/fake_subscription_service.dart';
import '../../../../../utils/test_helper.dart';
import 'catalog_controller_test.mocks.dart';

@GenerateMocks([CatalogItemRepository, ServicesRepository, AuthService])
void main() {
  late MockCatalogItemRepository catalogItemRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  CatalogController controller() =>
      container.read(catalogControllerProvider.notifier);
  CatalogState state() => container.read(catalogControllerProvider);

  setUp(() async {
    catalogItemRepository = MockCatalogItemRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(
      catalogItemRepository.get(any),
    ).thenAnswer((_) async => catalogItemsMock);
    when(
      catalogItemRepository.add(any),
    ).thenAnswer((_) async => catalogItemMock);

    container = ProviderContainer(
      overrides: [
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        // The creation path reports `client_created` / `limit_reached`.
        // Without this the real composite is built, and its Firebase sink
        // needs an initialised Firebase app a unit test does not have.
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        catalogItemRepositoryProvider.overrideWithValue(catalogItemRepository),
        authServiceProvider.overrideWithValue(authService),
        subscriptionServiceProvider.overrideWithValue(
          FakeSubscriptionService(),
        ),
        freemiumGuardProvider.overrideWithValue(fakeFreemiumGuard()),
        creationAdCoordinatorProvider.overrideWith(
          (ref) => FakeCreationAdCoordinator(),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('onInit', () {
    test('loads catalogItems and status readyToUserInput', () async {
      await controller().onInit();

      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().catalogItems, catalogItemsMock);
    });

    test('status noData when there are no catalogItems', () async {
      when(catalogItemRepository.get(any)).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().catalogItems, isEmpty);
    });
  });

  group('getCatalogItems', () {
    test('loads catalogItems and ends readyToUserInput', () async {
      await controller().getCatalogItems();

      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().catalogItems, catalogItemsMock);
    });

    test('status error with errorToGetCatalogItems on AppError', () async {
      when(catalogItemRepository.get(any)).thenThrow(
        ExternalError(KaziLocalizations.current.errorToGetCatalogItems),
      );

      await controller().getCatalogItems();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorToGetCatalogItems,
      );
    });

    test('status error with unknowError on unexpected exception', () async {
      when(catalogItemRepository.get(any)).thenThrow(Exception());

      await controller().getCatalogItems();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('addCatalogItem', () {
    test(
      'adds the catalogItem and ends in success with reset catalogItem',
      () async {
        controller().changeCatalogItem(catalogItemMock);
        await controller().addCatalogItem();

        expect(state().status, BaseStateStatus.success);
        expect(state().catalogItems, [catalogItemMock]);
        expect(state().catalogItem.id, isEmpty);
      },
    );
  });

  group('updateCatalogItem', () {
    test('updates and refetches catalogItems, ending in success', () async {
      controller().changeCatalogItem(catalogItemMock);
      await controller().updateCatalogItem();

      expect(state().status, BaseStateStatus.success);
      expect(state().catalogItems, catalogItemsMock);
    });
  });

  group('deleteCatalogItem', () {
    setUp(() {
      when(servicesRepository.count(any, any)).thenAnswer((_) async => 0);
    });

    test('deletes and refetches catalogItems, ending in success', () async {
      final catalogItemToDelete = catalogItemMock.copyWith(id: '123456');

      await controller().deleteCatalogItem(catalogItemToDelete);

      expect(state().status, BaseStateStatus.success);
      expect(state().catalogItems, catalogItemsMock);
    });
  });

  group('change properties', () {
    const newName = 'new name';
    const newDefaultValue = 9999.0;
    const newCommissionPercent = 1.0;

    test('eraseCatalogItem resets catalogItem', () {
      controller().changeCatalogItem(catalogItemMock);
      controller().eraseCatalogItem();

      expect(state().catalogItem.id, isEmpty);
      expect(state().catalogItem.name, isEmpty);
    });

    test('changeCatalogItemName updates name', () {
      controller().changeCatalogItem(catalogItemMock);
      controller().changeCatalogItemName(newName);

      expect(state().catalogItem, catalogItemMock.copyWith(name: newName));
    });

    test('changeCatalogItemDefaultValue updates defaultValue', () {
      controller().changeCatalogItem(catalogItemMock);
      controller().changeCatalogItemDefaultValue(newDefaultValue);

      expect(
        state().catalogItem,
        catalogItemMock.copyWith(defaultValue: newDefaultValue),
      );
    });

    test('changeCatalogItemCommissionPercent updates commissionPercent', () {
      controller().changeCatalogItem(catalogItemMock);
      controller().changeCatalogItemCommissionPercent(newCommissionPercent);

      expect(
        state().catalogItem,
        catalogItemMock.copyWith(commissionPercent: newCommissionPercent),
      );
    });
  });
}
