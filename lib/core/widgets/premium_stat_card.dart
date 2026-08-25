import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';
import 'package:billing_app/core/theme/text_styles.dart';

/// Liquid-glass stat card — semi-transparent colour-tinted container.
class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const darkSurfaceColor = AppTheme.darkSurface;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: AppDurations.slow,
      curve: AppDurations.ease,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // soft colored glow
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          // subtle ambient shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          // semi-transparent tinted glass fill
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? darkSurfaceColor.withValues(alpha: 0.40)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.60),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon chip + label row
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.of(context).statLabel.copyWith(
                            color: color.withValues(alpha: 0.85)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Big value — crossfades smoothly on refresh
                  AnimatedSwitcher(
                    duration: AppDurations.normal,
                    switchInCurve: AppDurations.ease,
                    switchOutCurve: AppDurations.ease,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      value,
                      key: ValueKey<String>(value),
                      style:
                          AppTextStyles.of(context).statValue.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),

            // Watermark icon (bottom-right, extra subtle)
            if (icon != null)
              Positioned(
                bottom: -6,
                right: -6,
                child: Icon(
                  icon,
                  size: 58,
                  color: darkSurfaceColor.withValues(alpha: 0.12),
                ),
              ),
          ],
        ),
      ),
        ),
      );
  }
}
