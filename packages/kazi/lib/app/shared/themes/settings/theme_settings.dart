import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kazi_core/kazi_core.dart';

abstract class ThemeSettings {
  static const pageTransitionsTheme = KaziThemeSettings.pageTransitionsTheme;

  static ShapeBorder get defaultShape => KaziThemeSettings.defaultShape;

  static ThemeData light() {
    final colors = _getColorScheme(Brightness.light);

    return ThemeData.light().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colors,
      appBarTheme: _appBarTheme(colors),
      cardTheme: _cardTheme(),
      listTileTheme: _listTileTheme(colors),
      bottomAppBarTheme: _bottomAppBarTheme(colors),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colors),
      bottomSheetTheme: _bottomSheetTheme(colors),
      floatingActionButtonTheme: _floatingActionButtonTheme(colors),
      dividerTheme: _dividerTheme(colors),
      navigationRailTheme: _navigationRailTheme(colors),
      tabBarTheme: _tabBarTheme(colors),
      drawerTheme: _drawerTheme(colors),
      inputDecorationTheme: _inputDecorationTheme(colors),
      textTheme: _textTheme(colors),
      dialogTheme: _dialogTheme(),
      iconTheme: _iconTheme(),
      scaffoldBackgroundColor: colors.surface,
    );
  }

  static ThemeData dark() {
    final colors = _getColorScheme(Brightness.dark);

    return ThemeData.dark().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colors,
      appBarTheme: _appBarTheme(colors),
      cardTheme: _cardTheme(),
      listTileTheme: _listTileTheme(colors),
      bottomAppBarTheme: _bottomAppBarTheme(colors),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colors),
      bottomSheetTheme: _bottomSheetTheme(colors),
      floatingActionButtonTheme: _floatingActionButtonTheme(colors),
      dividerTheme: _dividerTheme(colors),
      navigationRailTheme: _navigationRailTheme(colors),
      tabBarTheme: _tabBarTheme(colors),
      drawerTheme: _drawerTheme(colors),
      inputDecorationTheme: _inputDecorationTheme(colors),
      textTheme: _textTheme(colors),
      dialogTheme: _dialogTheme(),
      iconTheme: _iconTheme(),
      scaffoldBackgroundColor: colors.surface,
    );
  }

  static ColorScheme _getColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: KaziColors.primary,
      primary: KaziColors.primary,
      surface: KaziColors.background,
      onSurface: KaziColors.black,
      error: KaziColors.red,
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 0,
      color: KaziColors.white,
      surfaceTintColor: KaziColors.white,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ListTileThemeData _listTileTheme(ColorScheme colors) {
    return ListTileThemeData(
      shape: defaultShape,
      selectedColor: colors.secondary,
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: colors.primary,
      surfaceTintColor: colors.primary,
      // foregroundColor: colors.onSurface,
    );
  }

  static TabBarThemeData _tabBarTheme(ColorScheme colors) {
    return TabBarThemeData(
      labelColor: colors.secondary,
      unselectedLabelColor: colors.onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.secondary, width: 2)),
      ),
    );
  }

  static BottomAppBarThemeData _bottomAppBarTheme(ColorScheme colors) {
    return BottomAppBarThemeData(
      color: colors.surface,
      elevation: 0,
      height: 75,
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme(
    ColorScheme colors,
  ) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onPrimaryContainer,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(ColorScheme colors) {
    return BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme(
    ColorScheme colors,
  ) {
    return FloatingActionButtonThemeData(
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: colors.primary,
      foregroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    );
  }

  static DividerThemeData _dividerTheme(ColorScheme colors) {
    return const DividerThemeData(
      color: KaziColors.lightGrey,
      indent: 0,
      endIndent: 0,
      space: 0,
    );
  }

  static NavigationRailThemeData _navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  static DrawerThemeData _drawerTheme(ColorScheme colors) {
    return DrawerThemeData(backgroundColor: colors.surface);
  }

  static DialogThemeData _dialogTheme() => DialogThemeData(
    backgroundColor: KaziColors.white,
    surfaceTintColor: KaziColors.white,
    elevation: 3,
    shadowColor: KaziColors.black.withValues(alpha: 0.5),
  );

  static IconThemeData _iconTheme() =>
      const IconThemeData(size: 24, color: KaziColors.black);

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colors) {
    const borderRadius = BorderRadius.all(Radius.circular(6.0));
    return InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.onSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.onSurface),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        borderSide: BorderSide(color: colors.onSurface),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.onSurface),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(),
      displayMedium: GoogleFonts.outfit(),
      displaySmall: GoogleFonts.outfit(),
      headlineLarge: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 32,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 24,
      ),
      headlineSmall: GoogleFonts.outfit(
        color: KaziColors.grey,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      titleLarge: GoogleFonts.outfit(),
      titleMedium: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      titleSmall: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      ),
      bodyMedium: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodySmall: GoogleFonts.outfit(
        color: colors.onSurface,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.outfit(
        color: KaziColors.grey,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.outfit(
        color: KaziColors.grey,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.outfit(
        color: KaziColors.grey,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    );
  }
}
