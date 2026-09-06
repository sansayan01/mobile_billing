import 'package:flutter/material.dart';

import 'package:billing_app/core/theme/app_dimensions.dart';

/// Crossfade + slide swap — the Flutter-native equivalent of Framer Motion's
/// `AnimatePresence`. Swaps [child] whenever its [key] changes with a smooth
/// fade and upward slide, no layout jolt (skill §7: layout-shift-avoid).
///
/// Pair with a [ValueKey] built from the active state so Flutter knows a
/// transition is required.
class AnimatedSwap extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedSwap({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) return child;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppDurations.ease,
      switchOutCurve: AppDurations.ease,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
