import 'package:flutter/material.dart';

/// Sweeps a soft, diagonal specular light sheen across a widget at regular
/// intervals, creating a living, premium surface feel (like high-end FinTech cards).
class SheenEffect extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Duration interval;
  final Duration sweepDuration;
  final Color sheenColor;
  final bool enabled;

  const SheenEffect({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.interval = const Duration(seconds: 5),
    this.sweepDuration = const Duration(milliseconds: 1200),
    this.sheenColor = Colors.white,
    this.enabled = true,
  });

  @override
  State<SheenEffect> createState() => _SheenEffectState();
}

class _SheenEffectState extends State<SheenEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _isLoopRunning = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );

    _anim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAnimationState();
  }

  void _checkAnimationState() {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.enabled && !reduce) {
      _startLoop();
    } else {
      _stopLoop();
    }
  }

  void _startLoop() async {
    if (_isLoopRunning) return;
    _isLoopRunning = true;
    while (mounted && widget.enabled) {
      if (!mounted) break;
      final reduce = MediaQuery.of(context).disableAnimations;
      if (reduce || !widget.enabled) break;

      await Future.delayed(widget.interval);
      if (!mounted) break;
      if (MediaQuery.of(context).disableAnimations || !widget.enabled) break;

      await _ctrl.forward(from: 0.0);
    }
    _isLoopRunning = false;
  }

  void _stopLoop() {
    _isLoopRunning = false;
    if (_ctrl.isAnimating) {
      _ctrl.stop();
    }
    _ctrl.value = 0.0;
  }

  @override
  void didUpdateWidget(SheenEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimationState();
  }

  @override
  void dispose() {
    _isLoopRunning = false;
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (!widget.enabled || reduce) {
      return widget.child;
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  if (_ctrl.value <= 0.0 || _ctrl.value >= 1.0) {
                    return const SizedBox.shrink();
                  }

                  // Progress moves from -1.0 to 2.0 to fully sweep across
                  final t = _anim.value;
                  final left = (t * 3.0) - 1.0;

                  return FractionallySizedBox(
                    alignment: Alignment(left, 0),
                    widthFactor: 0.45,
                    heightFactor: 1.5,
                    child: Transform.rotate(
                      angle: 0.35, // ~20 degrees diagonal
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.sheenColor.withValues(alpha: 0.0),
                              widget.sheenColor.withValues(alpha: 0.28),
                              widget.sheenColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
