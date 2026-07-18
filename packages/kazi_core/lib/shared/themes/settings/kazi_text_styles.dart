import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kazi_core/shared/themes/themes.dart';

abstract class KaziTextStyles {
  /// 32px, [KaziColors.darkGrey], [FontWeight.w700]
  static final headlineLg = textTheme.headlineLarge!;

  /// 24px, [KaziColors.darkGrey], [FontWeight.w700]
  static final headlineMd = textTheme.headlineMedium!;

  /// 18px, [KaziColors.darkGrey], [FontWeight.w700]
  static final headlineSm = textTheme.headlineSmall!;

  /// 24px, [KaziColors.darkGrey], [FontWeight.w500]
  static final titleLg = textTheme.titleLarge!;

  /// 20px, [KaziColors.darkGrey], [FontWeight.w500]
  static final titleMd = textTheme.titleMedium!;

  /// 16px, [KaziColors.darkGrey], [FontWeight.w500]
  static final titleSm = textTheme.titleSmall!;

  /// 18px, [KaziColors.darkGrey], [FontWeight.w400]
  static final lg = textTheme.bodyLarge!;

  /// 16px, [KaziColors.darkGrey], [FontWeight.w400]
  static final md = textTheme.bodyMedium!;

  /// 14px, [KaziColors.darkGrey], [FontWeight.w400]
  static final sm = textTheme.bodySmall!;

  /// 16px, [KaziColors.grey], [FontWeight.w400]
  static final labelLg = textTheme.labelLarge!;

  /// 14px, [KaziColors.grey], [FontWeight.w400]
  static final labelMd = textTheme.labelMedium!;

  /// 12px, [KaziColors.grey], [FontWeight.w400]
  static final labelSm = textTheme.labelSmall!;

  static final textTheme = TextTheme(
    displayLarge: GoogleFonts.outfit(),
    displayMedium: GoogleFonts.outfit(),
    displaySmall: GoogleFonts.outfit(),
    headlineLarge: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w700,
      fontSize: 32,
    ),
    headlineMedium: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    headlineSmall: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ),
    titleLarge: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),
    titleMedium: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    titleSmall: GoogleFonts.outfit(
      color: KaziColors.black,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    bodyLarge: GoogleFonts.outfit(
      color: KaziColors.darkGrey,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    ),
    bodyMedium: GoogleFonts.outfit(
      color: KaziColors.darkGrey,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodySmall: GoogleFonts.outfit(
      color: KaziColors.darkGrey,
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
