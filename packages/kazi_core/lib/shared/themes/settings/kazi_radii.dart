import 'package:flutter/widgets.dart';

/// Corner radii, kept separate from [KaziInsets] so a spacing change can never
/// silently reshape a card.
///
/// The brandbook puts corners in the 12–16px range and fixes cards at 14px
/// (`--radius-card`). [full] is outside that range on purpose: a pill or a
/// circle is a different decision, not a very large corner.
abstract class KaziRadii {
  ///8.0px — inputs and small chips.
  static const xs = 8.0;

  ///12.0px — the lower bound of the brandbook range.
  static const sm = 12.0;

  ///14.0px — `--radius-card`. The default for cards and panels.
  static const md = 14.0;

  ///16.0px — the upper bound of the brandbook range.
  static const lg = 16.0;

  ///24.0px — bottom sheets and other large sheet-like surfaces.
  static const xl = 24.0;

  ///Pill or circle. FABs, pill buttons, avatars.
  static const full = 999.0;

  static const xsBorder = BorderRadius.all(Radius.circular(xs));
  static const smBorder = BorderRadius.all(Radius.circular(sm));
  static const mdBorder = BorderRadius.all(Radius.circular(md));
  static const lgBorder = BorderRadius.all(Radius.circular(lg));
  static const xlBorder = BorderRadius.all(Radius.circular(xl));
  static const fullBorder = BorderRadius.all(Radius.circular(full));

  /// Top-only [xl], for bottom sheets.
  static const xlTopBorder = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}
