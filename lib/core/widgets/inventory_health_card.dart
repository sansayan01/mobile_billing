import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class InventoryHealthCard extends StatelessWidget {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final VoidCallback? onViewDetails;

  const InventoryHealthCard({
    super.key,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    this.onViewDetails,
  });

  (String, Color) _healthInfo(Brightness b) {
    if (outOfStockCount >= 5 || lowStockCount >= 5) {
      return ('Critical', AppColors.error(b));
    }
    if (outOfStockCount >= 3 || lowStockCount >= 5) {
      return ('Fair', AppColors.warning);
    }
    return ('Good', AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    if (totalProducts == 0) {
      return _buildGlassContainer(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Health',
                style: AppTextStyles.of(context).inventoryTitle.copyWith(
                  color: isDark ? Colors.white : onSurface),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 36,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No products yet',
                      style: AppTextStyles.of(context).inventoryEmpty.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final inStockCount = totalProducts - lowStockCount - outOfStockCount;
    final inStockRatio = totalProducts > 0 ? inStockCount / totalProducts : 0.0;
    final lowRatio = totalProducts > 0 ? lowStockCount / totalProducts : 0.0;
    final outRatio = totalProducts > 0 ? outOfStockCount / totalProducts : 0.0;

    return _buildGlassContainer(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title Row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory Health',
                  style: AppTextStyles.of(context).inventoryTitle.copyWith(
                    color: isDark ? Colors.white : onSurface),
                ),
                if (onViewDetails != null)
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentText(theme.brightness),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Health Indicator Bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    if (inStockRatio > 0)
                      Expanded(
                        flex: (inStockRatio * 1000).toInt(),
                        child: Container(color: AppColors.success),
                      ),
                    if (lowRatio > 0)
                      Expanded(
                        flex: (lowRatio * 1000).toInt(),
                        child: Container(color: AppColors.warning),
                      ),
                    if (outRatio > 0)
                      Expanded(
                        flex: (outRatio * 1000).toInt(),
                        child:
                            Container(color: AppColors.error(theme.brightness)),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Stat Items ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'In Stock',
                  count: inStockCount,
                  color: AppColors.success,
                ),
                _StatItem(
                  label: 'Low Stock',
                  count: lowStockCount,
                  color: AppColors.warning,
                ),
                _StatItem(
                  label: 'Out of Stock',
                  count: outOfStockCount,
                  color: AppColors.error(theme.brightness),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Health Score ──
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _healthInfo(theme.brightness).$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Health: ${_healthInfo(theme.brightness).$1}',
                  style: AppTextStyles.of(context).healthLabel.copyWith(
                    color: isDark ? Colors.white : onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required BuildContext context,
    required Widget child,
  }) {
    final b = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(b)),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: b == Brightness.dark ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: AppTextStyles.of(context).statCount,
            ),
            Text(
              label,
              style: AppTextStyles.of(context).statLabelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
