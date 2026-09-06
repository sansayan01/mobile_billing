import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A live pulsing indicator with an expanding sonar ripple wave.
/// Displays a green dot with concentric ripples + "Live" text.
class LivePulseBadge extends StatefulWidget {
  final String label;
  final Color activeColor;

  const LivePulseBadge({
    super.key,
    this.label = 'Live',
    this.activeColor = const Color(0xFF22C55E), // Emerald Green
  });

  @override
  State<LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<LivePulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      if (_ctrl.isAnimating) _ctrl.stop();
    } else {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final reduce = MediaQuery.of(context).disableAnimations;

    Widget coreDot() => Container(
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.activeColor,
        boxShadow: [
          BoxShadow(
            color: widget.activeColor.withValues(alpha: 0.8),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );

    return Tooltip(
      message: 'Cloud Sync Healthy • Connected',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cloud_done_rounded,
                      size: 18, color: widget.activeColor),
                  const SizedBox(width: 8),
                  const Text('Live Sync: Connected to Supabase Realtime'),
                ],
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: widget.activeColor
                .withValues(alpha: b == Brightness.dark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.activeColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: reduce
                    ? Center(child: coreDot())
                    : AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, _) {
                          final t = _ctrl.value;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Expanding ripple wave
                              Transform.scale(
                                scale: 1.0 + (t * 1.6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.activeColor.withValues(
                                      alpha: (1.0 - t).clamp(0.0, 0.7),
                                    ),
                                  ),
                                ),
                              ),
                              // Core solid dot
                              coreDot(),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: widget.activeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
