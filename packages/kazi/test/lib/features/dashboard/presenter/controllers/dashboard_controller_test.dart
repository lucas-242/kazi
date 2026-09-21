import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/data/services/local_service_organizer.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/utils/date_range.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide CatalogItemRepository, Service;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/fakes/fake_analytics_service.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'dashboard_controller_test.mocks.dart';

@GenerateMocks([
  CatalogItemRepository,
  ServicesRepository,
  AuthService,
  UserSettingsRepository,
])
void main() {
  late MockCatalogItemRepository catalogItemRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late MockUserSettingsRepository userSettings;
  late TimeService timeService;
  late ServiceOrganizer serviceOrganizer;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  DashboardController controller() =>
      container.read(dashboardControllerProvider.notifier);
  DashboardState state() => container.read(dashboardControllerProvider);

  // Flushes microtasks so fire-and-forget async work in the controller settles.
  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() async {
    catalogItemRepository = MockCatalogItemRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();
    userSettings = MockUserSettingsRepository();
    timeService = LocalTimeService();
    serviceOrganizer = LocalServiceOrganizer(timeService);

    when(authService.user).thenReturn(userMock);
    when(
      catalogItemRepository.get(any),
    ).thenAnswer((_) async => catalogItemsWithIdsMock);
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
        catalogItemRepositoryProvider.overrideWithValue(catalogItemRepository),
        authServiceProvider.overrideWithValue(authService),
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        timeServiceProvider.overrideWithValue(timeService),
        serviceOrganizerProvider.overrideWithValue(serviceOrganizer),
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
        serviceOrganizer.orderServices(
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
      'status error with errorToGetCatalogItems when types get throws',
      () async {
        when(catalogItemRepository.get(any)).thenThrow(
          ExternalError(KaziLocalizations.current.errorToGetCatalogItems),
        );

        await controller().onInit();

        expect(state().status, BaseStateStatus.error);
        expect(
          state().callbackMessage,
          KaziLocalizations.current.errorToGetCatalogItems,
        );
      },
    );

    test('status error with unknowError on unexpected exception', () async {
      when(catalogItemRepository.get(any)).thenThrow(Exception());

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

    // Regression: two refreshes fired in quick succession used to be able to
    // finish out of order, since only leaving the tab bumped the generation a
    // read compares itself against — a read starting never did. The first
    // refresh's answer could then land *after* the second one's had already
    // settled, silently overwriting fresher data with stale data. The same
    // guard also protects a manual pull-to-refresh racing the billing-cycle
    // listener's own automatic `onRefresh()`.
    test(
      'a refresh that resolves after a later one does not overwrite it',
      () async {
        final clock = LocalTimeService(DateTime(2026, 3, 17));
        final scoped = ProviderContainer(
          overrides: [
            analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
            servicesRepositoryProvider.overrideWithValue(servicesRepository),
            catalogItemRepositoryProvider.overrideWithValue(
              catalogItemRepository,
            ),
            authServiceProvider.overrideWithValue(authService),
            userSettingsRepositoryProvider.overrideWithValue(userSettings),
            timeServiceProvider.overrideWithValue(clock),
            serviceOrganizerProvider.overrideWithValue(
              LocalServiceOrganizer(clock),
            ),
          ],
        );
        addTearDown(scoped.dispose);
        final scopedController = scoped.read(
          dashboardControllerProvider.notifier,
        );

        await scopedController.onInit();

        // The first refresh hangs until released below, with a non-empty
        // answer; the second resolves immediately, empty — simulating its
        // response arriving first even though it was requested second.
        final staleFetch = Completer<List<Service>>();
        var callCount = 0;
        when(servicesRepository.get(any, any, any)).thenAnswer((_) {
          callCount++;
          return callCount == 1 ? staleFetch.future : Future.value(const []);
        });

        final staleRefresh = scopedController.onRefresh();
        await pump();
        await scopedController.onRefresh();

        staleFetch.complete(servicesWithTypesMock);
        await staleRefresh;

        expect(
          scoped.read(dashboardControllerProvider).status,
          BaseStateStatus.noData,
        );
        expect(scoped.read(dashboardControllerProvider).services, isEmpty);
      },
    );
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
          catalogItemRepositoryProvider.overrideWithValue(
            catalogItemRepository,
          ),
          authServiceProvider.overrideWithValue(authService),
          userSettingsRepositoryProvider.overrideWithValue(userSettings),
          timeServiceProvider.overrideWithValue(clock),
          serviceOrganizerProvider.overrideWithValue(
            LocalServiceOrganizer(clock),
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

    // What the user actually asks for when they change the Payment Cycle in
    // Ajustes: the home must not wait to be revisited — it refetches on its
    // own the moment the setting's write lands, via the `ref.listen` in
    // `DashboardController.build`.
    test(
      'Refetches on its own when the Payment Cycle setting changes',
      () async {
        final scoped = containerAt(
          DateTime(2026, 8, 20),
          cycle: const MonthlyCycle(anchorDay: 5),
        );
        addTearDown(scoped.dispose);

        await scoped.read(dashboardControllerProvider.notifier).onInit();
        expect(
          scoped.read(dashboardControllerProvider).cycleRange,
          DateRange(
            start: DateTime(2026, 8, 6),
            end: DateTime(2026, 9, 5, 23, 59, 59),
          ),
        );

        // The same path the Settings page's "Salvar" button uses.
        when(userSettings.setBillingCycle(any, any)).thenAnswer((_) async {});
        await scoped
            .read(billingCycleControllerProvider.notifier)
            .select(const FortnightlyCycle(anchorDay: 5));
        // The listener's own `onRefresh()` is fire-and-forget, not awaited by
        // `select` — give its chain of awaits (cycle, services, catalogue,
        // rates) room to settle.
        await pump();
        await pump();

        expect(
          scoped.read(dashboardControllerProvider).cycleRange,
          const FortnightlyCycle(
            anchorDay: 5,
          ).currentCycle(DateTime(2026, 8, 20)),
        );
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
