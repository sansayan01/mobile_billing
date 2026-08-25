import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'IBM Plex Sans';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.15,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}

/// v3 "Midnight Lime" — money/numeric styles in IBM Plex Mono.
/// Use for ₹ amounts, balances, big metrics. Tabular by default.
/// Pre-computed (static final) — never call GoogleFonts inside build().
class AppMoneyText {
  AppMoneyText._();

  /// Hero balance (32 w700) — dashboard total, receipt grand total.
  static final TextStyle balance = GoogleFonts.ibmPlexMono(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Card-level metric (22 w700) — stat card values.
  static final TextStyle metric = GoogleFonts.ibmPlexMono(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.15,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Row-level amount (16 w600) — list rows, line items.
  static final TextStyle row = GoogleFonts.ibmPlexMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle sized(double size, FontWeight weight, Color color) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size >= 22 ? -0.3 : 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
