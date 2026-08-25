import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Design System v3 "Midnight Lime" — see design.md v3 section.
/// Public API (primaryColor, gradients, helpers) preserved from v2 so all
/// existing call sites keep compiling; values re-pointed to v3 tokens.
class AppTheme {
  AppTheme._();

  // ── Core brand tokens (v3) ──────────────────────────────────────────
  static const Color primaryColor = AppColors.accent;
  static const Color secondaryColor = AppColors.info;
  static const Color backgroundColor = AppColors.lightBg;
  static const Color surfaceColor = AppColors.lightSurface;
  static const Color errorColor = AppColors.errorLight;
  static const Color onAccentColor = AppColors.onAccent;

  // ── Dark surface colors (v3 midnight palette, names preserved) ──────
  static const Color darkBackground = AppColors.darkBg;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkCard = AppColors.darkSurface;
  static const Color darkInput = AppColors.darkSurfaceElevated;
  static const Color darkBorder = AppColors.darkBorder;

  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _FadeSlideUpTransition(),
      TargetPlatform.iOS: _FadeSlideUpTransition(),
      TargetPlatform.macOS: _FadeSlideUpTransition(),
      TargetPlatform.windows: _FadeSlideUpTransition(),
      TargetPlatform.linux: _FadeSlideUpTransition(),
    },
  );

  // ── Background gradients (v3) ───────────────────────────────────────
  static const LinearGradient aiGradient = AppColors.lightGradient;
  static const LinearGradient darkGradient = AppColors.darkGradient;

  static LinearGradient gradientFor(BuildContext context) =>
      AppColors.gradientFor(context);

  static final TextTheme textTheme =
      GoogleFonts.ibmPlexSansTextTheme(AppTypography.textTheme).copyWith(
    bodyLarge: GoogleFonts.ibmPlexSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Colors.black,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    bodyMedium: GoogleFonts.ibmPlexSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: Colors.black,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );

  static TextStyle ibm(double size, FontWeight weight, Color color) =>
      GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: weight, color: color);

  /// Money/numeric text in IBM Plex Mono (v3) — ₹ amounts, balances.
  static TextStyle money(double size, FontWeight weight, Color color) =>
      AppMoneyText.sized(size, weight, color);

  // ── Shared input decoration theme (used by both light & dark) ──────
  static InputDecorationTheme _baseInputTheme({
    required Color fillColor,
    required Color hintColor,
    required Color borderColor,
    required Color errorColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(
        color: hintColor,
        fontWeight: FontWeight.normal,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.info,
      onSecondary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightBgSecondary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outlineVariant: AppColors.lightBorder,
      error: AppColors.errorLight,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      pageTransitionsTheme: pageTransitions,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      colorScheme: colorScheme,
      dividerColor: AppColors.lightDivider,
      textTheme: textTheme.apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        color: surfaceColor,
      ),
      inputDecorationTheme: _baseInputTheme(
        fillColor: AppColors.lightSurface,
        hintColor: AppColors.lightTextTertiary,
        borderColor: AppColors.lightBorder,
        errorColor: AppColors.errorLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentTextOnLight,
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        shape: CircleBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentTextOnLight,
        linearTrackColor: AppColors.lightDivider,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.lightTextTertiary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.accentTextOnLight),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onAccent;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.lightBorder;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightModal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: textTheme.bodyMedium
            ?.copyWith(color: AppColors.lightBg, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgSecondary,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium
            ?.copyWith(color: AppColors.lightTextSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.info,
      onSecondary: AppColors.onAccent,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceElevated,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outlineVariant: AppColors.darkBorder,
      error: AppColors.errorDark,
      onError: AppColors.onAccent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      pageTransitionsTheme: pageTransitions,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      colorScheme: darkColorScheme,
      dividerColor: AppColors.darkDivider,
      textTheme: textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        color: darkCard,
      ),
      inputDecorationTheme: _baseInputTheme(
        fillColor: AppColors.darkSurfaceElevated,
        hintColor: AppColors.darkTextTertiary,
        borderColor: AppColors.darkBorder,
        errorColor: AppColors.errorDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        shape: CircleBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.darkDivider,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.darkTextTertiary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.accent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onAccent;
          }
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.darkSurfaceElevated;
        }),
      ),
      // Dark theme defaults for common widgets
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkModal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium
            ?.copyWith(color: AppColors.darkTextSecondary),
      ),
    );
  }
}

class _FadeSlideUpTransition extends PageTransitionsBuilder {
  const _FadeSlideUpTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
