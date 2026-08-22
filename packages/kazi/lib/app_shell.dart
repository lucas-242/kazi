import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/tap_probe.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/controllers/whats_new_controller.dart';
import 'package:kazi/features/onboarding/presenter/pages/whats_new_page.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/onboarding/presenter/widgets/replay_consent_sheet.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

/// The tab indices this file has something to say about, from the branch order
/// in `AppRouter.buildRoutes`.
abstract final class _Tab {
  static const home = 0;
  static const clients = 2;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFirstFrameChecks();
    });
  }

  /// Strictly sequential: the update dialog, the release announcement and the
  /// contextual hints all want the root navigator, and two of them arriving
  /// together is how a person ends up dismissing something they never read.
  Future<void> _runFirstFrameChecks() async {
    await _maybeShowOptionalUpdate();
    if (!mounted) return;
    await _maybeShowWhatsNew();
    if (!mounted) return;
    // Last in the chain, and only for people the guided setup never reached —
    // the `active` and `done` segments skip it, and they are exactly the
    // long-standing users whose sessions say most about why someone leaves.
    // `askIfNeeded` is a no-op once the question has been answered.
    await ReplayConsentSheet.askIfNeeded(context, ref);
  }

  Future<void> _maybeShowWhatsNew() async {
    final controller = ref.read(whatsNewControllerProvider.notifier);
    if (!await controller.shouldShow()) return;
    if (!mounted) return;

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) =>
            WhatsNewPage(onClose: () => Navigator.of(routeContext).pop()),
      ),
    );
    await controller.markSeen();
  }

  Future<void> _maybeShowOptionalUpdate() async {
    final controller = ref.read(appUpdateControllerProvider.notifier);
    if (!await controller.shouldShowOptionalDialog()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final storeUrl = ref.read(appUpdateControllerProvider).info.storeUrl;
    await KaziNavigator.showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OptionalUpdateDialog(storeUrl: storeUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(kaziEffectiveLocaleProvider);

    // Present the paywall whenever a creation flow hits a freemium limit. With
    // payments turned off no limit blocks anything, so the prompt is swallowed.
    ref.listen(paywallPromptControllerProvider, (previous, next) {
      if (next == null) return;
      ref.read(paywallPromptControllerProvider.notifier).dismiss();
      if (!ref.read(isPaymentsEnabledProvider)) return;
      showPaywall(context, limit: next);
    });

    return Scaffold(
      body: widget.navigationShell,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _ShellFab(
        tabIndex: widget.navigationShell.currentIndex,
      ),
      floatingActionButtonLocation: const KaziNavBarFabLocation(),
      bottomNavigationBar: KaziNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelected: _onTapTab,
        items: [
          KaziNavBarItem(
            icon: Icons.home_outlined,
            label: KaziLocalizations.current.home,
          ),
          KaziNavBarItem(
            icon: Icons.format_list_bulleted,
            label: KaziLocalizations.current.services,
          ),
          KaziNavBarItem(
            icon: Icons.person_outline,
            label: KaziLocalizations.current.clients,
          ),
          KaziNavBarItem(
            icon: Icons.tune,
            label: KaziLocalizations.current.menu,
          ),
        ],
      ),
    );
  }

  void _onTapTab(int index) {
    // `initialLocation` only when the tab is already active, which turns a
    // re-tap into "back to the root of this tab" rather than a no-op.
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class _ShellFab extends StatelessWidget {
  const _ShellFab({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final onAccent = context.colors.brand.onFill;

    final (AppPage destination, Widget child) = switch (tabIndex) {
      _Tab.clients => (AppPage.addClient, Icon(Icons.add, color: onAccent)),
      _ => (
        AppPage.addServices,
        KaziSvg(KaziSvgAssets.logo, height: 24, color: onAccent),
      ),
    };

    return HintAnchor(
      hint: OnboardingHint.fab,
      enabled: tabIndex == _Tab.home,
      // The app's main entry point into creating anything, and the button
      // people press again when a slow route makes it look ignored.
      child: TapProbe(
        target: 'shell_fab',
        child: KaziNavBarFab(
          onTap: () => KaziNavigator.push(destination),
          child: child,
        ),
      ),
    );
  }
}
