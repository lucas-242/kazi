import 'dart:ui';

/// Codec for the `AARRGGBB` colour strings persisted alongside user data.
///
/// Colours are stored as text rather than as an index into the palette so that
/// reordering the palette never repaints data that was already saved.
abstract class KaziHexColor {
  /// Encodes [color] as an uppercase 8-digit `AARRGGBB` string.
  static String encode(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

  /// Decodes an `AARRGGBB` string, returning null for anything else.
  ///
  /// Both "not informed" (empty) and a corrupt/tampered value resolve to null,
  /// so callers only ever deal with a valid colour or none at all.
  static Color? tryParse(String? hex) {
    if (hex == null || hex.length != 8) {
      return null;
    }
    final int? argb = int.tryParse(hex, radix: 16);
    if (argb == null) {
      return null;
    }
    return Color(argb);
  }
}
