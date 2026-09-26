/// The Kazi spacing scale, on a strict 4pt grid.
///
/// `0 · 4 · 8 · 12 · 16 · 24 · 32 · 40 · 48 · 64`
///
/// 20, 28 and 50 used to sit in this scale and broke the rhythm; they are
/// gone. The t-shirt names are unchanged, so call sites did not move — but
/// [lg], [xLg] and [xxxLg] now resolve to different numbers than before.
///
/// Use [KaziRadii] for corner radii. A spacing token driving a corner is a
/// category error, and it is why the card radius used to track this scale.
abstract class KaziInsets {
  ///0.0px
  static const zero = 0.0;

  ///4.0px
  static const xxs = 4.0;

  ///8.0px
  static const xs = 8.0;

  ///12.0px
  static const sm = 12.0;

  ///16.0px
  static const md = 16.0;

  ///24.0px
  static const lg = 24.0;

  ///32.0px
  static const xLg = 32.0;

  ///40.0px
  static const xxLg = 40.0;

  ///48.0px
  static const xxxLg = 48.0;

  ///64.0px
  static const xxxxLg = 64.0;
}
