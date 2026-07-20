import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/custom_bottom_navigation/custom_bottom_navigation.dart';
import 'package:kazi/features/app_update/app_update.dart';
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
    final user = ref.watch(authServiceProvider).user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: context.colorsScheme.onSurface,
        backgroundColor: context.colorsScheme.primary,
        title: Row(
          children: [
            KaziSpacings.horizontalXs,
            TextButton(
              onPressed: () => KaziNavigator.navigate(AppPage.profile),
              child: SizedBox(
                width: 48.0,
                height: 48.0,
                child: CircleAvatar(
                  backgroundImage: user?.thereIsPhoto ?? false
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  backgroundColor: KaziColors.white,
                  child: user == null || !user.thereIsPhoto
                      ? Text(
                          '🦆',
                          style: KaziTextStyles.titleMd.copyWith(
                            color: context.colorsScheme.surface,
                            fontWeight: FontWeight.w500,
                            fontSize: 38,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            KaziSpacings.horizontalXs,
            Text(
              user?.shortName ?? '',
              style: KaziTextStyles.titleMd.copyWith(
                color: context.colorsScheme.onSurface,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: KaziSvg(KaziSvgAssets.logo),
          ),
        ],
      ),
      body: widget.child,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CustomBottomNavigation(
        currentPage: KaziNavigator.currentPage?.pageIndex ?? 0,
        onTap: (index) => _onTapBottomItem(index, context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            onPressed: _onTapFloatingActionButton,
            tooltip: KaziLocalizations.current.newService,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _onTapFloatingActionButton() => KaziNavigator.push(AppPage.addServices);

  void _onTapBottomItem(int index, BuildContext context) {
    final page = AppPage.fromIndex(index);
    KaziNavigator.navigate(page);
  }
}
