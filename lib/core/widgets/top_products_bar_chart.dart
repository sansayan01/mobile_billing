import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class TopProductsBarChart extends StatelessWidget {
  final List<ProductSales> products;

  const TopProductsBarChart({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    if (products.isEmpty) {
      return _glass(
        context: context,
        isDark: isDark,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 36, color: AppTheme.primaryColor),
              SizedBox(height: 12),
              Text('No product data yet', style: TextStyle(fontSize: 14)),
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

    return _glass(
      context: context,
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Top Products', style: AppTextStyles.of(context).trendTitle),
                ),
                Text('by Qty Sold', style: AppTextStyles.of(context).trendChipLabel),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxQty * 1.2).toDouble(),
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.primaryColor.withValues(alpha: 0.9),
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
                              text: '${p.quantity} units · ₹${p.revenue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFE0E0FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
                          if (idx < 0 || idx >= products.length) return const SizedBox();
                          final label = products[idx].shortName;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
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
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: maxQty > 0 ? (maxQty / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: onSurface.withValues(alpha: 0.08),
                        strokeWidth: 1,
                      );
                    },
                    checkToShowHorizontalLine: (value) => true,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(products.length, (index) {
                    final p = products[index];
                    final ratio = maxRevenue > 0 ? p.revenue / maxRevenue : 0.5;
                    final color = Color.lerp(
                      AppTheme.primaryColor,
                      const Color(0xFF4CAF50),
                      ratio,
                    )!;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: p.quantity.toDouble(),
                          color: color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            if (products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: ${products.fold<int>(0, (s, p) => s + p.quantity)} units',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '₹${products.fold<double>(0, (s, p) => s + p.revenue).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)),
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
