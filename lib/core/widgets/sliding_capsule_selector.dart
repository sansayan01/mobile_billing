import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';

/// A premium segmented pill selector with an animated sliding capsule background.
///
/// Unlike standard segmented buttons that abruptly toggle colors,
/// [SlidingCapsuleSelector] physically slides a glowing capsule pill across
/// the options with easeOut spring physics, haptics, and reduce-motion obedience.
class SlidingCapsuleSelector extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const SlidingCapsuleSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 30,
    this.fontSize = 11,
    this.padding = const EdgeInsets.all(2.5),
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    final accent = AppColors.accentText(b);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemWidth = totalWidth / items.length;
          final clampedIndex = selectedIndex.clamp(0, items.length - 1);

          return Stack(
            children: [
              // ── Sliding Capsule Indicator ──
              AnimatedPositioned(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: clampedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accent.withValues(alpha: 0.22)
                        : AppColors.accent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.45),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Interactive Labels ──
              Row(
                children: List.generate(items.length, (i) {
                  final isSelected = i == clampedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i != selectedIndex) {
                          HapticFeedback.selectionClick();
                          onSelected(i);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? accent
                                : AppColors.textTertiary(b),
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontFamily,
                          ),
                          child: Text(
                            items[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
