import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

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
    // Present the paywall whenever a creation flow hits a freemium limit. With
    // payments turned off no limit blocks anything, so the prompt is swallowed.
    ref.listen(paywallPromptControllerProvider, (previous, next) {
      if (next == null) return;
      ref.read(paywallPromptControllerProvider.notifier).dismiss();
      if (!ref.read(isPaymentsEnabledProvider)) return;
      showPaywall(context, limit: next);
    });

    return Scaffold(
      appBar: AppBar(
        foregroundColor: context.colorsScheme.onSurface,
        backgroundColor: context.colorsScheme.primary,
        leadingWidth: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: KaziInsets.lg),
          child: KaziSvg(KaziSvgAssets.logoExtended),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: KaziInsets.sm),
            child: KaziCircularButton(
              onTap: onSignOut,
              backgroundColor: context.kaziColors.accentSurface,
              foregroundColor: context.kaziColors.onAccentSurface,
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: widget.child,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: KaziInsets.lg,
          right: KaziInsets.lg,
          bottom: context.bottomPadding,
        ),
        child: KaziBottomAppBar(
          gap: 8,
          iconSize: 26,
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.lg,
            vertical: KaziInsets.sm,
          ),
          // accentInk rather than the brand yellow: a yellow label on Névoa is
          // 1.4:1. accentInk flips to the yellow itself on dark.
          color: context.colorsScheme.onSurfaceVariant,
          activeColor: context.kaziColors.accentInk,
          tabActiveBorder: Border.all(color: context.kaziColors.accentInk),
          tabBackgroundColor: context.kaziColors.accentSubtle,
          tabs: [
            KaziBottomAppButton(
              icon: KaziIcons.home,
              text: KaziLocalizations.current.home,
              onPressed: () => _onTapBottomItem(0, context),
            ),
            KaziBottomAppButton(
              icon: Icons.home_repair_service,
              text: KaziLocalizations.current.services,
              onPressed: () => _onTapBottomItem(1, context),
            ),
            KaziBottomAppButton(
              icon: Icons.settings,
              text: KaziLocalizations.current.settings,
              onPressed: () => _onTapBottomItem(2, context),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapBottomItem(int index, BuildContext context) {
    final page = AppPage.fromIndex(index);
    KaziNavigator.navigate(page);
  }

  Future<void> onSignOut() async {
    KaziNavigator.showDialog(
      context: context,
      builder: (_) => KaziDialog(
        onConfirm: () async {
          final authService = ref.read(authServiceProvider);
          final routerController = ref.read(routerControllerProvider.notifier);
          final storageFuture = ref.read(localStorageProvider.future);

          context.pop();

          await authService.signOut();
          await (await storageFuture).clear();
          await routerController.resetOnboarding();
        },
        onCancel: context.pop,
        title: KaziLocalizations.current.signOut,
        message: KaziLocalizations.current.signOutConfirmation,
      ),
    );
  }
}
