import 'package:flutter/material.dart';
import 'package:kazi/app/shared/constants/app_assets.dart';
import 'package:kazi/app/shared/widgets/custom_bottom_navigation/widgets/bottom_navigation_button.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    this.currentPage = 0,
    required this.onTap,
  });
  final int currentPage;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          BottomNavigationButton(
            onTap: () => onTap(0),
            icon: AppAssets.home,
            label: 'Home',
            isSelected: currentPage == 0,
          ),
          BottomNavigationButton(
            onTap: () => onTap(1),
            icon: AppAssets.services,
            label: KaziLocalizations.current.services.capitalize(),
            isSelected: currentPage == 1,
          ),
        ],
      ),
    );
  }
}
