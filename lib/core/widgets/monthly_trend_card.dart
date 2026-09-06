import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';

class MonthlyTrendCard extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final String currencyPrefix;

  const MonthlyTrendCard({
    super.key,
    required this.values,
    required this.labels,
    this.currencyPrefix = '₹',
  });

  @override
  State<MonthlyTrendCard> createState() => _MonthlyTrendCardState();
}

class _MonthlyTrendCardState extends State<MonthlyTrendCard> {
  int _touchedIndex = -1;

  bool get _hasData =>
      widget.values.isNotEmpty && widget.values.any((v) => v > 0);

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    final labels = widget.labels;
    final currencyPrefix = widget.currencyPrefix;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final accent = AppColors.accentText(theme.brightness);

    final double total = values.fold(0.0, (sum, v) => sum + v);
    final double average = values.isEmpty ? 0 : total / values.length;

    final hasValidTouch = _touchedIndex >= 0 && _touchedIndex < values.length;
    final touchedValue = hasValidTouch ? values[_touchedIndex] : null;
    final touchedLabel =
        (hasValidTouch && _touchedIndex < labels.length) ? labels[_touchedIndex] : null;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chartLabel,
                      style: AppTextStyles.of(context).trendTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValidTouch
                          ? '$touchedLabel sales'
                          : 'Daily sales volume',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasValidTouch
                            ? accent
                            : AppColors.textTertiary(theme.brightness),
                        fontWeight: hasValidTouch
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    key: ValueKey(hasValidTouch ? 'touched-$touchedValue' : 'total-$total'),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasValidTouch
                          ? accent.withValues(alpha: 0.16)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasValidTouch
                            ? accent.withValues(alpha: 0.35)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      hasValidTouch
                          ? '$currencyPrefix${touchedValue!.toStringAsFixed(0)}'
                          : '$currencyPrefix${_totalLabel(total)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: hasValidTouch
                            ? accent
                            : AppColors.textPrimary(theme.brightness),
                      ),
                    ),
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
                      touchCallback: (FlTouchEvent event, response) {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.lineBarSpots == null ||
                            response.lineBarSpots!.isEmpty) {
                          return;
                        }
                        final newIndex =
                            response.lineBarSpots!.first.spotIndex;
                        if (_touchedIndex != newIndex) {
                          HapticFeedback.selectionClick();
                          setState(() => _touchedIndex = newIndex);
                        }
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => isDark
                            ? const Color(0xFF1A2233)
                            : const Color(0xFF2D3748),
                        tooltipRoundedRadius: 10,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final label =
                                idx < labels.length ? labels[idx] : '';
                            final val = spot.y;
                            return LineTooltipItem(
                              '$label\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '$currencyPrefix${val.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
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
                          color: AppColors.divider(theme.brightness),
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
                            if (idx < 0 || idx >= labels.length) {
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
                                  labels[idx],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? accent
                                        : onSurface.withValues(alpha: 0.6),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
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
                          reservedSize: 36,
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
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
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
                        color: accent,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        isStepLineChart: false,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isTouched = index == _touchedIndex;
                            final isLast = index == values.length - 1;

                            if (isTouched) {
                              return FlDotCirclePainter(
                                radius: 6.0,
                                color: AppColors.accentLight,
                                strokeWidth: 2.5,
                                strokeColor: isDark
                                    ? AppTheme.darkSurface
                                    : Colors.white,
                              );
                            }

                            return FlDotCirclePainter(
                              radius: isLast ? 4.5 : 2.5,
                              color: accent,
                              strokeWidth: 1.5,
                              strokeColor: isDark
                                  ? AppTheme.darkSurface
                                  : Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withValues(alpha: 0.28),
                              accent.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: MediaQuery.of(context).disableAnimations
                      ? Duration.zero
                      : AppDurations.normal,
                  curve: Curves.easeOutCubic,
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
    if (widget.labels.length <= 14) return 'Last ${widget.labels.length} Days';
    if (widget.labels.length == 30) return 'Monthly Trend';
    return '${widget.labels.length}-Day Trend';
  }

  String _totalLabel(double total) {
    if (total >= 100000) return '${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
  }

  Widget _buildStatsRow(BuildContext context, double total, double average) {
    final b = Theme.of(context).brightness;
    return Row(
      children: [
        _buildStatChip(
          context: context,
          label: 'Average',
          value: '${widget.currencyPrefix}${average.toStringAsFixed(0)}/day',
          icon: Icons.trending_flat_rounded,
          color: AppColors.textSecondary(b),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context: context,
          label: 'Peak Day',
          value:
              '${widget.currencyPrefix}${widget.values.isEmpty ? 0 : widget.values.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
          icon: Icons.trending_up_rounded,
          color: AppColors.successText(b),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary(
                          Theme.of(context).brightness),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 36,
              color: onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No sales recorded yet',
              style: TextStyle(
                fontSize: 13,
                color: onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
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

  double _gridInterval(double total) {
    if (total <= 0) return 1000;
    final max = widget.values.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return 1000;
    return (max / 3).ceilToDouble();
  }

  double _labelInterval() {
    if (widget.labels.length <= 7) return 1;
    if (widget.labels.length <= 14) return 2;
    return 5;
  }

  String _shortCurrency(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(0)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
