import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String get _healthLabel {
    if (outOfStockCount >= 5 || lowStockCount >= 5) return 'Critical';
    if (outOfStockCount >= 3 || lowStockCount >= 5) return 'Fair';
    return 'Good';
  }

  Color get _healthColor {
    final label = _healthLabel;
    if (label == 'Good') return const Color(0xFF22C55E);
    if (label == 'Fair') return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
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
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
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
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (onViewDetails != null)
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Text(
                      'View Details',
                      style: GoogleFonts.ibmPlexSans(
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
                    color: _healthColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Health: $_healthLabel',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _healthColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
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
        ),
      ),
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
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
