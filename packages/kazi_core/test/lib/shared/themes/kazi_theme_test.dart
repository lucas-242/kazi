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

    final lightColors = light.extension<KaziColors>()!;
    final darkColors = dark.extension<KaziColors>()!;
    expect(lightColors.brand.text, const Color(0xFFA87400)); // amber
    expect(darkColors.brand.text, const Color(0xFFFFCC31)); // kazi yellow
    expect(lightColors.category(19), lightColors.category(1)); // wraps

    // light()/dark() must be cached, not rebuilt per call
    expect(identical(KaziThemeSettings.light(), light), isTrue);

    // lerp must not throw and must land on the endpoints
    expect(lightColors.lerp(darkColors, 1).brand.text, darkColors.brand.text);
    expect(lightColors.lerp(darkColors, 0).brand.text, lightColors.brand.text);
    expect(lightColors.lerp(darkColors, 1).hero.mark, darkColors.hero.mark);
  });

  test('every group resolves in both brightnesses', () {
    // The whole point of the refactor: one accessor answers every question, so
    // no screen has to branch on brightness. If a group ever went missing from
    // one side, this is where it shows up.
    for (final (label, colors) in <(String, KaziColors)>[
      ('light', KaziColors.light),
      ('dark', KaziColors.dark),
    ]) {
      final reason = 'in $label';
      for (final status in <KaziStatusColors>[
        colors.success,
        colors.warning,
        colors.info,
        colors.danger,
      ]) {
        expect(status.fill, isNotNull, reason: reason);
        expect(status.onFill, isNotNull, reason: reason);
        expect(status.surface, isNotNull, reason: reason);
        expect(status.onSurface, isNotNull, reason: reason);
      }
      expect(colors.categories, hasLength(18), reason: reason);
      expect(colors.brightness, colors.scheme.brightness, reason: reason);
      // The forwarding getters must track the scheme, not a stale copy.
      expect(colors.background, colors.scheme.surface, reason: reason);
      expect(colors.textMuted, colors.scheme.onSurfaceVariant, reason: reason);
      expect(colors.border, colors.scheme.outlineVariant, reason: reason);
    }

    // The hero canvas has to flip, or the splash reads one theme in the other.
    expect(KaziColors.light.hero.surface, const Color(0xFFFFCC31)); // yellow
    expect(KaziColors.dark.hero.surface, const Color(0xFF14120D)); // graphite
    expect(KaziColors.light.hero.mark, KaziColors.light.hero.ink);
    expect(KaziColors.dark.hero.mark, isNot(KaziColors.dark.hero.ink));
  });

  testWidgets('overlayOn derives icon brightness from the surface',
      (tester) async {
    late KaziColors colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // Dark ground → light icons, whatever the ambient theme is. This is what
    // replaced the hand-written `isDark ? ... : ...` on the splash.
    final onGraphite = colors.overlayOn(colors.money.surface);
    expect(onGraphite.statusBarIconBrightness, Brightness.light);
    final onMist = colors.overlayOn(colors.background);
    expect(onMist.statusBarIconBrightness, Brightness.dark);
  });

  test('static styles are colourless and resolve the bundled families', () {
    expect(KaziTextStyles.titleMedium.color, isNull);
    expect(KaziTextStyles.bodyMedium.color, isNull);
    expect(KaziTextStyles.labelSmall.color, isNull);
    expect(KaziTextStyles.tag.color, isNull);

    // package: must be folded into the resolved family name.
    expect(KaziTextStyles.titleMedium.fontFamily, 'packages/kazi_core/Archivo');
    expect(KaziTextStyles.bodyMedium.fontFamily, 'packages/kazi_core/IBM Plex Sans');
    expect(KaziTextStyles.tag.fontFamily, 'packages/kazi_core/IBM Plex Mono');

    // Sizes that must not have drifted (heaviest-used getters).
    expect(KaziTextStyles.titleMedium.fontSize, 20);
    expect(KaziTextStyles.titleSmall.fontSize, 16);
    expect(KaziTextStyles.labelMedium.fontSize, 14);
    expect(KaziTextStyles.labelSmall.fontSize, 12);

    expect(KaziTextStyles.amount.fontFeatures, isNotNull);
    expect(KaziTextStyles.amountAt(20).letterSpacing, closeTo(-0.8, 0.001));

    // The theme copy must be coloured, or ThemeData renders black in dark.
    final darkText = KaziTextStyles.themed(KaziColors.dark.scheme);
    expect(darkText.bodyMedium!.color, const Color(0xFFF4F2ED)); // mist
    expect(darkText.labelSmall!.color, const Color(0xFFA8A498)); // graphite300
  });

  testWidgets('a colourless style inherits its colour from the theme',
      (tester) async {
    Color colourOf(WidgetTester t, String data) =>
        (t.firstWidget(find.text(data)) as Text).style?.color ??
        DefaultTextStyle.of(t.element(find.text(data))).style.color!;

    for (final (mode, expected) in <(ThemeMode, Color)>[
      (ThemeMode.light, const Color(0xFF14120D)), // graphite
      (ThemeMode.dark, const Color(0xFFF4F2ED)), // mist
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: KaziThemeSettings.light(),
          darkTheme: KaziThemeSettings.dark(),
          themeMode: mode,
          home: const Scaffold(
            body: Text('valor', style: KaziTextStyles.titleMedium),
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

  testWidgets('context.colors falls back outside a Kazi theme',
      (tester) async {
    late KaziColors colors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(colors, KaziColors.light);
  });
}
