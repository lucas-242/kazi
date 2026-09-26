import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The button in the central slot of a `KaziNavBar`.
///
/// The bar is notched around this slot rather than carrying a ring drawn on
/// top of the button, so the button reads as sitting in a real cut in the bar.
///
/// Dock it with [KaziNavBarFabLocation] — a thin wrapper over `centerDocked`,
/// which is what the notch geometry is computed against.
class KaziNavBarFab extends StatelessWidget {
  const KaziNavBarFab({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;

  /// The mark or icon on the yellow. Sized by the caller, since the action —
  /// not the bar — decides what is drawn.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: KaziSizings.navBarFabSize,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: colors.brand.fill,
        foregroundColor: colors.brand.onFill,
        shape: const CircleBorder(),
        child: child,
      ),
    );
  }
}

/// Docks the button centred on the bar's top edge, straddling the notch cut
/// into it — the same position `centerDocked` computes the notch against, so
/// the two stay in sync.
class KaziNavBarFabLocation extends FloatingActionButtonLocation {
  const KaziNavBarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return FloatingActionButtonLocation.centerDocked.getOffset(
      scaffoldGeometry,
    );
  }
}
