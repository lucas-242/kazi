import 'dart:math' as math;

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
/// attention in the same 62 dp strip is exactly what the brandbook rules out.
/// The active destination is marked by ink weight plus a stroke skewed to the
/// angle of the logo's bolt.
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

  /// The angle of the bolt in the logo, in radians.
  static const _markSkew = -31 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorsScheme;
    // Split after the second destination so the gap lands dead centre. With an
    // odd count the extra destination goes to the left half.
    final splitAt = (items.length / 2).ceil();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
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
    final colors = context.colorsScheme;
    final color = isActive ? colors.onSurface : colors.onSurfaceVariant;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: KaziSizings.navBarIcon, color: color),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: KaziTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
              const SizedBox(height: 1),
              _ActiveMark(isVisible: isActive, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 3 dp stroke under the active destination, skewed to the bolt's angle.
///
/// Always laid out, so the row does not shift by 3 dp as the selection moves.
class _ActiveMark extends StatelessWidget {
  const _ActiveMark({required this.isVisible, required this.color});

  final bool isVisible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(KaziNavBar._markSkew),
      alignment: Alignment.center,
      child: SizedBox(
        width: 14,
        height: 3,
        child: isVisible ? ColoredBox(color: color) : null,
      ),
    );
  }
}
