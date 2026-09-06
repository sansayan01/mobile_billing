import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class TopProductsBarChart extends StatefulWidget {
  final List<ProductSales> products;

  const TopProductsBarChart({
    super.key,
    required this.products,
  });

  @override
  State<TopProductsBarChart> createState() => _TopProductsBarChartState();
}

class _TopProductsBarChartState extends State<TopProductsBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final products = widget.products;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final accent = AppColors.accentText(theme.brightness);

    if (products.isEmpty) {
      return _glass(
        context: context,
        isDark: isDark,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 36, color: accent),
              const SizedBox(height: 12),
              const Text('No product data yet', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final maxQty = products
        .map((p) => p.quantity)
        .reduce((a, b) => a > b ? a : b);
    final maxRevenue = products
        .map((p) => p.revenue)
        .reduce((a, b) => a > b ? a : b);

    final touchedProduct = (_touchedIndex >= 0 && _touchedIndex < products.length)
        ? products[_touchedIndex]
        : null;

    return _glass(
      context: context,
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header & Mode ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Products',
                          style: AppTextStyles.of(context).trendTitle),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          touchedProduct != null
                              ? '#${_touchedIndex + 1} ${touchedProduct.name}'
                              : 'Ranked by volume sold',
                          key: ValueKey(touchedProduct?.name ?? 'default'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: touchedProduct != null
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: touchedProduct != null
                                ? accent
                                : AppColors.textTertiary(theme.brightness),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border(theme.brightness),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 12, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        'Touch bar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Bar Chart ──
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxQty * 1.25).toDouble(),
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        return;
                      }
                      final newIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                      if (_touchedIndex != newIndex) {
                        HapticFeedback.selectionClick();
                        setState(() => _touchedIndex = newIndex);
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => isDark
                          ? const Color(0xFF1A2233)
                          : const Color(0xFF2D3748),
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final p = products[groupIndex];
                        return BarTooltipItem(
                          '${p.name}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${p.quantity} units · ₹${p.revenue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= products.length) {
                            return const SizedBox();
                          }
                          final isSelected = _touchedIndex == idx;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _touchedIndex =
                                    (_touchedIndex == idx) ? -1 : idx;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                products[idx].shortName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? accent
                                      : onSurface.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: onSurface.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval:
                        maxQty > 0 ? (maxQty / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.divider(theme.brightness),
                        strokeWidth: 1,
                      );
                    },
                    checkToShowHorizontalLine: (value) => true,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(products.length, (index) {
                    final p = products[index];
                    final ratio =
                        maxRevenue > 0 ? p.revenue / maxRevenue : 0.5;
                    final isTouched = _touchedIndex == index;
                    final hasTouch = _touchedIndex != -1;

                    Color barColor = Color.lerp(
                      AppColors.accent,
                      AppColors.success,
                      ratio,
                    )!;

                    if (hasTouch && !isTouched) {
                      barColor = barColor.withValues(alpha: 0.35);
                    }

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: p.quantity.toDouble(),
                          color: isTouched ? AppColors.accentLight : barColor,
                          width: isTouched ? 24 : 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (maxQty * 1.25).toDouble(),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.black.withValues(alpha: 0.03),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                duration: MediaQuery.of(context).disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ),

            // ── Bottom Summary Row ──
            if (products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    // Rank badge for touched item or #1
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events_rounded,
                              size: 13, color: accent),
                          const SizedBox(width: 4),
                          Text(
                            _touchedIndex >= 0
                                ? 'Rank #${_touchedIndex + 1}'
                                : '#1 ${products.first.shortName}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      touchedProduct != null
                          ? '₹${touchedProduct.revenue.toStringAsFixed(0)} (${touchedProduct.quantity} pcs)'
                          : '₹${products.fold<double>(0, (s, p) => s + p.revenue).toStringAsFixed(0)} Total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successText(theme.brightness),
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

  Widget _glass({
    required BuildContext context,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSurface.withValues(alpha: 0.50)
              : Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProductSales {
  final String name;
  final String shortName;
  final int quantity;
  final double revenue;

  const ProductSales(this.name, this.shortName, this.quantity, this.revenue);
}

class ProductAggregator {
  static List<ProductSales> topProducts(
    List<dynamic> billHistory, {
    int limit = 5,
  }) {
    final Map<String, ProductSales> map = {};
    for (final bill in billHistory) {
      final items = bill.items ?? [];
      for (final item in items) {
        final pName = (item.productName ?? 'Unknown').trim();
        final existing = map[pName];
        final qty = item.quantity is int
            ? item.quantity as int
            : (item.quantity as num).toInt();
        final total = item.total is double
            ? item.total as double
            : (item.total as num).toDouble();

        if (existing != null) {
          map[pName] = ProductSales(
            pName,
            existing.shortName,
            existing.quantity + qty,
            existing.revenue + total,
          );
        } else {
          final short = pName.length > 14 ? '${pName.substring(0, 12)}…' : pName;
          map[pName] = ProductSales(pName, short, qty, total);
        }
      }
    }
    final sorted = map.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    return sorted.take(limit).toList();
  }
}
