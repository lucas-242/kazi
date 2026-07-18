import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/custom_app_bar.dart';
import 'package:kazi/core/widgets/custom_bottom_navigation/custom_bottom_navigation.dart';
import 'package:kazi_core/kazi_core.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: child,
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
