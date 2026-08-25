import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_theme.dart';
import 'quick_actions_panel.dart';

class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  bool _isActive(String route) =>
      route == '/' ? currentRoute == '/' : currentRoute.startsWith(route);

  void _go(BuildContext context, String route) {
    if (_isActive(route)) return;
    HapticFeedback.selectionClick();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
        child: Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: QuickActionsState.open,
              builder: (context, open, _) => Expanded(
                child: AnimatedOpacity(
                  opacity: open ? 0.0 : 1.0,
                  duration: AppDurations.normal,
                  curve: AppDurations.ease,
                  child: AnimatedScale(
                    scale: open ? 0.92 : 1.0,
                    duration: AppDurations.normal,
                    curve: AppDurations.ease,
                    child: _GlassPill(
                      isDark: isDark,
                      children: [
                        _PillTab(
                          icon: Icons.home_rounded,
                          active: _isActive('/'),
                          tooltip: 'Home',
                          onTap: () => _go(context, '/'),
                        ),
                        _PillTab(
                          icon: Icons.inventory_2_rounded,
                          active: _isActive('/products'),
                          tooltip: 'Products',
                          onTap: () => _go(context, '/products'),
                        ),
                        _PillTab(
                          icon: Icons.qr_code_scanner_rounded,
                          active: _isActive('/scan'),
                          tooltip: 'Billing',
                          onTap: () => _go(context, '/scan'),
                        ),
                        _PillTab(
                          icon: Icons.receipt_long_rounded,
                          active: _isActive('/reports'),
                          tooltip: 'Reports',
                          onTap: () => _go(context, '/reports'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<bool>(
              valueListenable: QuickActionsState.open,
              builder: (context, open, _) => Semantics(
                button: true,
                label: 'Quick actions',
                child: GestureDetector(
                  onTap: () => QuickActionsPanel.show(context),
                  child: Hero(
                    tag: 'quick-actions-toggle',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent,
                            AppColors.accentDark,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent
                                .withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _GlassPill({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withValues(alpha: 0.78)
                : theme.colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _PillTab({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      selected: active,
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            curve: AppDurations.ease,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
        ),
      ),
    );
  }
}
