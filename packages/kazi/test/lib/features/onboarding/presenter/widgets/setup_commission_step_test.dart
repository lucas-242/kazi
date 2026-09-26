import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/pages/guided_setup_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/test_helper.dart';

void main() {
  TestHelper.loadAppLocalizations();

  late ProviderContainer container;

  Future<void> pumpStep(
    WidgetTester tester,
    List<SetupCatalogItem> items,
  ) async {
    container = ProviderContainer(
      overrides: [
        guidedSetupControllerProvider.overrideWith(
          () => _FakeSetupController(
            GuidedSetupState(
              status: BaseStateStatus.readyToUserInput,
              userId: 'user',
              currency: SupportedCurrency.brl,
              step: SetupStep.commission,
              items: items,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [KaziLocalizations.delegate],
          supportedLocales: KaziLocalizations.delegate.supportedLocales,
          theme: KaziThemeSettings.light(),
          home: const GuidedSetupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool isChipSelected(WidgetTester tester, String label) => tester
      .widget<KaziChip>(find.widgetWithText(KaziChip, label))
      .isSelected;

  GuidedSetupState current() =>
      container.read(guidedSetupControllerProvider).requireValue;

  const kit = [
    SetupCatalogItem(id: 'a', name: 'Cut', commissionPercent: 40),
    SetupCatalogItem(id: 'b', name: 'Colour', commissionPercent: 40),
  ];

  const saved = [
    SetupCatalogItem(
      id: 'a',
      existingItemId: 'a',
      name: 'Cut',
      commissionPercent: 60,
      hasSavedCommission: true,
    ),
    SetupCatalogItem(
      id: 'b',
      existingItemId: 'b',
      name: 'Colour',
      commissionPercent: 70,
      hasSavedCommission: true,
    ),
  ];

  testWidgets('Should select the tapped chip and apply it to every item', (
    tester,
  ) async {
    await pumpStep(tester, kit);

    await tester.tap(find.widgetWithText(KaziChip, '50%'));
    await tester.pumpAndSettle();

    expect(isChipSelected(tester, '50%'), isTrue);
    expect(find.text('50%'), findsNWidgets(3));
    expect(
      current().items.every((item) => item.commissionPercent == 50),
      isTrue,
    );
  });

  testWidgets('Should apply a chip over commissions an account had saved', (
    tester,
  ) async {
    await pumpStep(tester, saved);

    await tester.tap(find.widgetWithText(KaziChip, '30%'));
    await tester.pumpAndSettle();

    expect(isChipSelected(tester, '30%'), isTrue);
    expect(
      current().items.every((item) => item.commissionPercent == 30),
      isTrue,
    );
  });

  testWidgets('Should select the chip the saved commissions agree on', (
    tester,
  ) async {
    await pumpStep(tester, [
      for (final item in saved) item.copyWith(commissionPercent: 50),
    ]);

    expect(isChipSelected(tester, '50%'), isTrue);
    expect(current().canContinueFromCommission, isTrue);
  });

  testWidgets('Should keep a per-item exception when a chip is tapped', (
    tester,
  ) async {
    await pumpStep(tester, kit);
    container
        .read(guidedSetupControllerProvider.notifier)
        .setCommissionFor('a', 55);

    await tester.tap(find.widgetWithText(KaziChip, '100%'));
    await tester.pumpAndSettle();

    expect(isChipSelected(tester, '100%'), isTrue);
    expect(current().items.map((item) => item.commissionPercent), [55, 100]);
  });
}

class _FakeSetupController extends GuidedSetupController {
  _FakeSetupController(this._initial);

  final GuidedSetupState _initial;

  @override
  Future<GuidedSetupState> build() async => _initial;
}
