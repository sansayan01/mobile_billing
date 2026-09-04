import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';
import 'package:billing_app/core/theme/text_styles.dart';

/// Big prominent action card (e.g. "New Bill") — v3 flat surface,
/// hairline border, colored icon chip. No glassmorphism.
class DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppDurations.normal,
      curve: AppDurations.strongEase,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.rXl,
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(b),
              borderRadius: AppRadius.rXl,
              border: Border.all(color: AppColors.border(b), width: 1),
            ),
            child: Row(
              children: [
                // Colored icon chip — squircle (continuous corners)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),
                const SizedBox(width: 16),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.of(context)
                            .actionCardTitle
                            .copyWith(color: AppColors.textPrimary(b)),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: AppTextStyles.of(context).actionCardSubtitle
                              .copyWith(color: AppColors.textTertiary(b)),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textTertiary(b),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact square tile for the quick-actions grid — icon on top,
/// short label below. v3 flat surface + hairline border, colored icon chip.
/// Entrance: fade+slide with per-tile stagger (no overshoot on
/// informational UI — ui-ux-pro-max guidance), wrapped in RepaintBoundary.
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Duration staggerDelay;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.staggerDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: AppDurations.normal + staggerDelay,
        curve: Interval(
          staggerDelay.inMilliseconds /
              (AppDurations.normal.inMilliseconds + staggerDelay.inMilliseconds),
          1.0,
          curve: AppDurations.strongEase,
        ),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
           borderRadius: AppRadius.rLg,
           splashColor: color.withValues(alpha: 0.12),
           child: Container(
             padding:
                 const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
             decoration: BoxDecoration(
               color: AppColors.surface(b),
               borderRadius: AppRadius.rLg,
               border: Border.all(color: AppColors.border(b), width: 1),
             ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Colored icon chip
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 7),
                // Label
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context)
                      .tileLabel
                      .copyWith(
                          color: AppColors.textSecondary(b), fontSize: 10.5),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
