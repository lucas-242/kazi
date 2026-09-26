import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/controllers/hint_controller.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/pump_page.dart';
import '../../../../../utils/test_overrides.dart';

void main() {
  late TestFakes fakes;
  late ValueNotifier<bool> isDeserved;

  setUp(() {
    fakes = TestFakes();
    isDeserved = ValueNotifier(true);
  });

  tearDown(() {
    isDeserved.dispose();
    fakes.dispose();
  });

  String title() => KaziLocalizations.current.hintFabTitle;

  Future<ProviderContainer> pumpAnchor(
    WidgetTester tester, {
    bool asTab = false,
  }) async {
    final container = await pumpPage(
      tester,
      _AnchorPage(isDeserved: isDeserved, asTab: asTab),
      fakes: fakes,
      surfaceSize: const Size(400, 800),
    );
    container.read(hintControllerProvider.notifier).markStartupSettled();
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows the hint over its anchor', (tester) async {
    await pumpAnchor(tester);

    expect(find.text(title()), findsOneWidget);
  });

  testWidgets('leaves the anchor uncovered', (tester) async {
    await pumpAnchor(tester);

    // Inside the spotlight, off the icon: whatever is painted there must be
    // the button itself, not the mark drawn over it.
    final probe = tester.getCenter(find.byKey(_AnchorPage.anchorKey)).translate(
      0,
      20,
    );
    const outside = Offset(20, 20);
    final withMark = await _pixelAt(tester, probe);
    final dimmed = await _pixelAt(tester, outside);

    await tester.tap(find.text(KaziLocalizations.current.hintGotIt));
    await tester.pumpAndSettle();
    final withoutMark = await _pixelAt(tester, probe);
    final undimmed = await _pixelAt(tester, outside);

    expect(withMark, withoutMark);
    // And the scrim really was up: everything outside the spotlight dimmed.
    expect(dimmed, isNot(undimmed));
  });

  testWidgets('does not show on an inactive tab, and shows on return', (
    tester,
  ) async {
    isDeserved.value = false;
    await pumpAnchor(tester, asTab: true);
    expect(find.text(title()), findsNothing);

    isDeserved.value = true;
    await tester.pumpAndSettle();

    expect(find.text(title()), findsOneWidget);
  });

  testWidgets('spends the hint even when the anchor stops deserving it', (
    tester,
  ) async {
    final container = await pumpAnchor(tester);
    expect(find.text(title()), findsOneWidget);

    isDeserved.value = false;
    await tester.pumpAndSettle();

    expect(find.text(title()), findsNothing);
    expect(fakes.storage.values[OnboardingHint.fab.storageKey], isTrue);
    expect(
      await container
          .read(hintControllerProvider.notifier)
          .shouldShow(OnboardingHint.fab),
      isFalse,
    );
  });

  testWidgets('a hint taken down without a tap is not logged as dismissed', (
    tester,
  ) async {
    await pumpAnchor(tester);

    isDeserved.value = false;
    await tester.pumpAndSettle();

    expect(fakes.analytics.events, isNot(contains(AnalyticsEvent.hintDismissed)));
  });

  testWidgets('the next screen still gets its own hint in the same session', (
    tester,
  ) async {
    final activeTab = ValueNotifier(0);
    addTearDown(activeTab.dispose);

    final container = await pumpPage(
      tester,
      _TwoTabsPage(activeTab: activeTab),
      fakes: fakes,
      surfaceSize: const Size(400, 800),
    );
    container.read(hintControllerProvider.notifier).markStartupSettled();
    await tester.pumpAndSettle();

    await tester.tap(find.text(KaziLocalizations.current.hintGotIt));
    await tester.pumpAndSettle();

    activeTab.value = 1;
    await tester.pumpAndSettle();

    expect(
      find.text(KaziLocalizations.current.hintReceivedTitle),
      findsOneWidget,
    );
  });

  testWidgets('the loser of a screen takes its turn as the winner goes down', (
    tester,
  ) async {
    final container = await pumpPage(
      tester,
      const _SameScreenPage(),
      fakes: fakes,
      surfaceSize: const Size(400, 800),
    );
    container.read(hintControllerProvider.notifier).markStartupSettled();
    await tester.pumpAndSettle();

    final first = find.text(title()).evaluate().isNotEmpty
        ? title()
        : KaziLocalizations.current.hintReceivedTitle;
    final second = first == title()
        ? KaziLocalizations.current.hintReceivedTitle
        : title();

    expect(find.text(first), findsOneWidget);
    expect(find.text(second), findsNothing);

    await tester.tap(find.text(KaziLocalizations.current.hintGotIt));
    await tester.pumpAndSettle();

    // The slot is offered on only after a pause.
    expect(find.text(second), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Neither anchor remounted and neither `enabled` moved: the slot coming
    // free is the whole trigger.
    expect(find.text(second), findsOneWidget);
  });

  testWidgets('records the hint as seen once dismissed', (tester) async {
    await pumpAnchor(tester);

    await tester.tap(find.text(KaziLocalizations.current.hintGotIt));
    await tester.pumpAndSettle();

    expect(find.text(title()), findsNothing);
    expect(fakes.storage.values[OnboardingHint.fab.storageKey], isTrue);
  });
}

Future<int> _pixelAt(WidgetTester tester, Offset point) async {
  final pixel = await tester.runAsync(() async {
    final image = await captureImage(find.byType(MaterialApp).evaluate().single);
    final bytes = await image.toByteData();
    final offset = ((point.dy.floor() * image.width) + point.dx.floor()) * 4;
    return bytes!.getUint32(offset);
  });

  return pixel!;
}

/// [isDeserved] drives both conditions that retract a hint — the anchor's own
/// `enabled`, and the ticker mode go_router switches off on an inactive branch
/// — so a test can flip either without rebuilding the state under test.
class _AnchorPage extends StatelessWidget {
  const _AnchorPage({required this.isDeserved, required this.asTab});

  static const anchorKey = Key('anchor');

  final ValueListenable<bool> isDeserved;
  final bool asTab;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDeserved,
      builder: (context, isDeservedNow, _) => TickerMode(
        enabled: !asTab || isDeservedNow,
        child: Scaffold(
          floatingActionButton: HintAnchor(
            hint: OnboardingHint.fab,
            enabled: asTab || isDeservedNow,
            child: FloatingActionButton(
              key: anchorKey,
              // Not the brand yellow the mark paints with, so that a mark
              // covering the button would change the pixels under it.
              backgroundColor: const Color(0xFF00A0FF),
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two hints sharing one screen, both deserving from the first frame.
class _SameScreenPage extends StatelessWidget {
  const _SameScreenPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          HintAnchor(
            hint: OnboardingHint.markReceived,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt),
            ),
          ),
        ],
      ),
      floatingActionButton: HintAnchor(
        hint: OnboardingHint.fab,
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Two hints on two tabs, the way the shell arranges them: only the active
/// one's ticker mode is on.
class _TwoTabsPage extends StatelessWidget {
  const _TwoTabsPage({required this.activeTab});

  final ValueListenable<int> activeTab;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: activeTab,
      builder: (context, tab, _) => Scaffold(
        body: IndexedStack(
          index: tab,
          children: [
            TickerMode(
              enabled: tab == 0,
              child: HintAnchor(
                hint: OnboardingHint.fab,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            TickerMode(
              enabled: tab == 1,
              child: HintAnchor(
                hint: OnboardingHint.markReceived,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('received'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
