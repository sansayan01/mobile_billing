import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';
import 'package:billing_app/core/theme/text_styles.dart';

/// Big prominent action card (e.g. "New Bill") — v3 flat surface,
/// hairline border, colored icon chip. No glassmorphism.
class DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppDurations.normal,
      curve: AppDurations.strongEase,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.rXl,
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(b),
              borderRadius: AppRadius.rXl,
              border: Border.all(color: AppColors.border(b), width: 1),
            ),
            child: Row(
              children: [
                // Colored icon chip — squircle (continuous corners)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),
                const SizedBox(width: 16),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.of(context)
                            .actionCardTitle
                            .copyWith(color: AppColors.textPrimary(b)),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: AppTextStyles.of(context).actionCardSubtitle
                              .copyWith(color: AppColors.textTertiary(b)),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textTertiary(b),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact square tile for the quick-actions grid — icon on top,
/// short label below. v3 flat surface + hairline border, colored icon chip.
/// Entrance: fade+slide with per-tile stagger (no overshoot on
/// informational UI — ui-ux-pro-max guidance), wrapped in RepaintBoundary.
///
/// Alive-but-professional motion (counter POS, used all day):
///  • Idle: the icon pod's colored glow gently breathes (~3s, reverse)
///    so the tile reads as "alive", not frozen.
///  • Press: the icon scales down (~0.88) and the tile's outer shadow
///    tightens (sinks) via transform/shadow only — never layout.
/// Both respect OS reduced-motion (render the static mid-state, no tickers).
class QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Duration staggerDelay;
  final Widget? badge;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.staggerDelay = Duration.zero,
    this.badge,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with SingleTickerProviderStateMixin {
  // Idle glow breathe — gently oscillates the icon pod's colored shadow alpha
  // (slow 3s ease-in-out, reverse). Started in didChangeDependencies so a
  // reduced-motion device never runs the ticker at all.
  late final AnimationController _breatheCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  late final Animation<double> _breathe = Tween<double>(
    begin: 0.10,
    end: 0.20,
  ).animate(CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

  bool _pressed = false;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce != _reduce) {
      _reduce = reduce;
      if (_reduce) {
        _breatheCtrl.stop();
      } else if (!_breatheCtrl.isAnimating) {
        _breatheCtrl.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) => setState(() => _pressed = true);
  void _onPointerUp(PointerUpEvent _) => setState(() => _pressed = false);
  void _onPointerCancel(PointerCancelEvent _) =>
      setState(() => _pressed = false);

  // Icon pod colored glow alpha. Resting baseline matches the original
  // (dark 0.22 / light 0.10); the breathe oscillates ± a small fraction around
  // it and dims ~55% while pressed. Reduced-motion holds the resting baseline.
  double _glowAlpha(bool isDark) {
    const baseline = 0.10;
    const darkBaseline = 0.22;
    final base = _reduce ? 0.0 : (_breathe.value - 0.10);
    final alpha = (isDark ? darkBaseline : baseline) + base * (isDark ? 1.2 : 1.0);
    return _pressed ? alpha * 0.45 : alpha;
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    final reduce = _reduce;

    // Outer tile shadow tightens on press so the tile feels like it sinks.
    // Reduced-motion: hold the resting shadow — no press animation.
    final pressed = _pressed && !reduce;
    final outerShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
        blurRadius: pressed ? 8 : 12,
        offset: Offset(0, pressed ? 2 : 4),
      ),
    ];

    return RepaintBoundary(
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: AppDurations.normal + widget.staggerDelay,
          curve: Interval(
            widget.staggerDelay.inMilliseconds /
                (AppDurations.normal.inMilliseconds +
                    widget.staggerDelay.inMilliseconds),
            1.0,
            curve: AppDurations.strongEase,
          ),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              borderRadius: BorderRadius.circular(18),
              splashColor: widget.color.withValues(alpha: 0.18),
              highlightColor: widget.color.withValues(alpha: 0.06),
              child: AnimatedContainer(
                duration: _pressed
                    ? const Duration(milliseconds: 120)
                    : const Duration(milliseconds: 200),
                curve: _pressed ? Curves.easeOut : AppDurations.spring,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF141926),
                            const Color(0xFF090D15),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF1F5F9),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? (widget.color == AppColors.accent
                            ? widget.color.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.08))
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                  boxShadow: reduce
                      ? const [
                          BoxShadow(
                            color: Color(0x00000000),
                            blurRadius: 0,
                            offset: Offset.zero,
                          ),
                        ]
                      : outerShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Signature Midnight Lime Icon Pod
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _breatheCtrl,
                          builder: (context, _) {
                            return Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          widget.color
                                              .withValues(alpha: 0.18),
                                          widget.color
                                              .withValues(alpha: 0.05),
                                        ]
                                      : [
                                          widget.color
                                              .withValues(alpha: 0.14),
                                          widget.color
                                              .withValues(alpha: 0.04),
                                        ],
                                ),
                                border: Border.all(
                                  color: widget.color
                                      .withValues(alpha: isDark ? 0.35 : 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withValues(
                                      alpha: _glowAlpha(isDark),
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: -2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedScale(
                                  scale: reduce ? 1.0 : (_pressed ? 0.88 : 1.0),
                                  duration: _pressed
                                      ? const Duration(milliseconds: 120)
                                      : const Duration(milliseconds: 200),
                                  curve: _pressed
                                      ? Curves.easeOut
                                      : AppDurations.spring,
                                  child: Icon(widget.icon,
                                      size: 21, color: widget.color),
                                ),
                              ),
                            );
                          },
                        ),
                        if (widget.badge != null)
                          Positioned(
                            top: -5,
                            right: -7,
                            child: widget.badge!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    // Punchy high-contrast label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
