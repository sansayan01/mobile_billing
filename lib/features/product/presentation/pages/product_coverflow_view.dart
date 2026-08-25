import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Spotlight Cover-flow view — a 3D product carousel with a category dial.
class ProductCoverflowView extends StatefulWidget {
  final List<Product> products;
  final Map<String, String> categoryNames;
  final void Function(Product) onDetail;
  final void Function(Product) onEdit;
  final void Function(Product) onQr;

  const ProductCoverflowView({
    super.key,
    required this.products,
    required this.categoryNames,
    required this.onDetail,
    required this.onEdit,
    required this.onQr,
  });

  @override
  State<ProductCoverflowView> createState() => _ProductCoverflowViewState();
}

class _ProductCoverflowViewState extends State<ProductCoverflowView> {
  final PageController _pageController =
      PageController(viewportFraction: 0.72);
  final Map<String, GlobalKey> _dialKeys = {};
  final GlobalKey _allDialKey = GlobalKey();
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant ProductCoverflowView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFirst =
        oldWidget.products.isEmpty ? null : oldWidget.products.first.id;
    final newFirst =
        widget.products.isEmpty ? null : widget.products.first.id;
    if (oldFirst != newFirst) {
      _currentIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectCategory(String? id) {
    HapticFeedback.selectionClick();
    context.read<ProductBloc>().add(FilterByCategory(id));
    _currentIndex = 0;
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = (id == null ? _allDialKey : _dialKeys[id])?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Empty list pe clamp(0, -1) ArgumentError throw karta — guard karo.
    final safeIndex = widget.products.isEmpty
        ? 0
        : _currentIndex.clamp(0, widget.products.length - 1);

    return Column(
      children: [
        _buildDial(context),
        const SizedBox(height: 6),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
                    return _CoverFlowItem(
                      controller: _pageController,
                      index: index,
                      child: _CoverCard(
                        product: product,
                        categoryName:
                            widget.categoryNames[product.categoryId],
                        isCenter: index == safeIndex,
                        onTap: () => widget.onDetail(product),
                        onEdit: () => widget.onEdit(product),
                        onQr: () => widget.onQr(product),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _bottomPanel(context, widget.products.length, safeIndex),
      ],
    );
  }

  Widget _buildDial(BuildContext context) {
    final categories = context.watch<CategoryBloc>().state.categories;
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final total = state.products.length;
        return SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _dialItem(
                key: _allDialKey,
                label: 'All',
                icon: Icons.grid_view_rounded,
                count: total,
                selected: state.selectedCategoryId == null,
                onTap: () => _selectCategory(null),
              ),
              for (final category in categories)
                _dialItem(
                  key: _dialKeys.putIfAbsent(category.id, GlobalKey.new),
                  label: category.name,
                  icon: Icons.category_rounded,
                  count: state.products
                      .where((p) => p.categoryId == category.id)
                      .length,
                  selected: state.selectedCategoryId == category.id,
                  onTap: () => _selectCategory(category.id),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialItem({
    required Key key,
    required String label,
    required IconData icon,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : Theme.of(context).dividerColor,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppColors.onAccent : AppColors.accentText(Theme.of(context).brightness),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.onAccent
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.onAccent.withValues(alpha: 0.18)
                      : AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.onAccent : AppColors.accentText(Theme.of(context).brightness),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomPanel(BuildContext context, int total, int current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (total <= 12)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < total; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: i == current ? 22 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == current
                          ? AppColors.accent
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            )
          else
            const SizedBox(height: 7),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_rounded,
                  size: 14, color: AppColors.accentText(Theme.of(context).brightness)),
              const SizedBox(width: 6),
              Text(
                '${current + 1} of $total  ·  Swipe to browse',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cover-flow 3D motion ──────────────────────────────────────────────────

class _CoverFlowItem extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const _CoverFlowItem({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients
            ? (controller.page ?? controller.initialPage.toDouble())
            : controller.initialPage.toDouble();
        final offset = (page - index).abs().clamp(0.0, 1.0);
        final angle = offset * 0.72;
        final scale = 1 - offset * 0.16;

        return Opacity(
          opacity: (1 - offset * 0.35).clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateY(angle)
              ..scaleByDouble(scale, scale, scale, 1),
            child: child,
          ),
        );
      },
    );
  }
}

// ── Cover card ────────────────────────────────────────────────────────────

class _CoverCard extends StatelessWidget {
  final Product product;
  final String? categoryName;
  final bool isCenter;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onQr;

  const _CoverCard({
    required this.product,
    required this.categoryName,
    required this.isCenter,
    required this.onTap,
    required this.onEdit,
    required this.onQr,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = _stockColor(context, product.stock, product.minStockLevel);
    final hasImage =
        product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isCenter
                ? stockColor.withValues(alpha: 0.55)
                : Theme.of(context).dividerColor,
            width: isCenter ? 2 : 1,
          ),
          boxShadow: isCenter
              ? [
                  BoxShadow(
                    color: stockColor.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Hero(
                      tag: 'product-${product.id}',
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest),
                        errorBuilder: (_, __, ___) =>
                            _placeholder(context),
                      ),
                    )
                  else
                    _placeholder(context),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(
                      context,
                      categoryName ?? 'No Category',
                      AppColors.info,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _badge(
                        context, 'Stock: ${product.stock}', stockColor),
                  ),
                  if (product.isLowStock)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        color: AppColors.warning.withValues(alpha: 0.92),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 14, color: AppColors.onAccent),
                            SizedBox(width: 6),
                            Text(
                              'Low stock — reorder soon',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: AppMoneyText.sized(
                          22,
                          FontWeight.w800,
                          AppColors.accentText(Theme.of(context).brightness),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.unit.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (product.barcode.isNotEmpty)
                    Text(
                      product.barcode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          context,
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          color: AppColors.accentText(Theme.of(context).brightness),
                          onTap: onEdit,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(
                          context,
                          icon: Icons.qr_code_2_rounded,
                          label: 'QR Code',
                          color: AppColors.infoText(Theme.of(context).brightness),
                          onTap: onQr,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _actionBtn(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 52,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Color _stockColor(BuildContext context, int stock, int minLevel) {
    final b = Theme.of(context).brightness;
    if (stock <= 0) return AppColors.error(b);
    if (stock <= minLevel) return AppColors.warningText(b);
    return AppColors.successText(b);
  }
}

/// Loading skeleton used by the shell while products load in carousel mode.
class ProductCoverflowSkeleton extends StatefulWidget {
  const ProductCoverflowSkeleton({super.key});

  @override
  State<ProductCoverflowSkeleton> createState() =>
      _ProductCoverflowSkeletonState();
}

class _ProductCoverflowSkeletonState extends State<ProductCoverflowSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface.withValues(alpha: 0.7);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.45, end: 0.95).animate(
                  CurvedAnimation(
                      parent: _controller, curve: Curves.easeInOut)),
              child: Container(
                width: 240,
                height: 340,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}