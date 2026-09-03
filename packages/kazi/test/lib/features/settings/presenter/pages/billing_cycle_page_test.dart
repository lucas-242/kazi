import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/features/settings/presenter/pages/billing_cycle_page.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'billing_cycle_page_test.mocks.dart';

@GenerateMocks([UserSettingsRepository, AuthService])
void main() {
  TestHelper.loadAppLocalizations();

  late MockUserSettingsRepository userSettings;
  late MockAuthService authService;

  setUp(() {
    userSettings = MockUserSettingsRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.setBillingCycle(any, any)).thenAnswer((_) async {});
  });

  // The page reads `billingCycleProvider` synchronously in `initState`, so the
  // controller's async build must already be resolved before the widget is
  // pumped — otherwise it seeds itself from the loading-state default instead
  // of the cycle under test, exactly as it would if this page could somehow be
  // reached before the app's own pre-warm of this keepAlive provider.
  Future<void> pumpPage(WidgetTester tester, BillingCycle initial) async {
    when(
      userSettings.get(any),
    ).thenAnswer((_) async => UserSettings(billingCycle: initial));

    final container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
    addTearDown(container.dispose);
    await container.read(billingCycleControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            KaziLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: KaziLocalizations.delegate.supportedLocales,
          theme: KaziThemeSettings.light(),
          home: const BillingCyclePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [
    const Size(320, 640),
    const Size(375, 812),
    const Size(414, 896),
  ]) {
    testWidgets(
      'Should lay out without overflow at ${size.width}x${size.height} '
      'for a monthly cycle',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await pumpPage(tester, const MonthlyCycle(anchorDay: 5));

        expect(tester.takeException(), isNull);
        expect(find.text('Save cycle'), findsOneWidget);
      },
    );
  }

  testWidgets('Should switch to the weekday chips for a weekly cycle', (
    tester,
  ) async {
    await pumpPage(tester, const WeeklyCycle(anchorWeekday: DateTime.friday));

    expect(tester.takeException(), isNull);
    expect(find.text('Save cycle'), findsOneWidget);
  });

  testWidgets('Should show "Other · day" when the anchor is not a quick pick', (
    tester,
  ) async {
    await pumpPage(tester, const MonthlyCycle(anchorDay: 12));

    expect(tester.takeException(), isNull);
    expect(find.text('Other · 12'), findsOneWidget);
  });
}
