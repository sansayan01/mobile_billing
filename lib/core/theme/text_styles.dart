import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Pre-computed IBM Plex Sans text styles — computed once at load time,
/// not on every widget rebuild. Use these instead of calling
/// GoogleFonts.ibmPlexSans() inline inside build() methods.
///
/// For dark-mode‑aware styles, call [of] with the current [BuildContext].
class AppTextStyles {
  AppTextStyles._();

  // ── Dashboard section titles ────────────────────────────────────────
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.lightTextPrimary,
    letterSpacing: -0.2,
  );

  // ── Greeting header ─────────────────────────────────────────────────
  static const TextStyle greetingSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextTertiary,
    letterSpacing: 0.3,
  );
  static const TextStyle greetingName = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.lightTextPrimary,
    height: 1.15,
  );
  static const TextStyle greetingDate = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextTertiary,
  );

  // ── Stat cards (PremiumStatCard) ────────────────────────────────────
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ── Quick action tiles ──────────────────────────────────────────────
  static const TextStyle tileLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    letterSpacing: 0.1,
  );

  // ── Dashboard action card ───────────────────────────────────────────
  static const TextStyle actionCardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );
  static const TextStyle actionCardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextSecondary,
  );

  // ── Recent transactions ─────────────────────────────────────────────
  static const TextStyle txnTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );
  static const TextStyle txnStaffName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );
  static const TextStyle txnMeta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextSecondary,
  );
  static const TextStyle txnAmount = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle txnSeeAll = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.accentTextOnLight,
  );
  static const TextStyle txnEmptyTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextSecondary,
  );
  static const TextStyle txnEmptySubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextTertiary,
  );

  // ── Sales trend card ────────────────────────────────────────────────
  static const TextStyle trendTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
  );
  static const TextStyle trendChipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextTertiary,
  );
  static const TextStyle trendChipValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle trendPlaceholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextTertiary,
  );

  // ── Low stock banner ────────────────────────────────────────────────
  static const TextStyle lowStockText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.errorLight,
  );

  // ── Inventory health ────────────────────────────────────────────────
  static const TextStyle inventoryTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle inventoryEmpty = TextStyle(
    fontSize: 14,
    color: Color(0x99FFFFFF),
  );
  static const TextStyle statCount = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle statLabelSmall = TextStyle(
    fontSize: 11,
    color: Color(0xB3FFFFFF),
  );
  static const TextStyle healthLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ── Dynamic text styles (dark‑mode aware) ────────────────────────────

  /// Returns text styles adapted to the current theme brightness.
  static AdaptiveTextStyles of(BuildContext context) {
    return AdaptiveTextStyles._(Theme.of(context).brightness);
  }
}

/// Theme‑aware text style set.  Call [AppTextStyles.of(context)] to get one.
class AdaptiveTextStyles {
  final Brightness _brightness;
  AdaptiveTextStyles._(this._brightness);

  bool get _isDark => _brightness == Brightness.dark;

  Color get _onSurface => AppColors.textPrimary(_brightness);
  Color get _onSurfaceVariant =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary;
  Color get _onSurfaceDisabled =>
      _isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
  Color get _onSurfaceMeta =>
      _isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary;
  Color get _onSurfaceMuted =>
      _isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary;
  Color get _primary => AppColors.accentText(_brightness);

  TextStyle get sectionTitle =>
      AppTextStyles.sectionTitle.copyWith(color: _onSurface);
  TextStyle get greetingName =>
      AppTextStyles.greetingName.copyWith(color: _onSurface);
  TextStyle get greetingSubtitle =>
      AppTextStyles.greetingSubtitle.copyWith(color: _onSurfaceVariant);
  TextStyle get greetingDate =>
      AppTextStyles.greetingDate.copyWith(color: _onSurfaceDisabled);
  TextStyle get tileLabel =>
      AppTextStyles.tileLabel.copyWith(color: _onSurface);
  TextStyle get actionCardTitle =>
      AppTextStyles.actionCardTitle.copyWith(color: _onSurface);
  TextStyle get actionCardSubtitle =>
      AppTextStyles.actionCardSubtitle.copyWith(color: _onSurfaceMuted);
  TextStyle get txnTitle => AppTextStyles.txnTitle.copyWith(color: _onSurface);
  TextStyle get txnStaffName =>
      AppTextStyles.txnStaffName.copyWith(color: _onSurface);
  TextStyle get txnMeta =>
      AppTextStyles.txnMeta.copyWith(color: _onSurfaceMeta);
  TextStyle get txnAmount =>
      AppTextStyles.txnAmount.copyWith(color: _onSurface);
  TextStyle get txnSeeAll => AppTextStyles.txnSeeAll.copyWith(color: _primary);
  TextStyle get txnEmptyTitle =>
      AppTextStyles.txnEmptyTitle.copyWith(color: _onSurfaceMeta);
  TextStyle get txnEmptySubtitle =>
      AppTextStyles.txnEmptySubtitle.copyWith(color: _onSurfaceDisabled);
  TextStyle get trendTitle =>
      AppTextStyles.trendTitle.copyWith(color: _onSurface);
  TextStyle get trendChipLabel =>
      AppTextStyles.trendChipLabel.copyWith(color: _onSurfaceVariant);
  TextStyle get trendChipValue =>
      AppTextStyles.trendChipValue.copyWith(color: _onSurface);
  TextStyle get trendPlaceholder =>
      AppTextStyles.trendPlaceholder.copyWith(color: _onSurfaceDisabled);
  TextStyle get lowStockText => AppTextStyles.lowStockText;
  TextStyle get statLabel =>
      AppTextStyles.statLabel.copyWith(color: _onSurfaceVariant);
  TextStyle get statValue =>
      AppTextStyles.statValue.copyWith(color: Colors.white);
  TextStyle get healthLabel =>
      AppTextStyles.healthLabel.copyWith(color: _isDark ? Colors.white : _onSurface);
  TextStyle get inventoryTitle =>
      AppTextStyles.inventoryTitle.copyWith(color: _isDark ? Colors.white : _onSurface);
  TextStyle get inventoryEmpty =>
      AppTextStyles.inventoryEmpty.copyWith(
          color: _isDark ? Colors.white.withValues(alpha: 0.6) : _onSurfaceVariant);
  TextStyle get statCount =>
      AppTextStyles.statCount.copyWith(color: _isDark ? Colors.white : _onSurface);
  TextStyle get statLabelSmall =>
      AppTextStyles.statLabelSmall.copyWith(color: _isDark ? Colors.white.withValues(alpha: 0.6) : _onSurfaceVariant);
}
