import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/utils/date_range.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/fakes/fake_analytics_service.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'dashboard_controller_test.mocks.dart';

@GenerateMocks([
  ServiceTypeRepository,
  ServicesRepository,
  AuthService,
  UserSettingsRepository,
])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late MockUserSettingsRepository userSettings;
  late TimeService timeService;
  late ServicesService servicesService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  DashboardController controller() =>
      container.read(dashboardControllerProvider.notifier);
  DashboardState state() => container.read(dashboardControllerProvider);

  // Flushes microtasks so fire-and-forget async work in the controller settles.
  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();
    userSettings = MockUserSettingsRepository();
    timeService = LocalTimeService();
    servicesService = LocalServicesService(timeService);

    when(authService.user).thenReturn(userMock);
    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesWithIdsMock);
    // The home queries the whole billing cycle, so start *and* end are passed.
    when(
      servicesRepository.get(any, any, any),
    ).thenAnswer((_) async => servicesWithTypeIdMock);
    when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());

    container = ProviderContainer(
      overrides: [
        // The controller reports what it rendered. Without this the real
        // composite is built, and its Firebase sink needs an initialised
        // Firebase app a unit test does not have.
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        timeServiceProvider.overrideWithValue(timeService),
        servicesServiceProvider.overrideWithValue(servicesService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('onInit', () {
    test('loads services ordered by dateDesc and status success', () async {
      await controller().onInit();

      expect(state().status, BaseStateStatus.success);
      expect(
        state().services,
        servicesService.orderServices(
          servicesWithTypesMock,
          OrderBy.dateDesc,
          currency: SupportedCurrency.usd,
          rateBook: const RateBook.empty(),
        ),
      );
    });

    test('status noData when there are no services', () async {
      when(servicesRepository.get(any, any, any)).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().services, isEmpty);
    });

    test(
      'status error with errorToGetServices when get throws AppError',
      () async {
        when(servicesRepository.get(any, any, any)).thenThrow(
          ExternalError(KaziLocalizations.current.errorToGetServices),
        );

        await controller().onInit();

        expect(state().status, BaseStateStatus.error);
        expect(
          state().callbackMessage,
          KaziLocalizations.current.errorToGetServices,
        );
      },
    );

    test(
      'status error with errorToGetServiceTypes when types get throws',
      () async {
        when(serviceTypeRepository.get(any)).thenThrow(
          ExternalError(KaziLocalizations.current.errorToGetServiceTypes),
        );

        await controller().onInit();

        expect(state().status, BaseStateStatus.error);
        expect(
          state().callbackMessage,
          KaziLocalizations.current.errorToGetServiceTypes,
        );
      },
    );

    test('status error with unknowError on unexpected exception', () async {
      when(serviceTypeRepository.get(any)).thenThrow(Exception());

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('onRefresh', () {
    test('ends in success with the refetched services', () async {
      await controller().onRefresh();
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(state().services, servicesWithTypesMock);
    });
  });

  group('Billing cycle', () {
    /// Rebuilds the container against a fixed clock and a stored cycle, so the
    /// window the repository is queried over is fully determined.
    ProviderContainer containerAt(DateTime today, {BillingCycle? cycle}) {
      final clock = LocalTimeService(today);
      when(userSettings.get(any)).thenAnswer(
        (_) async =>
            UserSettings(billingCycle: cycle ?? BillingCycle.monthlyDefault),
      );

      return ProviderContainer(
        overrides: [
          servicesRepositoryProvider.overrideWithValue(servicesRepository),
          serviceTypeRepositoryProvider.overrideWithValue(
            serviceTypeRepository,
          ),
          authServiceProvider.overrideWithValue(authService),
          userSettingsRepositoryProvider.overrideWithValue(userSettings),
          timeServiceProvider.overrideWithValue(clock),
          servicesServiceProvider.overrideWithValue(
            LocalServicesService(clock),
          ),
          analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        ],
      );
    }

    DateRange queriedRange() {
      final captured = verify(
        servicesRepository.get(any, captureAny, captureAny),
      ).captured;
      return DateRange(
        start: captured[0] as DateTime,
        end: captured[1] as DateTime,
      );
    }

    test(
      'Should query the calendar month for a user with no cycle set',
      () async {
        final scoped = containerAt(DateTime(2026, 8, 20));
        addTearDown(scoped.dispose);

        await scoped.read(dashboardControllerProvider.notifier).onInit();

        expect(
          queriedRange(),
          DateRange(
            start: DateTime(2026, 8),
            end: DateTime(2026, 8, 31, 23, 59, 59),
          ),
        );
      },
    );

    test('Should query the configured cycle window', () async {
      final scoped = containerAt(
        DateTime(2026, 8, 20),
        cycle: const MonthlyCycle(anchorDay: 5),
      );
      addTearDown(scoped.dispose);

      await scoped.read(dashboardControllerProvider.notifier).onInit();

      expect(
        queriedRange(),
        DateRange(
          start: DateTime(2026, 8, 6),
          end: DateTime(2026, 9, 5, 23, 59, 59),
        ),
      );
    });

    test('Should publish the window and the countdown on the state', () async {
      final scoped = containerAt(
        DateTime(2026, 8, 14),
        cycle: const MonthlyCycle(anchorDay: 5),
      );
      addTearDown(scoped.dispose);

      await scoped.read(dashboardControllerProvider.notifier).onInit();
      final published = scoped.read(dashboardControllerProvider);

      expect(published.cycleRange?.start, DateTime(2026, 8, 6));
      expect(published.daysUntilClose, 22);
    });

    /// Fail-open all the way up: an unreachable settings document must not stop
    /// the home from rendering, it just falls back to the calendar month.
    test(
      'Should fall back to the calendar month when settings are unreadable',
      () async {
        final scoped = containerAt(DateTime(2026, 8, 20));
        // After containerAt, which stubs a successful read of its own.
        when(userSettings.get(any)).thenThrow(Exception());
        addTearDown(scoped.dispose);

        await scoped.read(dashboardControllerProvider.notifier).onInit();

        expect(
          scoped.read(dashboardControllerProvider).status,
          BaseStateStatus.success,
        );
        expect(queriedRange().start, DateTime(2026, 8));
      },
    );
  });

  group('State properties', () {
    DashboardState buildState() => DashboardState(
      services: servicesWithTypesMock,
      status: BaseStateStatus.success,
      selectedOrderBy: OrderBy.dateDesc,
    );

    test('totalValue should be 210', () {
      expect(buildState().totals.value, 210);
    });

    test('total commission should be 105', () {
      expect(buildState().totals.commission, 105);
    });

    test('total withheld should be 105', () {
      expect(buildState().totals.withheld, 105);
    });
  });
}
