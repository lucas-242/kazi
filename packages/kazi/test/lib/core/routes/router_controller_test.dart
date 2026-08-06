import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'router_controller_test.mocks.dart';

@GenerateMocks([KaziLocalStorageService])
void main() {
  late MockKaziLocalStorageService storage;
  late ProviderContainer container;

  RouterController controller() =>
      container.read(routerControllerProvider.notifier);

  setUp(() {
    storage = MockKaziLocalStorageService();

    when(storage.write<bool>(any, any)).thenAnswer((_) => Future<void>.value());
    when(
      storage.read<bool>(StorageKeys.showOnboarding),
    ).thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [localStorageProvider.overrideWith((ref) async => storage)],
    );
  });

  tearDown(() => container.dispose());

  group('resetOnboarding', () {
    test('Should persist that the onboarding was not seen', () async {
      await container.read(routerControllerProvider.future);

      await controller().resetOnboarding();

      verify(storage.write<bool>(StorageKeys.showOnboarding, false)).called(1);
    });

    test('Should expose it without waiting for a new storage read', () async {
      await container.read(routerControllerProvider.future);

      await controller().resetOnboarding();

      expect(await container.read(routerControllerProvider.future), false);
    });
  });
}
