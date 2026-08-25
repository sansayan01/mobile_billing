import 'package:flutter/material.dart';

/// Design System v3 "Midnight Lime" — semantic color tokens.
/// Source of truth: design.md (v3 section). DO NOT hardcode colors in pages —
/// use these tokens or Theme.of(context).colorScheme.
class AppColors {
  AppColors._();

  // ── Accent (lime) — surgical use only: CTA, active state, key metric ──
  static const Color accent = Color(0xFFC8F031);
  static const Color accentLight = Color(0xFFE4FF6A);
  static const Color accentDark = Color(0xFF9FC414);
  static const Color onAccent = Color(0xFF0B0F1A);
  static const Color accentSubtle = Color(0x1FC8F031);
  static const Color accentTextOnLight = Color(0xFF55700A);

  // ── Dark palette (primary experience) ──
  static const Color darkBg = Color(0xFF0B0F1A);
  static const Color darkBgSecondary = Color(0xFF0F1522);
  static const Color darkSurface = Color(0xFF151C2C);
  static const Color darkSurfaceElevated = Color(0xFF1C2436);
  static const Color darkModal = Color(0xFF1A2233);
  static const Color darkNav = Color(0xFF101625);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFFA8B3C5);
  static const Color darkTextTertiary = Color(0xFF6B7688);
  static const Color darkTextDisabled = Color(0xFF454F60);
  static const Color darkBorder = Color(0x1AFFFFFF);
  static const Color darkDivider = Color(0x0DFFFFFF);

  // ── Light palette (secondary, theme toggle preserved) ──
  static const Color lightBg = Color(0xFFF4F6F4);
  static const Color lightBgSecondary = Color(0xFFEDF1EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightModal = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF101828);
  static const Color lightTextSecondary = Color(0xFF5A6472);
  static const Color lightTextTertiary = Color(0xFF98A2B3);
  static const Color lightTextDisabled = Color(0xFFC2C9C4);
  static const Color lightBorder = Color(0xFFE2E7E2);
  static const Color lightDivider = Color(0xFFEBEFEB);

  // ── Semantic ──
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color errorLight = Color(0xFFE11D48);
  static const Color errorDark = Color(0xFFF4586F);
  static const Color info = Color(0xFF5AB8F0);

  // Light-mode-safe TEXT variants (same hue, darker for contrast on white)
  static const Color successTextOnLight = Color(0xFF047857);
  static const Color warningTextOnLight = Color(0xFFB45309);
  static const Color infoTextOnLight = Color(0xFF0369A1);

  /// Semantic colors usable AS TEXT for the given brightness.
  static Color successText(Brightness b) =>
      b == Brightness.dark ? success : successTextOnLight;
  static Color warningText(Brightness b) =>
      b == Brightness.dark ? warning : warningTextOnLight;
  static Color infoText(Brightness b) =>
      b == Brightness.dark ? info : infoTextOnLight;

  // ── Brightness-resolved helpers ──
  static Color bg(Brightness b) =>
      b == Brightness.dark ? darkBg : lightBg;
  static Color surface(Brightness b) =>
      b == Brightness.dark ? darkSurface : lightSurface;
  static Color surfaceElevated(Brightness b) =>
      b == Brightness.dark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(Brightness b) =>
      b == Brightness.dark ? darkTextTertiary : lightTextTertiary;
  static Color border(Brightness b) =>
      b == Brightness.dark ? darkBorder : lightBorder;
  static Color divider(Brightness b) =>
      b == Brightness.dark ? darkDivider : lightDivider;
  static Color error(Brightness b) =>
      b == Brightness.dark ? errorDark : errorLight;

  /// Accent color usable AS TEXT for the given brightness.
  /// Lime on light bg fails contrast — use dark lime there.
  static Color accentText(Brightness b) =>
      b == Brightness.dark ? accent : accentTextOnLight;

  /// Foreground for buttons/chips filled with [accent].
  static Color get foregroundOnAccent => onAccent;

  // ── Background gradients (v3) ──
  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFF4F6F4), Color(0xFFEFF3EE), Color(0xFFEAF3EA)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0B0F1A), Color(0xFF0F1522), Color(0xFF121A2A)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gradientFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkGradient
          : lightGradient;
}
