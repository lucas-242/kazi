import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/data/services/local_service_organizer.dart';
import 'package:kazi/features/services/domain/errors/services_error.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'agenda_controller_test.mocks.dart';

@GenerateMocks([ServicesRepository, CatalogItemRepository, AuthService])
void main() {
  final now = DateTime(2026, 10, 22, 9);
  final monday = DateTime(2026, 10, 19);
  final sunday = DateTime(2026, 10, 25);
  final week = DateTimeRange(start: monday, end: sunday);

  late MockServicesRepository servicesRepository;
  late MockCatalogItemRepository catalogItemRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  Service service(
    String id,
    DateTime date, {
    ClockTime? start,
    Duration? duration,
  }) => Service(
    id: id,
    value: 100,
    catalogItemId: catalogItemsWithIdsMock.first.id,
    date: date,
    startTime: start,
    duration: duration,
    userId: userMock.uid,
  );

  AgendaController controller() =>
      container.read(agendaControllerProvider.notifier);

  List<String> drawnIds() =>
      container.read(agendaControllerProvider).entries.map((entry) {
        return entry.service.id;
      }).toList();

  void answerWindow(List<Service> inWindow, [List<Service> multiDay = const []]) {
    when(
      servicesRepository.get(any, any, any),
    ).thenAnswer((_) async => inWindow);
    when(
      servicesRepository.getMultiDay(any, any, any),
    ).thenAnswer((_) async => multiDay);
  }

  setUp(() {
    servicesRepository = MockServicesRepository();
    catalogItemRepository = MockCatalogItemRepository();
    authService = MockAuthService();

    final clock = LocalTimeService(now);

    when(authService.user).thenReturn(userMock);
    when(
      catalogItemRepository.get(any),
    ).thenAnswer((_) async => catalogItemsWithIdsMock);
    answerWindow(const []);

    container = ProviderContainer(
      overrides: [
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        catalogItemRepositoryProvider.overrideWithValue(catalogItemRepository),
        authServiceProvider.overrideWithValue(authService),
        timeServiceProvider.overrideWithValue(clock),
        serviceOrganizerProvider.overrideWithValue(
          LocalServiceOrganizer(clock),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('opens on today, in the day mode', () {
    final state = container.read(agendaControllerProvider);

    expect(state.mode, KaziAgendaMode.day);
    expect(state.firstVisibleDay, DateTime(2026, 10, 22));
    expect(state.lastVisibleDay, DateTime(2026, 10, 22));
  });

  test('reads the visible days by date, to the end of the last one', () async {
    await controller().onVisibleRangeChanged(week);

    verify(
      servicesRepository.get(
        userMock.uid,
        monday,
        DateTime(2026, 10, 25, 23, 59, 59),
      ),
    ).called(1);
    expect(
      container.read(agendaControllerProvider).status,
      BaseStateStatus.success,
    );
  });

  test('looks back for long services that started before the window', () async {
    await controller().onVisibleRangeChanged(week);

    verify(
      servicesRepository.getMultiDay(
        userMock.uid,
        monday.subtract(KaziDurationPicker.longest),
        DateTime(2026, 10, 18, 23, 59, 59),
      ),
    ).called(1);
  });

  test(
    'keeps only the earlier services that run into the window, once',
    () async {
      final intoTheWeek = service(
        'into',
        DateTime(2026, 10, 17),
        start: const ClockTime(10, 0),
        duration: const Duration(days: 3),
      );
      final overBefore = service(
        'over',
        DateTime(2026, 10, 10),
        start: const ClockTime(10, 0),
        duration: const Duration(days: 2),
      );
      final inside = service('inside', DateTime(2026, 10, 21));
      answerWindow([inside, inside], [intoTheWeek, overBefore]);

      await controller().onVisibleRangeChanged(week);

      expect(drawnIds(), unorderedEquals(['inside', 'into']));
    },
  );

  test('attaches the catalog item, for the tile to name and colour', () async {
    answerWindow([service('a', DateTime(2026, 10, 21))]);

    await controller().onVisibleRangeChanged(week);

    final drawn = container.read(agendaControllerProvider).entries.single;
    expect(drawn.service.catalogItem?.name, catalogItemsWithIdsMock.first.name);
  });

  test('a window already read is not read again', () async {
    await controller().onVisibleRangeChanged(week);
    await controller().onVisibleRangeChanged(
      DateTimeRange(start: DateTime(2026, 10, 22), end: DateTime(2026, 10, 22)),
    );

    verify(servicesRepository.get(any, any, any)).called(1);
    expect(
      container.read(agendaControllerProvider).firstVisibleDay,
      DateTime(2026, 10, 22),
    );
  });

  test('draws only what falls on the days on screen', () async {
    answerWindow([
      service('tue', DateTime(2026, 10, 20)),
      service('thu', DateTime(2026, 10, 22)),
    ]);
    await controller().onVisibleRangeChanged(week);

    await controller().onVisibleRangeChanged(
      DateTimeRange(start: DateTime(2026, 10, 22), end: DateTime(2026, 10, 22)),
    );

    expect(drawnIds(), ['thu']);
  });

  test('a write elsewhere replaces what was held', () async {
    answerWindow([service('gone', DateTime(2026, 10, 20))]);
    await controller().onVisibleRangeChanged(week);

    answerWindow([service('new', DateTime(2026, 10, 21))]);
    await controller().onChangeServices();

    expect(drawnIds(), ['new']);
  });

  test('a write elsewhere costs nothing before the agenda opens', () async {
    await controller().onChangeServices();

    verifyNever(servicesRepository.get(any, any, any));
  });

  test('a failed read leaves the error status, and a retry reads again', () async {
    when(
      servicesRepository.get(any, any, any),
    ).thenThrow(ServicesError(ServicesFailure.load));
    await controller().onVisibleRangeChanged(week);

    expect(
      container.read(agendaControllerProvider).status,
      BaseStateStatus.error,
    );

    answerWindow([service('a', DateTime(2026, 10, 21))]);
    await controller().onRefresh();

    expect(drawnIds(), ['a']);
  });

  test('a read abandoned by leaving the tab is thrown away', () async {
    answerWindow([service('late', DateTime(2026, 10, 21))]);

    final read = controller().onVisibleRangeChanged(week);
    controller().cancelPendingRead();
    await read;

    expect(drawnIds(), isEmpty);

    await controller().resumeAbandonedRead();
    expect(drawnIds(), ['late']);
  });

  test('stamps written elsewhere patch the loaded services', () async {
    answerWindow([
      service(
        'a',
        DateTime(2026, 10, 21),
        start: const ClockTime(10, 0),
        duration: const Duration(hours: 1),
      ),
    ]);
    await controller().onVisibleRangeChanged(week);

    final finishedAt = DateTime(2026, 10, 21, 11);
    controller().applyFinish({'a': finishedAt, 'unknown': finishedAt});
    controller().applyReceipt({'a': now});

    final patched = container.read(agendaControllerProvider).services.single;
    expect(patched.finishedAt, finishedAt);
    expect(patched.receivedAt, now);

    controller().applyCancellation({'a': null});
    controller().applyFinish({'a': null});
    expect(
      container.read(agendaControllerProvider).services.single.isFinished,
      isFalse,
    );
  });
}
