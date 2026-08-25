import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class QuickActionsState {
  QuickActionsState._();
  static final ValueNotifier<bool> open = ValueNotifier<bool>(false);
}

class QuickActionsPanel {
  QuickActionsPanel._();

  static void show(BuildContext context) {
    HapticFeedback.mediumImpact();
    QuickActionsState.open.value = true;
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: AppDurations.normal,
        pageBuilder: (_, __, ___) => const _QuickActionsScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    )
        .then((_) {
      QuickActionsState.open.value = false;
    });
  }
}

class _QuickActionsScreen extends StatelessWidget {
  const _QuickActionsScreen();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 88,
              bottom: mq.padding.bottom + 76,
              child: ScaleTransition(
                alignment: Alignment.bottomRight,
                scale: CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: AppDurations.spring,
                ),
                child: const _ActionsPanel(),
              ),
            ),
            Positioned(
              right: 16,
              bottom: mq.padding.bottom + 7,
              child: FadeTransition(
                opacity: ModalRoute.of(context)!.animation!,
                child: const _CloseButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOwner =
        context.read<AuthBloc>().state is Authenticated &&
            (context.read<AuthBloc>().state as Authenticated).user.role ==
                'owner';

    final items = <_PanelItem>[
      const _PanelItem(Icons.category_rounded, 'Categories', '/categories'),
      const _PanelItem(Icons.people_outline_rounded, 'Customers', '/customers'),
      const _PanelItem(Icons.payments_outlined, 'Due Pay', '/due-payments'),
      const _PanelItem(Icons.verified_outlined, 'Warranty', '/warranty'),
      const _PanelItem(Icons.broken_image_rounded, 'Damaged', '/damaged-products'),
      const _PanelItem(Icons.store_rounded, 'Shop', '/shop'),
      const _PanelItem(Icons.settings_rounded, 'Settings', '/settings'),
      if (isOwner) const _PanelItem(Icons.people_rounded, 'Staff', '/staff'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withValues(alpha: 0.82)
                : theme.colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.xs,
            childAspectRatio: 0.92,
            children:
                items.map((item) => _PanelTile(item: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _PanelItem {
  final IconData icon;
  final String label;
  final String route;
  const _PanelItem(this.icon, this.label, this.route);
}

class _PanelTile extends StatelessWidget {
  final _PanelItem item;
  const _PanelTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: AppRadius.rLg,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop();
        context.go(item.route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Icon(item.icon, size: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close quick actions',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
          customBorder: const CircleBorder(),
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
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: AppDurations.normal,
                curve: AppDurations.spring,
                builder: (context, t, _) => Transform.rotate(
                  angle: t * 3.14159265 / 4,
                  child: const Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
