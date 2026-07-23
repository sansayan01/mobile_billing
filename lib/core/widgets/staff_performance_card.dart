import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';

class StaffPerformanceCard extends StatelessWidget {
  final List<StaffStat> staff;

  const StaffPerformanceCard({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    if (staff.isEmpty) {
      return _buildGlassContainer(
        context: context,
        isDark: isDark,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.people_rounded, size: 36, color: AppTheme.primaryColor),
              SizedBox(height: 12),
              Text('No staff data yet', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final maxRevenue = staff.map((s) => s.revenue).fold(0.0, (a, b) => a > b ? a : b);

    return _buildGlassContainer(
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
                  child: Text('Staff Performance', style: AppTextStyles.of(context).trendTitle),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            ...staff.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              final isTop = idx == 0;
              final barWidth = maxRevenue > 0 ? (s.revenue / maxRevenue) : 0.0;

              return Column(
                children: [
                  if (idx > 0) ...[
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: onSurface.withValues(alpha: 0.06),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isTop
                              ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                              : AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '#${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isTop
                                  ? const Color(0xFFFFB300)
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar circle with initial
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _avatarColor(idx).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _initial(s.name),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _avatarColor(idx),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Name + bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    s.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${_short(s.revenue)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isTop ? const Color(0xFFFFB300) : onSurface,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Progress bar
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: onSurface.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  height: 6,
                                  width: MediaQuery.of(context).size.width * 0.55 * barWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _avatarColor(idx),
                                        _avatarColor(idx).withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _avatarColor(idx).withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${s.billCount} bill${s.billCount != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: onSurface.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 10,
                                  color: onSurface.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
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

  String _initial(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _short(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  // Rotating avatar colors for distinct staff members
  static Color _avatarColor(int index) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF2196F3),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }
}

class StaffStat {
  final String name;
  final int billCount;
  final double revenue;

  const StaffStat(this.name, this.billCount, this.revenue);
}

/// Helper to aggregate bill history by staff member.
class StaffAggregator {
  static List<StaffStat> weeklyPerformance(
    List<dynamic> billHistory, {
    int limit = 5,
  }) {
    final Map<String, StaffStat> map = {};
    for (final bill in billHistory) {
      final name = bill.staffName?.trim() ?? 'Unknown';
      final existing = map[name];
      if (existing != null) {
        map[name] = StaffStat(
          name,
          existing.billCount + 1,
          existing.revenue + bill.grandTotal,
        );
      } else {
        map[name] = StaffStat(name, 1, bill.grandTotal);
      }
    }
    final sorted = map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return sorted.take(limit).toList();
  }
}
