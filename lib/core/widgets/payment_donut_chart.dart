import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class PaymentDonutChart extends StatelessWidget {
  final Map<String, double> paymentTotals;
  final Map<String, int>? paymentCounts;

  const PaymentDonutChart({
    super.key,
    required this.paymentTotals,
    this.paymentCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final b = theme.brightness;
    final entries = paymentTotals.entries.toList();

    if (entries.isEmpty) {
      return _glass(context, isDark, child: const _EmptyState(icon: Icons.pie_chart_rounded, text: 'No payment data yet'));
    }

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    return _glass(context, isDark, child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Methods', style: AppTextStyles.of(context).trendTitle),
              Text(_fmt(total), style: AppTextStyles.of(context).trendChipValue.copyWith(color: AppColors.accentText(b))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 28,
                      startDegreeOffset: -90,
                      sections: entries.map((entry) {
                        final pct = total > 0 ? (entry.value / total) : 0.0;
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${(pct * 100).toInt()}%',
                          titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _darkText(_methodColor(entry.key, b))),
                          radius: 60,
                          color: _methodColor(entry.key, b),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: entries.map((entry) {
                    final count = paymentCounts != null && paymentCounts!.containsKey(entry.key) ? paymentCounts![entry.key] : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: _methodColor(entry.key, b), borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurface)),
                            if (count != null) Text('$count bill${count != 1 ? 's' : ''}', style: TextStyle(fontSize: 10, color: onSurface.withValues(alpha: 0.6))),
                          ])),
                          Text(_fmt(entry.value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onSurface, fontFeatures: const [FontFeature.tabularFigures()])),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _glass(BuildContext context, bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withValues(alpha: 0.70) : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.darkSurface.withValues(alpha: 0.50) : Colors.white.withValues(alpha: 0.35), width: 1),
        boxShadow: [BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  static Color _methodColor(String method, Brightness b) {
    final key = method.trim().toLowerCase();
    if (key.contains('upi')) return AppColors.info;
    if (key.contains('cash')) return AppColors.success;
    if (key.contains('card')) return AppColors.warning;
    if (key.contains('credit')) return AppColors.accentText(b);
    if (key.contains('bank')) return AppColors.error(b);
    return AppColors.textTertiary(b);
  }

  static Color _darkText(Color color) {
    return color.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;
  }

  static String _fmt(double value) {
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Icon(icon, size: 36, color: AppColors.accentText(Theme.of(context).brightness)),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ]),
    );
  }
}

