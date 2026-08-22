import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The button in the central slot of a `KaziNavBar`.
///
/// The ring is the page ground, not the bar's — it is what stops the yellow
/// from bleeding into the strip it floats over, and it is why the button reads
/// as sitting above the bar rather than inside it.
///
/// Dock it with [KaziNavBarFabLocation]: it carries the other half of the
/// anatomy, and a bare `centerDocked` puts the button too high.
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
        // Painted inside the 54 dp footprint, so the yellow disc is 46 dp and
        // the shadow still follows the full circle.
        shape: CircleBorder(
          side: BorderSide(
            color: colors.background,
            width: KaziSizings.navBarFabRing,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Docks the central button [KaziSizings.navBarFabSink] below the standard
/// docked position: it overlaps the bar, clearing its top edge by 12 dp,
/// instead of being cut in half by it.
class KaziNavBarFabLocation extends FloatingActionButtonLocation {
  const KaziNavBarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final docked = FloatingActionButtonLocation.centerDocked.getOffset(
      scaffoldGeometry,
    );

    return Offset(docked.dx, docked.dy + KaziSizings.navBarFabSink);
  }
}
