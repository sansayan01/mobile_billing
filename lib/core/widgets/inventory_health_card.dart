import 'package:flutter/material.dart';
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

  (String, Color) get _healthInfo {
    if (outOfStockCount >= 5 || lowStockCount >= 5) return ('Critical', const Color(0xFFEF4444));
    if (outOfStockCount >= 3 || lowStockCount >= 5) return ('Fair', const Color(0xFFF59E0B));
    return ('Good', const Color(0xFF22C55E));
  }

  @override
  Widget build(BuildContext context) {
    if (totalProducts == 0) {
      return _buildGlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Health',
                style: AppTextStyles.inventoryTitle,
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 36,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No products yet',
                      style: AppTextStyles.inventoryEmpty,
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
                  style: AppTextStyles.inventoryTitle,
                ),
                if (onViewDetails != null)
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
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
                        child: Container(color: const Color(0xFF22C55E)),
                      ),
                    if (lowRatio > 0)
                      Expanded(
                        flex: (lowRatio * 1000).toInt(),
                        child: Container(color: const Color(0xFFF59E0B)),
                      ),
                    if (outRatio > 0)
                      Expanded(
                        flex: (outRatio * 1000).toInt(),
                        child: Container(color: const Color(0xFFEF4444)),
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
                  color: const Color(0xFF22C55E),
                ),
                _StatItem(
                  label: 'Low Stock',
                  count: lowStockCount,
                  color: const Color(0xFFF59E0B),
                ),
                _StatItem(
                  label: 'Out of Stock',
                  count: outOfStockCount,
                  color: const Color(0xFFEF4444),
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
                    color: _healthInfo.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Health: ${_healthInfo.$1}',
                  style: AppTextStyles.healthLabel.copyWith(color: _healthInfo.$2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              style: AppTextStyles.statCount,
            ),
            Text(
              label,
              style: AppTextStyles.statLabelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
