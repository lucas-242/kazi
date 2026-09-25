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

  /// Under every slot in the type scale: at `labelSmall`'s own size four
  /// destinations do not fit a phone's width.
  static const _labelSize = 10.0;
  static const _labelLineHeight = 1.1;

  /// Between a destination's icon and its label. Tighter than any [KaziInsets]
  /// step, which start at 4 — the two read as one mark, not as two things.
  static const _iconGap = 3.0;

  /// A destination's own ink, plus [KaziInsets.xs] above and below it.
  ///
  /// Derived from the text scale rather than fixed: the bar is the one strip
  /// of the app a user cannot scroll, so a label that grows has to be given
  /// the room instead of being clipped. [KaziSizings.navBarMinHeight] is the
  /// floor, so a destination is never shorter than a touch target.
  static double _heightFor(BuildContext context) {
    final label =
        MediaQuery.textScalerOf(context).scale(_labelSize) * _labelLineHeight;
    final ink = KaziSizings.navBarIcon + _iconGap + label;

    return math.max(
      KaziSizings.navBarMinHeight,
      ink + KaziInsets.xs * 2,
    );
  }

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
      // A hole, not a drawn ring: the cut is the button inflated by this, so
      // the gap shows whatever sits behind the bar. See README.md.
      notchMargin: KaziInsets.xs,
      padding: EdgeInsets.zero,
      // Just the bar: BottomAppBar sizes its child to this and wraps that in
      // a SafeArea of its own, so adding the inset here makes the bar a whole
      // inset taller than the destinations it holds.
      height: _heightFor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
      child: InkWell(
        onTap: onTap,
        // No ink on touch: a strip this short has no ripple that reads as
        // deliberate. The destination it opens is the feedback. Focus and
        // hover keep their own, which touch never raises. See README.md.
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
            minWidth: KaziSizings.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: KaziSizings.navBarIcon,
                  color: color,
                ),
                const SizedBox(height: KaziNavBar._iconGap),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: KaziTextStyles.labelSmall.copyWith(
                    fontSize: KaziNavBar._labelSize,
                    height: KaziNavBar._labelLineHeight,
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
