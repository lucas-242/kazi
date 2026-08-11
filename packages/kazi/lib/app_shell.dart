import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

/// Tab indices, mirroring the branch order in `AppRouter.buildRoutes`.
abstract final class _Tab {
  static const home = 0;
  static const services = 1;
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
      _maybeShowOptionalUpdate();
    });
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: KaziNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelected: _onTapTab,
        items: [
          KaziNavBarItem(
            icon: KaziIcons.home,
            label: KaziLocalizations.current.home,
          ),
          KaziNavBarItem(
            icon: Icons.receipt_long_outlined,
            label: KaziLocalizations.current.services,
          ),
          KaziNavBarItem(
            icon: Icons.person_outline,
            label: KaziLocalizations.current.clients,
          ),
          KaziNavBarItem(
            icon: Icons.menu,
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

    final (AppPage, Widget)? action = switch (tabIndex) {
      _Tab.home || _Tab.services => (
        AppPage.addServices,
        KaziSvg(KaziSvgAssets.logo, height: 24, color: onAccent),
      ),
      _Tab.clients => (AppPage.addClient, Icon(Icons.add, color: onAccent)),
      // The menu: configuration is not creation.
      _ => null,
    };

    if (action == null) {
      // Zero-sized rather than absent: the bar reserves its central gap either
      // way, so collapsing here keeps the menu free of the button without the
      // Scaffold animating one in and out on every tab change.
      return const SizedBox.shrink();
    }

    final (destination, child) = action;

    return SizedBox.square(
      dimension: KaziSizings.navBarFabSize,
      child: FloatingActionButton(
        onPressed: () => KaziNavigator.push(destination),
        backgroundColor: context.colors.brand.fill,
        foregroundColor: onAccent,
        child: child,
      ),
    );
  }
}
