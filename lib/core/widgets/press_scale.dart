import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tap/press scale feedback — the Flutter-native equivalent of Framer Motion's
/// `whileTap`. Wraps any widget and scales it down slightly on pointer-down,
/// springing back on release with elastic physics and tactile haptic feedback.
///
/// Uses [Listener] (not [GestureDetector.onTap]) so it observes the press
/// without stealing the tap from an inner [InkWell] — ripple + action stay
/// intact. Respects OS reduced-motion.
class PressScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;
  final Duration pressDuration;
  final Duration releaseDuration;
  final Curve pressCurve;
  final Curve releaseCurve;
  final bool enableHaptic;

  const PressScale({
    super.key,
    required this.child,
    this.pressedScale = 0.96,
    this.pressDuration = const Duration(milliseconds: 90),
    this.releaseDuration = const Duration(milliseconds: 240),
    this.pressCurve = Curves.easeOutQuad,
    this.releaseCurve = Curves.easeOutBack,
    this.enableHaptic = true,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _onPointerDown(PointerDownEvent _) {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    setState(() => _pressed = true);
  }

  void _onPointerUp(PointerUpEvent _) {
    setState(() => _pressed = false);
  }

  void _onPointerCancel(PointerCancelEvent _) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedScale(
        scale: reduce ? 1.0 : (_pressed ? widget.pressedScale : 1.0),
        duration: _pressed ? widget.pressDuration : widget.releaseDuration,
        curve: _pressed ? widget.pressCurve : widget.releaseCurve,
        child: widget.child,
      ),
    );
  }
}
