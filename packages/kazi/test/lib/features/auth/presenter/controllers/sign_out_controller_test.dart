import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/auth/data/services/errors/firebase_sign_in_error.dart';
import 'package:kazi/features/auth/presenter/controllers/account_action_state.dart';
import 'package:kazi/features/auth/presenter/controllers/sign_out_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fakes/fake_analytics_service.dart';
import '../../../../../utils/fakes/fake_auth_service.dart';
import '../../../../../utils/fakes/fake_local_storage.dart';
import '../../../../../utils/test_helper.dart';

void main() {
  late FakeAuthService authService;
  late FakeAnalyticsService analytics;
  late FakeLocalStorage storage;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  SignOutController controller() =>
      container.read(signOutControllerProvider.notifier);
  AccountActionState state() => container.read(signOutControllerProvider);

  setUp(() {
    authService = FakeAuthService(user: userMock);
    analytics = FakeAnalyticsService();
    storage = FakeLocalStorage({'some_key': 'value'});

    container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
        authServiceProvider.overrideWithValue(authService),
        localStorageProvider.overrideWith((ref) async => storage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    authService.dispose();
  });

  test('signs out and wipes the local storage', () async {
    await controller().signOut();

    expect(authService.signOutCalled, isTrue);
    expect(storage.values, isEmpty);
    expect(analytics.events, contains(AnalyticsEvent.logout));
    expect(state().status, AccountActionStatus.idle);
  });

  test('signs out once on a repeated tap', () async {
    await Future.wait([controller().signOut(), controller().signOut()]);

    expect(
      analytics.events.where((event) => event == AnalyticsEvent.logout),
      hasLength(1),
    );
  });

  test('is running until the sign-out completes', () async {
    final pending = controller().signOut();

    expect(state().isRunning, isTrue);
    await pending;
    expect(state().isRunning, isFalse);
  });

  test('reports a failure and keeps the local storage', () async {
    authService.signOutError = FirebaseSignInError();

    await controller().signOut();

    expect(state().status, AccountActionStatus.error);
    expect(state().errorMessage, KaziLocalizations.current.errorUnknowError);
    expect(storage.values, isNotEmpty);
  });
}
