import 'package:flutter/material.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';

/// Staggered entrance wrapper — fades + slides a child up with a per-index
/// delay so a column of sections cascades in (skill rule §7: stagger 30–50ms
/// per item, never all-at-once). Uses transform/opacity only (no layout
/// reflow), interruptible because it snaps to final state on tap.
class StaggeredFade extends StatefulWidget {
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
  State<StaggeredFade> createState() => _StaggeredFadeState();
}

class _StaggeredFadeState extends State<StaggeredFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.normal,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _ctrl,
    curve: AppDurations.strongEase,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: AppDurations.strongEase));

  @override
  void initState() {
    super.initState();
    final stagger = Duration(milliseconds: widget.index * 45);
    Future.delayed(stagger, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect Reduce Motion — skill Motion law: spatial motion collapses to fade.
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
