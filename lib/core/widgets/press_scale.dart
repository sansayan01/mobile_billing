import 'package:flutter/material.dart';

import 'package:billing_app/core/theme/app_dimensions.dart';

/// Tap/press scale feedback — the Flutter-native equivalent of Framer Motion's
/// `whileTap`. Wraps any widget and scales it down slightly on pointer-down,
/// springing back on release.
///
/// Uses [Listener] (not [GestureDetector.onTap]) so it observes the press
/// without stealing the tap from an inner [InkWell] — ripple + action stay
/// intact. Respects OS reduced-motion (skill §7: reduced-motion).
class PressScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;
  final Duration duration;
  final Curve curve;

  const PressScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.duration = AppDurations.fast,
    this.curve = AppDurations.strongEase,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: reduce ? 1.0 : (_pressed ? widget.pressedScale : 1.0),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
