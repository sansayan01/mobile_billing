import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

enum FeedbackType { success, error, info }

class AppFeedback {
  AppFeedback._();

  static void success(BuildContext context, String message) =>
      _show(context, message, FeedbackType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, FeedbackType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, FeedbackType.info);

  static void _show(
    BuildContext context,
    String message,
    FeedbackType type,
  ) {
    final theme = Theme.of(context);
    final (icon, color) = switch (type) {
      FeedbackType.success => (
          Icons.check_circle_rounded,
          theme.colorScheme.primary,
        ),
      FeedbackType.error => (
          Icons.error_rounded,
          theme.colorScheme.error,
        ),
      FeedbackType.info => (
          Icons.info_rounded,
          theme.colorScheme.onSurfaceVariant,
        ),
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: AppElevation.mid,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          content: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          duration: type == FeedbackType.error
              ? const Duration(seconds: 4)
              : const Duration(seconds: 2),
        ),
      );
  }
}
