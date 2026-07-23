import 'package:flutter/material.dart';

/// Pre-computed IBM Plex Sans text styles — computed once at load time,
/// not on every widget rebuild. Use these instead of calling
/// GoogleFonts.ibmPlexSans() inline inside build() methods.
class AppTextStyles {
  AppTextStyles._();

  // ── Dashboard section titles ────────────────────────────────────────
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Color(0xFF1A1A2E),
    letterSpacing: -0.2,
  );

  // ── Greeting header ─────────────────────────────────────────────────
  static const TextStyle greetingSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9E9EA7),
    letterSpacing: 0.3,
  );
  static const TextStyle greetingName = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Color(0xFF1A1A2E),
    height: 1.15,
  );
  static const TextStyle greetingDate = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B0BA),
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
    color: Color(0xFF1A1A2E),
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
    color: Color(0xFF757580),
  );

  // ── Recent transactions ─────────────────────────────────────────────
  static const TextStyle txnTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A2E),
  );
  static const TextStyle txnStaffName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A2E),
  );
  static const TextStyle txnMeta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8E8E9A),
  );
  static const TextStyle txnAmount = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A1A2E),
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle txnSeeAll = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6C63FF),
  );
  static const TextStyle txnEmptyTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8E8E9A),
  );
  static const TextStyle txnEmptySubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB0B0BA),
  );

  // ── Sales trend card ────────────────────────────────────────────────
  static const TextStyle trendTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A1A2E),
  );
  static const TextStyle trendChipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9E9EA7),
  );
  static const TextStyle trendChipValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle trendPlaceholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B0BA),
  );

  // ── Low stock banner ────────────────────────────────────────────────
  static const TextStyle lowStockText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFFB00020),
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
}
