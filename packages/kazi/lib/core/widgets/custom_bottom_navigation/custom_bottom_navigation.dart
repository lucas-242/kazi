import 'package:flutter/material.dart';
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
          _BottomNavigationButton(
            onTap: () => onTap(0),
            icon: KaziSvgAssets.home,
            label: 'Home',
            isSelected: currentPage == 0,
          ),
          _BottomNavigationButton(
            onTap: () => onTap(1),
            icon: KaziSvgAssets.services,
            label: KaziLocalizations.current.services.capitalize(),
            isSelected: currentPage == 1,
          ),
          _BottomNavigationButton(
            onTap: () => onTap(2),
            icon: KaziSvgAssets.person,
            label: KaziLocalizations.current.settings.capitalize(),
            isSelected: currentPage == 2,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationButton extends StatelessWidget {
  const _BottomNavigationButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final VoidCallback onTap;
  final String icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colorsScheme.primary
        : context.colorsScheme.onPrimaryContainer;

    final fontWeight = isSelected ? FontWeight.w500 : FontWeight.w400;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KaziSvg(icon, color: color),
            KaziSpacings.verticalXxs,
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
