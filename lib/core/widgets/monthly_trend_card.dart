import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class MonthlyTrendCard extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String currencyPrefix;

  const MonthlyTrendCard({
    super.key,
    required this.values,
    required this.labels,
    this.currencyPrefix = '₹',
  });

  bool get _hasData => values.isNotEmpty && values.any((v) => v > 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final double total = values.fold(0.0, (sum, v) => sum + v);
    final double average = values.isEmpty ? 0 : total / values.length;

    return _buildGlassContainer(
      context: context,
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _chartLabel,
                  style: AppTextStyles.of(context).trendTitle,
                ),
                Text(
                  '$currencyPrefix${_totalLabel(total)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_hasData)
              AspectRatio(
                aspectRatio: 1.8,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            AppTheme.primaryColor.withValues(alpha: 0.85),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final label = idx < labels.length ? labels[idx] : '';
                            final val = spot.y;
                            return LineTooltipItem(
                              '$label\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: '$currencyPrefix${val.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFFE0E0FF),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _gridInterval(total),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: onSurface.withValues(alpha: 0.07),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _labelInterval(),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= labels.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          reservedSize: 24,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _gridInterval(total),
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _shortCurrency(value),
                              style: TextStyle(
                                fontSize: 9,
                                color: onSurface.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(values.length, (i) {
                          return FlSpot(i.toDouble(), values[i]);
                        }),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.primaryColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 3.5,
                              color: AppTheme.primaryColor,
                              strokeWidth: 1.5,
                              strokeColor: isDark ? AppTheme.darkSurface : Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.18),
                              AppTheme.primaryColor.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildEmptyState(context),

            const SizedBox(height: 14),
            _buildStatsRow(context, total, average),
          ],
        ),
      ),
    );
  }

  String get _chartLabel {
    if (labels.length <= 14) return 'Last ${labels.length} Days';
    if (labels.length == 30) return 'Monthly Trend';
    return '${labels.length}-Day Trend';
  }

  String _totalLabel(double total) {
    if (total >= 100000) return '${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
  }

  Widget _buildStatsRow(BuildContext context, double total, double average) {
    return Row(
      children: [
        _buildStatChip(
          context: context,
          label: 'Total',
          value: '$currencyPrefix${_formatShort(total)}',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          context: context,
          label: 'Avg',
          value: '$currencyPrefix${_formatShort(average)}',
          color: const Color(0xFF00C9A7),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.of(context).trendChipLabel),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.of(context).trendChipValue.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.show_chart_rounded, size: 32, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text('No data yet', style: AppTextStyles.of(context).trendPlaceholder),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatShort(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  String _shortCurrency(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(0)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  double _gridInterval(double total) {
    if (total <= 0) return 1;
    if (total < 100) return 10;
    if (total < 1000) return 100;
    if (total < 10000) return 1000;
    if (total < 100000) return 10000;
    return 50000;
  }

  double _labelInterval() {
    // Show roughly 7 labels max
    final len = labels.length;
    if (len <= 7) return 1;
    if (len <= 14) return 2;
    if (len <= 30) return 5;
    return (len / 7).ceilToDouble();
  }
}
