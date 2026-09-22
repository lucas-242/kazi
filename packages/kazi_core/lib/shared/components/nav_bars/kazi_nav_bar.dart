import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/nav_bars/kazi_nav_bar_item.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The app's bottom navigation: four destinations around a central slot.
///
/// Stateless on purpose — [selectedIndex] is always supplied by the caller,
/// which is what keeps the highlight honest on deep links, `pop` and
/// programmatic navigation.
///
/// The brand yellow is deliberately absent: on this bar it belongs to the
/// floating button that sits in the central slot, and two things competing for
/// attention in the same strip is exactly what the brandbook rules out.
/// The bar itself is notched around that slot — a real cut in its top edge,
/// not a ring drawn on the button — so the button reads as sitting in the bar
/// rather than merely floating over it. The active destination is marked by
/// ink weight and a heavier icon.
class KaziNavBar extends StatelessWidget {
  const KaziNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.hasCenterSlot = true,
  });

  final List<KaziNavBarItem> items;

  /// Index into [items] of the destination currently being shown.
  final int selectedIndex;

  /// Fired for every tap, including one on the already-active destination —
  /// the caller decides what a re-tap means.
  final ValueChanged<int> onSelected;

  /// Leaves a gap between the second and third destination for a centre-docked
  /// button. With four destinations and no gap they simply split the width.
  final bool hasCenterSlot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Split after the second destination so the gap lands dead centre. With an
    // odd count the extra destination goes to the left half.
    final splitAt = (items.length / 2).ceil();

    return BottomAppBar(
      color: colors.card,
      elevation: 2,
      shadowColor: colors.scheme.shadow.withValues(alpha: 0.15),
      shape: hasCenterSlot ? const CircularNotchedRectangle() : null,
      notchMargin: 8,
      padding: EdgeInsets.zero,
      height: KaziSizings.navBarHeight + MediaQuery.paddingOf(context).bottom,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: KaziSizings.navBarHeight,
          child: Row(
            children: [
              for (final (index, item) in items.indexed) ...[
                if (hasCenterSlot && index == splitAt)
                  const SizedBox(width: KaziSizings.navBarCenterSlot),
                Expanded(
                  child: _NavBarDestination(
                    item: item,
                    isActive: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarDestination extends StatelessWidget {
  const _NavBarDestination({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final KaziNavBarItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isActive ? colors.text : colors.textMuted;

    return Semantics(
      button: true,
      selected: isActive,
      label: item.semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: KaziSizings.minTouchTarget,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
            minWidth: KaziSizings.minTouchTarget,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: KaziSizings.navBarIcon,
                  color: color,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: KaziTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
