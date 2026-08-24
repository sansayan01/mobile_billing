import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets sectionV = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static final BorderRadius rSm = BorderRadius.circular(sm);
  static final BorderRadius rMd = BorderRadius.circular(md);
  static final BorderRadius rLg = BorderRadius.circular(lg);
  static final BorderRadius rXl = BorderRadius.circular(xl);
}

class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double low = 1;
  static const double mid = 3;
  static const double high = 8;

  static List<BoxShadow> shadowLow(Color base) => [
        BoxShadow(
          color: base.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowMid(Color base) => [
        BoxShadow(
          color: base.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}

class AppTouchTarget {
  AppTouchTarget._();

  static const double min = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
}
