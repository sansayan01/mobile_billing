import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/text_styles.dart';
import 'package:billing_app/core/widgets/count_up_money.dart';
import 'package:billing_app/core/widgets/press_scale.dart';

class InventoryHealthCard extends StatefulWidget {
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

  @override
  State<InventoryHealthCard> createState() => _InventoryHealthCardState();
}

class _InventoryHealthCardState extends State<InventoryHealthCard> {
  int _selectedSegment = -1; // -1: none, 0: in-stock, 1: low-stock, 2: out-of-stock

  (String, Color) _healthInfo(Brightness b) {
    if (widget.outOfStockCount >= 5 || widget.lowStockCount >= 5) {
      return ('Critical', AppColors.error(b));
    }
    if (widget.outOfStockCount >= 3 || widget.lowStockCount >= 5) {
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

    if (widget.totalProducts == 0) {
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
                      color: isDark ? Colors.white : onSurface,
                    ),
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

    final inStockCount =
        widget.totalProducts - widget.lowStockCount - widget.outOfStockCount;
    final inStockRatio =
        widget.totalProducts > 0 ? inStockCount / widget.totalProducts : 0.0;
    final lowRatio = widget.totalProducts > 0
        ? widget.lowStockCount / widget.totalProducts
        : 0.0;
    final outRatio = widget.totalProducts > 0
        ? widget.outOfStockCount / widget.totalProducts
        : 0.0;

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
                        color: isDark ? Colors.white : onSurface,
                      ),
                ),
                if (widget.onViewDetails != null)
                  PressScale(
                    pressedScale: 0.92,
                    enableHaptic: false,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onViewDetails,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentText(theme.brightness),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Health Indicator Bar (animated draw-in) ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    return Row(
                      children: [
                        if (inStockRatio > 0)
                          Expanded(
                            flex: (inStockRatio * 1000 * t).toInt().clamp(1, 1000),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: (_selectedSegment == -1 || _selectedSegment == 0) ? 1.0 : 0.35,
                              child: Container(color: AppColors.success),
                            ),
                          ),
                        if (lowRatio > 0)
                          Expanded(
                            flex: (lowRatio * 1000 * t).toInt().clamp(1, 1000),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: (_selectedSegment == -1 || _selectedSegment == 1) ? 1.0 : 0.35,
                              child: Container(color: AppColors.warning),
                            ),
                          ),
                        if (outRatio > 0)
                          Expanded(
                            flex: (outRatio * 1000 * t).toInt().clamp(1, 1000),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: (_selectedSegment == -1 || _selectedSegment == 2) ? 1.0 : 0.35,
                              child: Container(color: AppColors.error(theme.brightness)),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Interactive Stat Items ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInteractiveStatItem(
                  index: 0,
                  label: 'In Stock',
                  count: inStockCount,
                  color: AppColors.success,
                  isDark: isDark,
                ),
                _buildInteractiveStatItem(
                  index: 1,
                  label: 'Low Stock',
                  count: widget.lowStockCount,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
                _buildInteractiveStatItem(
                  index: 2,
                  label: 'Out of Stock',
                  count: widget.outOfStockCount,
                  color: AppColors.error(theme.brightness),
                  isDark: isDark,
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
                        color: isDark ? Colors.white : onSurface,
                      ),
                ),
              ],
            ),

            // ── Inline Expansion Drawer on selection ──
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: _selectedSegment == -1
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (_selectedSegment == 0
                                ? AppColors.success
                                : _selectedSegment == 1
                                    ? AppColors.warning
                                    : AppColors.error(theme.brightness))
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_selectedSegment == 0
                                  ? AppColors.success
                                  : _selectedSegment == 1
                                      ? AppColors.warning
                                      : AppColors.error(theme.brightness))
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedSegment == 0
                                ? Icons.check_circle_outline_rounded
                                : _selectedSegment == 1
                                    ? Icons.warning_amber_rounded
                                    : Icons.error_outline_rounded,
                            size: 18,
                            color: _selectedSegment == 0
                                ? AppColors.success
                                : _selectedSegment == 1
                                    ? AppColors.warning
                                    : AppColors.error(theme.brightness),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedSegment == 0
                                  ? '$inStockCount items healthy & ready'
                                  : _selectedSegment == 1
                                      ? '${widget.lowStockCount} items running low'
                                      : '${widget.outOfStockCount} items sold out',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : onSurface,
                              ),
                            ),
                          ),
                          if (widget.onViewDetails != null &&
                              _selectedSegment != 0)
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onViewDetails?.call();
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Restock',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onAccent,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveStatItem({
    required int index,
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedSegment == index;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedSegment = (_selectedSegment == index) ? -1 : index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.16 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.40)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            index == 2 && count > 0
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, pulse, child) {
                      return Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: isSelected ? 0.6 : pulse * 0.5),
                              blurRadius: isSelected ? 6 : 4 * pulse,
                              spreadRadius: isSelected ? 1 : 0.8 * pulse,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountUpText(
                  value: count,
                  style: AppTextStyles.of(context).statCount.copyWith(
                        color: isSelected ? color : null,
                      ),
                ),
                Text(
                  label,
                  style: AppTextStyles.of(context).statLabelSmall,
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
