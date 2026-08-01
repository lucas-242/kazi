import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/custom_bottom_navigation/custom_bottom_navigation.dart';
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
    // Present the paywall whenever a creation flow hits a freemium limit.
    ref.listen(paywallPromptControllerProvider, (previous, next) {
      if (next == null) return;
      ref.read(paywallPromptControllerProvider.notifier).dismiss();
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
              backgroundColor: KaziColors.primary,
              foregroundColor: KaziColors.black,
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: widget.child,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CustomBottomNavigation(
        currentPage: KaziNavigator.currentPage?.pageIndex ?? 0,
        onTap: (index) => _onTapBottomItem(index, context),
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
          await ref.read(authServiceProvider).signOut();
          await ref
              .read(localStorageProvider.future)
              .then((value) => value.clear());
        },
        onCancel: context.pop,
        title: KaziLocalizations.current.signOut,
        message: KaziLocalizations.current.signOutConfirmation,
      ),
    );
  }
}
