import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Slowly drifting aurora glow — a breathing radial-gradient halo for dark
/// backgrounds. Loops on a sin-based drift (no snapping), GPU-cheap: only
/// opacity/translate animate inside a RepaintBoundary.
///
/// Keep it behind content with IgnorePointer. Subtle by design — alpha
/// multipliers stay small so text contrast is never harmed.
class AuroraGlow extends StatefulWidget {
  final Color color;
  final double size;
  final Duration period;

  const AuroraGlow({
    super.key,
    required this.color,
    this.size = 520,
    this.period = const Duration(seconds: 10),
  });

  @override
  State<AuroraGlow> createState() => _AuroraGlowState();
}

class _AuroraGlowState extends State<AuroraGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      if (!_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      const breathe = 1.0;
      return RepaintBoundary(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: 0.34 * breathe),
                widget.color.withValues(alpha: 0.12 * breathe),
                widget.color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // Two out-of-phase sine waves = organic drift, never a full loop snap.
          final dx = math.sin(t * 2 * math.pi) * 28;
          final dy = math.cos(t * 2 * math.pi * 0.7) * 18;
          final breathe =
              0.85 + 0.15 * math.sin(t * 2 * math.pi * 0.5 + math.pi / 3);

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.34 * breathe),
                    widget.color.withValues(alpha: 0.12 * breathe),
                    widget.color.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
