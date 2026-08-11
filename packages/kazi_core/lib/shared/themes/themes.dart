export 'animations/no_animation_page_transition.dart';
export 'extensions/theme_extension.dart';
export 'gallery/kazi_theme_gallery_page.dart';
export 'kazi_colors.dart';
export 'kazi_theme_controller.dart';
export 'settings/kazi_breakpoints.dart';
export 'settings/kazi_icons.dart';
export 'settings/kazi_image_assets.dart';
export 'settings/kazi_insets.dart';
export 'settings/kazi_radii.dart';
export 'settings/kazi_sizings.dart';
export 'settings/kazi_spacings.dart';
export 'settings/kazi_svg_assets.dart';
export 'settings/kazi_text_styles.dart';
export 'settings/kazi_theme_settings.dart';
// `settings/kazi_palette.dart` is deliberately NOT exported. The raw hexes know
// nothing about light and dark, so a screen that reaches for them silently
// breaks one of the two themes. `KaziColors` (context.colors) is the only way
// in, and keeping the palette off the barrel is what makes that a compile
// error rather than a code-review note.
