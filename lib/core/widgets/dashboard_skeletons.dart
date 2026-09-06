import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

/// Pulse-animated skeleton box for loading placeholders. Alternates opacity
/// so it works in both themes without a directional shimmer sweep.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.8).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant
              .withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Hero sales-card skeleton — title row, big number, sparkline strip, stats row.
class HeroCardSkeleton extends StatelessWidget {
  const HeroCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonBox(width: 110, height: 12, radius: 6),
              Spacer(),
              SkeletonBox(width: 64, height: 20, radius: 10),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(width: 180, height: 34, radius: 8),
          const SizedBox(height: 18),
          const SkeletonBox(height: 44, radius: 8),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.divider(b)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 30, radius: 6)),
              SizedBox(width: 24),
              Expanded(child: SkeletonBox(height: 30, radius: 6)),
              SizedBox(width: 24),
              Expanded(child: SkeletonBox(height: 30, radius: 6)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chart card skeleton — title row + squarish chart area + legend lines.
/// [title] renders the real section title (stable label during load);
/// when null a skeleton bar stands in for it.
class ChartCardSkeleton extends StatelessWidget {
  final String? title;

  const ChartCardSkeleton({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: title != null
                    ? Text(
                        title!,
                        style: AppTextStyles.of(context).trendTitle,
                      )
                    : const SkeletonBox(width: 140, height: 14, radius: 6),
              ),
              const SkeletonBox(width: 50, height: 14, radius: 6),
            ],
          ),
          const SizedBox(height: 20),
          const SkeletonBox(height: 160, radius: 12),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: SkeletonBox(height: 34, radius: 8)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 34, radius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent-transactions skeleton — 3 row placeholders (replaces the
/// page-local one; same layout, now with pulse animation).
class TxnListSkeleton extends StatelessWidget {
  const TxnListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const darkSurface = AppTheme.darkSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? darkSurface.withValues(alpha: 0.70)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? darkSurface.withValues(alpha: 0.50)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Transactions',
              style: AppTextStyles.of(context).txnTitle),
          const SizedBox(height: 20),
          ...List.generate(3, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: SkeletonBox(height: 36, radius: 10),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 80, height: 12, radius: 6),
                      SizedBox(height: 6),
                      SkeletonBox(width: 50, height: 10, radius: 5),
                    ],
                  ),
                ),
                SkeletonBox(width: 50, height: 14, radius: 6),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
