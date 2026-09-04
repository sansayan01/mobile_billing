import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Premium success overlay — lime circle draws in, checkmark strokes across,
/// soft radial burst fades. Auto-dismisses after [holdDuration] unless tapped.
///
/// Usage:
/// ```dart
/// await SuccessBurst.show(context, message: 'Bill Saved');
/// // returns when dismissed — safe to navigate after
/// ```
class SuccessBurst extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration holdDuration;

  const SuccessBurst({
    super.key,
    required this.message,
    required this.onDismiss,
    this.holdDuration = const Duration(milliseconds: 1400),
  });

  /// Shows a full-screen success burst and completes when dismissed.
  static Future<void> show(
    BuildContext context, {
    String message = 'Done!',
    Duration holdDuration = const Duration(milliseconds: 1400),
  }) {
    HapticFeedback.mediumImpact();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (_) => SuccessBurst(
        message: message,
        holdDuration: holdDuration,
        onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Timeline (0..1): 0-0.35 circle scale+fade, 0.25-0.55 check draw,
  // 0.4-0.7 burst, 0.75-1.0 card settle.
  late final Animation<double> _circle;
  late final Animation<double> _check;
  late final Animation<double> _burst;
  late final Animation<double> _card;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _circle = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
    );
    _check = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
    );
    _burst = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
    );
    _card = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    );

    _c.forward();
    Future.delayed(widget.holdDuration + const Duration(milliseconds: 900), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Lime circle + checkmark + burst ──
              SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial burst ring
                      if (_burst.value > 0)
                        Container(
                          width: 140 * (1 + _burst.value * 0.6),
                          height: 140 * (1 + _burst.value * 0.6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withValues(
                                  alpha: 0.5 * (1 - _burst.value)),
                              width: 2,
                            ),
                          ),
                        ),
                      // Lime circle (backdrop-filter blur on dialog barrier)
                      ScaleTransition(
                        scale: Tween(begin: 0.4, end: 1.0).animate(_circle),
                        child: FadeTransition(
                          opacity: _circle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter:
                                  ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.35),
                                      blurRadius: 32,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: _CheckPainter(progress: _check.value),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ── Message card ──
              FadeTransition(
                opacity: _card,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(_card),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurfaceElevated
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(
                        Theme.of(context).brightness)),
                    ),
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(
                            Theme.of(context).brightness),
                      ),
                    ),
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

/// Checkmark that strokes itself in as [progress] goes 0→1.
class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.26, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.70)
      ..lineTo(size.width * 0.76, size.height * 0.34);

    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );

    canvas.drawPath(
      partial,
      Paint()
        ..color = AppColors.onAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.progress != progress;
}
