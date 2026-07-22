import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A glass-effect card that displays a mini sales trend line chart
/// for the last 7 days using a custom painter — no external chart packages needed.
class SalesTrendCard extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const SalesTrendCard({
    super.key,
    required this.values,
    required this.labels,
  });

  static const Color _primaryColor = Color(0xFF6C63FF);

  bool get _hasData =>
      values.isNotEmpty && values.any((v) => v > 0);

  @override
  Widget build(BuildContext context) {
    final double total = values.fold(0.0, (sum, v) => sum + v);
    final double average = values.isEmpty ? 0 : total / values.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              Text(
                'Weekly Sales Trend',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),

              // ── Chart ──
              if (_hasData)
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SalesTrendPainter(
                      values: values,
                      labels: labels,
                      primaryColor: _primaryColor,
                    ),
                  ),
                )
              else
                _buildPlaceholder(),

              const SizedBox(height: 12),

              // ── Total & Average Row ──
              _buildStatsRow(total, average),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_rounded,
            size: 32,
            color: _primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No data yet',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double total, double average) {
    return Row(
      children: [
        _buildStatChip(
          label: 'Total',
          value: _formatCurrency(total),
          color: _primaryColor,
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          label: 'Avg/day',
          value: _formatCurrency(average),
          color: const Color(0xFF00C9A7),
        ),
      ],
    );
  }

  Widget _buildStatChip({
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
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

/// Custom painter that draws a smooth curved sales trend line
/// with gradient fill, data dots, day labels, and a max-value badge.
class _SalesTrendPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color primaryColor;

  _SalesTrendPainter({
    required this.values,
    required this.labels,
    required this.primaryColor,
  });

  // Padding inside the canvas so dots/labels aren't clipped.
  static const double _leftPad = 24;
  static const double _rightPad = 8;
  static const double _topPad = 20; // room for max-value badge
  static const double _bottomPad = 20; // room for day labels

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double chartW = size.width - _leftPad - _rightPad;
    final double chartH = size.height - _topPad - _bottomPad;

    final double maxVal =
        values.reduce((a, b) => a > b ? a : b);
    final double minVal =
        values.reduce((a, b) => a < b ? a : b);
    // Use at least 1 to avoid division by zero when all values are equal.
    final double range = (maxVal - minVal).clamp(1, double.infinity);

    // ── Compute points ──
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = _leftPad + (i / (values.length - 1)) * chartW;
      // Invert Y so higher values are at the top.
      final double y =
          _topPad + chartH - ((values[i] - minVal) / range) * chartH;
      points.add(Offset(x, y));
    }

    // ── Smooth line path (quadratic bezier) ──
    final Path linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final double midX = (prev.dx + curr.dx) / 2;
      linePath.quadraticBezierTo(prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
    }
    // Connect to the last point.
    linePath.lineTo(points.last.dx, points.last.dy);

    // ── Gradient fill below line ──
    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, _topPad + chartH);
    fillPath.lineTo(points.first.dx, _topPad + chartH);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.30),
          primaryColor.withValues(alpha: 0.02),
        ],
      ).createShader(
        Rect.fromLTWH(0, _topPad, size.width, chartH),
      );

    canvas.drawPath(fillPath, fillPaint);

    // ── Line stroke ──
    final Paint linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // ── Dots ──
    final Paint dotFill = Paint()..color = Colors.white;
    final Paint dotBorder = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.5, dotFill);
      canvas.drawCircle(pt, 4.5, dotBorder);
    }

    // ── Day labels ──
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labels.length && i < points.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: GoogleFonts.ibmPlexSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          _topPad + chartH + 4,
        ),
      );
    }

    // ── Max-value badge at the highest point ──
    final int maxIndex = values.indexOf(maxVal);
    final Offset maxPt = points[maxIndex];
    final String maxLabel =
        maxVal >= 1000
            ? '${(maxVal / 1000).toStringAsFixed(1)}K'
            : maxVal.toStringAsFixed(0);

    final TextSpan badgeSpan = TextSpan(
      text: '₹$maxLabel',
      style: GoogleFonts.ibmPlexSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
    );
    final TextPainter badgePainter = TextPainter(
      text: badgeSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw a small pill behind the badge.
    const double badgePadH = 6;
    const double badgePadV = 3;
    const double badgeRadius = 6;
    final Rect badgeRect = Rect.fromLTWH(
      maxPt.dx - badgePainter.width / 2 - badgePadH,
      maxPt.dy - badgePainter.height - badgePadV * 2 - 8,
      badgePainter.width + badgePadH * 2,
      badgePainter.height + badgePadV * 2,
    );
    final RRect badgeRRect = RRect.fromRectAndRadius(
      badgeRect,
      const Radius.circular(badgeRadius),
    );

    canvas.drawRRect(
      badgeRRect,
      Paint()..color = primaryColor.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    badgePainter.paint(
      canvas,
      Offset(
        maxPt.dx - badgePainter.width / 2,
        badgeRect.top + badgePadV,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}
