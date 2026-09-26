import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The chevron that reveals the earnings breakdown, flipping upside down when
/// open rather than rotating sideways — the same convention as the onboarding
/// checklist's own disclosure arrow.
class ExpandToggle extends StatelessWidget {
  const ExpandToggle({super.key, required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: KaziLocalizations.current.details,
      child: InkWell(
        borderRadius: KaziRadii.fullBorder,
        onTap: onTap,
        child: SizedBox(
          width: KaziSizings.minTouchTarget,
          height: KaziSizings.minTouchTarget,
          child: Center(
            child: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                LucideIcons.chevronDown,
                size: KaziSizings.iconMd,
                color: context.colors.money.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
