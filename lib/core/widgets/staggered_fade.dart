import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';

/// Staggered entrance wrapper — fades + slides a child up with a per-index
/// delay so a column of sections cascades in (skill rule §7: stagger 30–50ms
/// per item, never all-at-once). Uses transform/opacity only (no layout
/// reflow), interruptible because it snaps to final state on tap.
///
/// Controller-free: a single [TweenAnimationBuilder<double>] drives both
/// the fade and the slide via a computed [Interval] (staggerFraction → 1.0).
class StaggeredFade extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration? delay;

  const StaggeredFade({
    super.key,
    required this.index,
    required this.child,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    // Respect Reduce Motion — skill Motion law: spatial motion collapses to fade.
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }
    final stagger = delay ?? Duration(milliseconds: index * 45);
    final total = AppDurations.normal + stagger;
    final staggerFraction = total.inMilliseconds == 0
        ? 0.0
        : stagger.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: total,
      curve: Interval(
        staggerFraction,
        1.0,
        curve: AppDurations.strongEase,
      ),
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }
}
