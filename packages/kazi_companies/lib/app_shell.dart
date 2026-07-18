import 'package:flutter/material.dart';
import 'package:kazi_companies/app_controller.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/domain/models/menu.dart';
import 'package:kazi_core/kazi_core.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final List<Menu> menus = [
    Menu(
      KaziLocalizations.current.services,
      KaziSvgAssets.services,
      AppPages.home,
    ),
    Menu(
      KaziLocalizations.current.clients,
      KaziSvgAssets.person,
      AppPages.clients,
    ),
    Menu(
      KaziLocalizations.current.employees,
      KaziSvgAssets.calculator,
      AppPages.employees,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(appControllerProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: KaziPaddingWrap(
          paddingTop: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: KaziInsets.sm,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: KaziColors.primary,
                      borderRadius: BorderRadius.circular(KaziInsets.xxs),
                    ),
                    child: const KaziSvg(KaziSvgAssets.logo),
                  ),
                  const Text('Kazi'),
                ],
              ),
              const Spacer(),
              Row(
                children: menus
                    .map(
                      (m) => KaziTextButton(
                        onTap: () => context.navigate(m.page.route),
                        color: currentPage == m.page
                            ? KaziColors.primary
                            : KaziColors.grey,
                        child: Text(m.name),
                      ),
                    )
                    .toList(),
              ),
              const Spacer(),
              Row(
                spacing: KaziInsets.md,
                children: [
                  if (currentPage == AppPages.clients)
                    KaziElevatedButton.icon(
                      onTap: () => context.navigate(Routes.newClient),
                      icon: const Icon(Icons.add),
                      label: KaziLocalizations.current.newClient,
                    ),
                  const CircleAvatar(
                    radius: 24,
                    child: KaziSvg(KaziSvgAssets.person),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => context.showLeaveBottomSheet().then(
          (_) {
            if (context.mounted) KaziNavigator.pop();
          },
        ),
        child: widget.child,
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
