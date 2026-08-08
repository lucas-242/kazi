import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

/// Pins the parts of the design system that would otherwise regress
/// silently: the dark scheme nobody looks at yet, the colourless-static /
/// coloured-theme contract that makes dark mode work at all, the 4pt grid,
/// and the bundled font resolution.
void main() {
  test('both themes build and carry the brand roles', () {
    final light = KaziThemeSettings.light();
    final dark = KaziThemeSettings.dark();

    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.scaffoldBackgroundColor, const Color(0xFFF4F2ED));
    expect(dark.scaffoldBackgroundColor, const Color(0xFF14120D));
    expect(light.colorScheme.surfaceTint, light.colorScheme.surface);
    expect(dark.colorScheme.surfaceTint, dark.colorScheme.surface);
    expect(light.dividerColor, const Color(0xFFD8D4C8));
    expect(dark.dividerColor, const Color(0xFF35322A));

    final lightRoles = light.extension<KaziColorRoles>()!;
    final darkRoles = dark.extension<KaziColorRoles>()!;
    expect(lightRoles.accentInk, const Color(0xFFA87400)); // ambar
    expect(darkRoles.accentInk, const Color(0xFFFFCC31)); // kazi yellow
    expect(lightRoles.category(7), lightRoles.category(1)); // wraps

    // light()/dark() must be cached, not rebuilt per call
    expect(identical(KaziThemeSettings.light(), light), isTrue);

    // lerp must not throw and must land on the endpoints
    expect(lightRoles.lerp(darkRoles, 1).accentInk, darkRoles.accentInk);
    expect(lightRoles.lerp(darkRoles, 0).accentInk, lightRoles.accentInk);
  });

  test('static styles are colourless and resolve the bundled families', () {
    expect(KaziTextStyles.titleMd.color, isNull);
    expect(KaziTextStyles.md.color, isNull);
    expect(KaziTextStyles.labelSm.color, isNull);
    expect(KaziTextStyles.tag.color, isNull);

    // package: must be folded into the resolved family name.
    expect(KaziTextStyles.titleMd.fontFamily, 'packages/kazi_core/Archivo');
    expect(KaziTextStyles.md.fontFamily, 'packages/kazi_core/IBM Plex Sans');
    expect(KaziTextStyles.tag.fontFamily, 'packages/kazi_core/IBM Plex Mono');

    // Sizes that must not have drifted (heaviest-used getters).
    expect(KaziTextStyles.titleMd.fontSize, 20);
    expect(KaziTextStyles.titleSm.fontSize, 16);
    expect(KaziTextStyles.labelMd.fontSize, 14);
    expect(KaziTextStyles.labelSm.fontSize, 12);

    expect(KaziTextStyles.money.fontFeatures, isNotNull);
    expect(KaziTextStyles.moneyAt(20).letterSpacing, closeTo(-0.8, 0.001));

    // The theme copy must be coloured, or ThemeData renders black in dark.
    final darkText = KaziTextStyles.themed(KaziColorSchemes.dark);
    expect(darkText.bodyMedium!.color, const Color(0xFFF4F2ED)); // nevoa
    expect(darkText.labelSmall!.color, const Color(0xFFA8A498)); // grafite300
  });

  testWidgets('a colourless style inherits its colour from the theme',
      (tester) async {
    Color colourOf(WidgetTester t, String data) =>
        (t.firstWidget(find.text(data)) as Text).style?.color ??
        DefaultTextStyle.of(t.element(find.text(data))).style.color!;

    for (final (mode, expected) in <(ThemeMode, Color)>[
      (ThemeMode.light, const Color(0xFF14120D)), // grafite
      (ThemeMode.dark, const Color(0xFFF4F2ED)), // nevoa
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: KaziThemeSettings.light(),
          darkTheme: KaziThemeSettings.dark(),
          themeMode: mode,
          home: const Scaffold(
            body: Text('valor', style: KaziTextStyles.titleMd),
          ),
        ),
      );
      // MaterialApp animates theme changes, so the first frame after a
      // themeMode switch is still interpolating from the previous theme.
      await tester.pumpAndSettle();
      expect(colourOf(tester, 'valor'), expected, reason: '$mode');
    }
  });

  test('insets sit on a 4pt grid and radii follow the brandbook', () {
    const scale = <double>[
      KaziInsets.zero,
      KaziInsets.xxs,
      KaziInsets.xs,
      KaziInsets.sm,
      KaziInsets.md,
      KaziInsets.lg,
      KaziInsets.xLg,
      KaziInsets.xxLg,
      KaziInsets.xxxLg,
      KaziInsets.xxxxLg,
    ];
    expect(scale, <double>[0, 4, 8, 12, 16, 24, 32, 40, 48, 64]);
    for (final step in scale) {
      expect(step % 4, 0, reason: '$step is off the 4pt grid');
    }

    // KaziSpacings derives from KaziInsets, so it must have moved with it.
    expect(KaziSpacings.verticalLg.height, KaziInsets.lg);
    expect(KaziSpacings.horizontalXxxLg.width, KaziInsets.xxxLg);

    expect(KaziRadii.md, 14); // --radius-card
    for (final r in <double>[KaziRadii.sm, KaziRadii.md, KaziRadii.lg]) {
      expect(r, inInclusiveRange(12, 16), reason: 'outside brandbook range');
    }

    final card = KaziThemeSettings.light().cardTheme.shape!;
    expect(
      (card as RoundedRectangleBorder).borderRadius,
      KaziRadii.mdBorder,
    );
  });

  testWidgets('context.kaziColors falls back outside a Kazi theme',
      (tester) async {
    late KaziColorRoles roles;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            roles = context.kaziColors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(roles, KaziColorRoles.light);
  });
}
