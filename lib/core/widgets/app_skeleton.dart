import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.radius = 6,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class AppSkeletonListTile extends StatelessWidget {
  const AppSkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          AppSkeleton(width: 44, height: 44, radius: 22),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: double.infinity, height: 13, radius: 8),
                SizedBox(height: AppSpacing.sm),
                AppSkeleton(width: 120, height: 11),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          AppSkeleton(width: 56, height: 14, radius: 7),
        ],
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  final int itemCount;

  const AppSkeletonList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppSkeletonListTile(),
    );
  }
}
