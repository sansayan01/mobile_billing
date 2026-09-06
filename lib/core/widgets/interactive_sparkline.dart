import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:billing_app/core/theme/app_colors.dart';

/// Single day snapshot for the hero sparkline.
class SparkDayData {
  final DateTime date;
  final double total;
  final int billCount;

  const SparkDayData({
    required this.date,
    required this.total,
    this.billCount = 0,
  });
}

/// Interactive, scrubbable sparkline chart.
///
/// Features:
/// - Smooth draw-in bezier path on mount.
/// - Touch & drag (scrubbing) across days with tactile haptic clicks.
/// - Magnetic snapping to data points with a vertical guideline and halo dot.
/// - Floating glass tooltip displaying day, formatted ₹ revenue, and bill count.
/// - Auto-fades when touch is released.
class InteractiveSparkline extends StatefulWidget {
  final List<SparkDayData> days;
  final Color lineColor;
  final Color fillColor;
  final double height;

  const InteractiveSparkline({
    super.key,
    required this.days,
    required this.lineColor,
    required this.fillColor,
    this.height = 64,
  });

  @override
  State<InteractiveSparkline> createState() => _InteractiveSparklineState();
}

class _InteractiveSparklineState extends State<InteractiveSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawCtrl;
  late final Animation<double> _drawAnim;

  int? _selectedIndex;
  Offset? _selectedPoint;
  bool _isScrubbing = false;

  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _drawCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _drawAnim = CurvedAnimation(
      parent: _drawCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      _drawCtrl.value = 1.0;
    } else if (_drawCtrl.value == 0.0) {
      _drawCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(InteractiveSparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      final reduce = MediaQuery.of(context).disableAnimations;
      if (reduce) {
        _drawCtrl.value = 1.0;
      } else {
        _drawCtrl.forward(from: 0.0);
      }
      _selectedIndex = null;
      _selectedPoint = null;
    }
  }

  @override
  void dispose() {
    _drawCtrl.dispose();
    super.dispose();
  }

  void _handleTouch(Offset localPos, double width, double height) {
    if (widget.days.length < 2 || width <= 0) return;

    final step = width / (widget.days.length - 1);
    final rawIndex = (localPos.dx / step).round();
    final index = rawIndex.clamp(0, widget.days.length - 1);

    if (_selectedIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedIndex = index;
        _isScrubbing = true;
      });
    } else if (!_isScrubbing) {
      setState(() => _isScrubbing = true);
    }
  }

  void _handleTouchEnd() {
    // Keep the selection visible briefly then fade smoothly
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isScrubbing = false;
          _selectedIndex = null;
        });
      }
    });
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.length < 2) return const SizedBox.shrink();

    final b = Theme.of(context).brightness;
    final reduce = MediaQuery.of(context).disableAnimations;
    final values = widget.days.map((d) => d.total).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = widget.height;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => _handleTouch(d.localPosition, width, height),
          onHorizontalDragUpdate: (d) => _handleTouch(d.localPosition, width, height),
          onHorizontalDragEnd: (_) => _handleTouchEnd(),
          onHorizontalDragCancel: _handleTouchEnd,
          onTapDown: (d) => _handleTouch(d.localPosition, width, height),
          onTapUp: (_) => _handleTouchEnd(),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Base Sparkline with draw-in animation (or static at full progress)
                if (reduce)
                  CustomPaint(
                    size: Size(width, height),
                    painter: _InteractiveSparklinePainter(
                      values: values,
                      progress: 1.0,
                      color: widget.lineColor,
                      fillColor: widget.fillColor,
                      selectedIndex: _selectedIndex,
                      onPointCalculated: (idx, point) {
                        if (idx == _selectedIndex) {
                          _selectedPoint = point;
                        }
                      },
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _drawAnim,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(width, height),
                        painter: _InteractiveSparklinePainter(
                          values: values,
                          progress: _drawAnim.value,
                          color: widget.lineColor,
                          fillColor: widget.fillColor,
                          selectedIndex: _selectedIndex,
                          onPointCalculated: (idx, point) {
                            if (idx == _selectedIndex) {
                              _selectedPoint = point;
                            }
                          },
                        ),
                      );
                    },
                  ),

                // Floating Magnetic Tooltip
                if (_selectedIndex != null && _selectedPoint != null) ...[
                  _buildFloatingTooltip(width, height, b, reduce),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingTooltip(
      double width, double height, Brightness b, bool reduce) {
    final data = widget.days[_selectedIndex!];
    final dayLabel = _formatDayLabel(data.date);
    final amountText = _inrFormat.format(data.total);

    // Calculate clamped horizontal position so tooltip stays within card bounds
    const tooltipWidth = 140.0;
    final targetLeft = _selectedPoint!.dx - (tooltipWidth / 2);
    final clampedLeft = targetLeft.clamp(4.0, width - tooltipWidth - 4.0);

    return Positioned(
      left: clampedLeft,
      top: -38, // Position above the curve
      child: AnimatedOpacity(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 160),
        opacity: _isScrubbing ? 1.0 : 0.0,
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: b == Brightness.dark
                ? const Color(0xFF1E293B).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.lineColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(b),
                    ),
                  ),
                  if (data.billCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: widget.lineColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${data.billCount} bills',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: widget.lineColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary(b),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveSparklinePainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final Color color;
  final Color fillColor;
  final int? selectedIndex;
  final void Function(int index, Offset point)? onPointCalculated;

  _InteractiveSparklinePainter({
    required this.values,
    required this.progress,
    required this.color,
    required this.fillColor,
    this.selectedIndex,
    this.onPointCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxVal = values.reduce((a, c) => a > c ? a : c);
    final minVal = values.reduce((a, c) => a < c ? a : c);
    final range = (maxVal - minVal).clamp(1, double.infinity);

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final dx = (i / (values.length - 1)) * size.width;
      final dy = size.height - 6 - ((values[i] - minVal) / range) * (size.height - 14);
      final pt = Offset(dx, dy);
      points.add(pt);
      onPointCalculated?.call(i, pt);
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      line.quadraticBezierTo(prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
    }

    // Clip according to entrance animation progress
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    // Draw area fill
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor, fillColor.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw main curve stroke
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();

    // If an item is selected (scrubbing), draw the magnetic guideline & active halo dot
    if (selectedIndex != null && selectedIndex! < points.length) {
      final activePoint = points[selectedIndex!];

      // Vertical guide line
      canvas.drawLine(
        Offset(activePoint.dx, 0),
        Offset(activePoint.dx, size.height),
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );

      // Outer ripple ring
      canvas.drawCircle(
        activePoint,
        7.0,
        Paint()..color = color.withValues(alpha: 0.22),
      );

      // Inner solid point
      canvas.drawCircle(
        activePoint,
        3.8,
        Paint()..color = color,
      );

      // White center core
      canvas.drawCircle(
        activePoint,
        1.8,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveSparklinePainter old) =>
      old.values != values ||
      old.progress != progress ||
      old.selectedIndex != selectedIndex ||
      old.color != color;
}
