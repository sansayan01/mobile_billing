import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class PaymentDonutChart extends StatefulWidget {
  final Map<String, double> paymentTotals;
  final Map<String, int>? paymentCounts;

  const PaymentDonutChart({
    super.key,
    required this.paymentTotals,
    this.paymentCounts,
  });

  @override
  State<PaymentDonutChart> createState() => _PaymentDonutChartState();
}

class _PaymentDonutChartState extends State<PaymentDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final b = theme.brightness;
    final entries = widget.paymentTotals.entries.toList();

    if (entries.isEmpty) {
      return _glass(
        context,
        isDark,
        child: const _EmptyState(
          icon: Icons.pie_chart_rounded,
          text: 'No payment data yet',
        ),
      );
    }

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    final activeEntry = (_touchedIndex >= 0 && _touchedIndex < entries.length)
        ? entries[_touchedIndex]
        : null;

    return _glass(
      context,
      isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Methods', style: AppTextStyles.of(context).trendTitle),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    activeEntry != null
                        ? '${activeEntry.key.toUpperCase()}: ${_fmt(activeEntry.value)}'
                        : _fmt(total),
                    key: ValueKey(activeEntry?.key ?? 'total'),
                    style: AppTextStyles.of(context).trendChipValue.copyWith(
                          color: activeEntry != null
                              ? _methodColor(activeEntry.key, b)
                              : AppColors.accentText(b),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  final newIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                  if (_touchedIndex != newIndex && newIndex >= 0) {
                                    HapticFeedback.selectionClick();
                                  }
                                  _touchedIndex = newIndex;
                                });
                              },
                            ),
                            sectionsSpace: 3,
                            centerSpaceRadius: 28,
                            startDegreeOffset: -90,
                            sections: entries.asMap().entries.map((mapEntry) {
                              final index = mapEntry.key;
                              final entry = mapEntry.value;
                              final isTouched = index == _touchedIndex;
                              final pct = total > 0 ? (entry.value / total) : 0.0;
                              final radius = isTouched ? 66.0 : 58.0;

                              return PieChartSectionData(
                                value: entry.value,
                                title: isTouched
                                    ? '${(pct * 100).toStringAsFixed(0)}%'
                                    : '${(pct * 100).toInt()}%',
                                titleStyle: TextStyle(
                                  fontSize: isTouched ? 12 : 11,
                                  fontWeight: FontWeight.w800,
                                  color: _darkText(_methodColor(entry.key, b)),
                                ),
                                radius: radius,
                                color: _methodColor(entry.key, b),
                                badgePositionPercentageOffset: 0.98,
                              );
                            }).toList(),
                          ),
                          duration: MediaQuery.of(context).disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                        ),
                        // Center active badge inside donut hole
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: activeEntry != null
                              ? Container(
                                  key: ValueKey(activeEntry.key),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _methodColor(activeEntry.key, b)
                                        .withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _methodIcon(activeEntry.key),
                                      size: 18,
                                      color: _methodColor(activeEntry.key, b),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('empty-center')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: entries.asMap().entries.map((mapEntry) {
                      final index = mapEntry.key;
                      final entry = mapEntry.value;
                      final isSelected = index == _touchedIndex;
                      final count = widget.paymentCounts != null &&
                              widget.paymentCounts!.containsKey(entry.key)
                          ? widget.paymentCounts![entry.key]
                          : null;
                      final color = _methodColor(entry.key, b);

                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _touchedIndex = (_touchedIndex == index) ? -1 : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: isDark ? 0.16 : 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? color.withValues(alpha: 0.35)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected ? color : onSurface,
                                      ),
                                    ),
                                    if (count != null)
                                      Text(
                                        '$count bill${count != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                _fmt(entry.value),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? color : onSurface,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _methodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('upi')) return Icons.qr_code_2_rounded;
    if (m.contains('cash')) return Icons.payments_rounded;
    if (m.contains('card')) return Icons.credit_card_rounded;
    if (m.contains('credit')) return Icons.account_balance_wallet_rounded;
    return Icons.receipt_rounded;
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

