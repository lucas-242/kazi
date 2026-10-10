import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/auth/domain/repositories/account_data_repository.dart';
import 'package:kazi/features/auth/presenter/controllers/delete_account_controller.dart';
import 'package:kazi/features/auth/presenter/controllers/account_action_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fakes/fake_analytics_service.dart';
import '../../../../../utils/fakes/fake_auth_service.dart';
import '../../../../../utils/fakes/fake_local_storage.dart';
import '../../../../../utils/test_helper.dart';
import 'delete_account_controller_test.mocks.dart';

@GenerateMocks([AccountDataRepository])
void main() {
  late MockAccountDataRepository accountData;
  late FakeAuthService authService;
  late FakeAnalyticsService analytics;
  late FakeLocalStorage storage;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  DeleteAccountController controller() =>
      container.read(deleteAccountControllerProvider.notifier);
  AccountActionState state() => container.read(deleteAccountControllerProvider);

  setUp(() {
    accountData = MockAccountDataRepository();
    authService = FakeAuthService(user: userMock);
    analytics = FakeAnalyticsService();
    storage = FakeLocalStorage({'some_key': 'value'});

    when(accountData.deleteAll(any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
        authServiceProvider.overrideWithValue(authService),
        accountDataRepositoryProvider.overrideWithValue(accountData),
        localStorageProvider.overrideWith((ref) async => storage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    authService.dispose();
  });

  test('deletes the data, then the account, then the local state', () async {
    await controller().deleteAccount();

    verify(accountData.deleteAll(userMock.uid)).called(1);
    expect(authService.deleteAccountCalled, true);
    expect(storage.values, isEmpty);
    expect(analytics.events, contains(AnalyticsEvent.accountDeleted));
    expect(state().status, AccountActionStatus.idle);
  });

  test('deletes once on a repeated tap', () async {
    await Future.wait([
      controller().deleteAccount(),
      controller().deleteAccount(),
    ]);

    verify(accountData.deleteAll(userMock.uid)).called(1);
  });

  test('touches nothing when the confirmation sign-in is cancelled', () async {
    authService.reauthenticateSucceeds = false;

    await controller().deleteAccount();

    verifyNever(accountData.deleteAll(any));
    expect(authService.deleteAccountCalled, false);
    expect(storage.values, isNotEmpty);
    expect(state().status, AccountActionStatus.idle);
  });

  test('keeps the account when the data cannot be deleted', () async {
    // Deleting the account first would strand its data with no owner able to
    // reach it; failing here leaves everything retryable.
    when(
      accountData.deleteAll(any),
    ).thenThrow(ExternalError(KaziLocalizations.current.errorToDeleteAccount));

    await controller().deleteAccount();

    expect(authService.deleteAccountCalled, false);
    expect(authService.user, isNotNull);
    expect(state().status, AccountActionStatus.error);
    expect(
      state().errorMessage,
      KaziLocalizations.current.errorToDeleteAccount,
    );
    expect(
      analytics.parametersOf(AnalyticsEvent.accountDeletionFailed),
      {'reason': 'ExternalError'},
    );
  });

  test('does nothing without a signed-in user', () async {
    authService.user = null;

    await controller().deleteAccount();

    verifyNever(accountData.deleteAll(any));
    expect(state().status, AccountActionStatus.idle);
  });
}
