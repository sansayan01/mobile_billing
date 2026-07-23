import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../category/presentation/bloc/category_bloc.dart';
import '../../presentation/bloc/product_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu,
              size: 24, color: Theme.of(context).primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Open menu',
        ),
        title: const Text('Product Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/products/edit/${product.id}',
                extra: product),
            icon: const Icon(Icons.edit_rounded,
                color: AppTheme.primaryColor, size: 22),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.imageUrl != null &&
                        product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            Center(
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Details
            _detailRow(context, 'Barcode', product.barcode,
                icon: Icons.qr_code_rounded),
            const SizedBox(height: 14),
            _detailRow2(context,
              leftLabel: 'Price',
              leftValue: '₹${product.price.toStringAsFixed(2)}',
              leftIcon: Icons.currency_rupee_rounded,
              leftValueColor: AppTheme.primaryColor,
              rightLabel: 'Stock',
              rightValue: '${product.stock}',
              rightIcon: Icons.inventory_2_rounded,
              rightBadge: true,
              rightInStock: product.stock > 0,
            ),
            if (categoryName != null || (product.location != null && product.location!.isNotEmpty)) ...[
              const SizedBox(height: 14),
              _detailRow2(
                context,
                leftLabel: 'Category',
                leftValue: categoryName ?? '—',
                leftIcon: categoryName != null ? Icons.category_rounded : null,
                rightLabel: 'Location',
                rightValue: product.location != null && product.location!.isNotEmpty
                    ? product.location!
                    : '—',
                rightIcon: product.location != null && product.location!.isNotEmpty
                    ? Icons.location_on_outlined
                    : null,
              ),
            ],
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _descriptionRow(context, product.description!),
            ],
            if (product.createdAt != null || product.updatedAt != null) ...[
              const SizedBox(height: 14),
              _detailRow2(
                context,
                leftLabel: 'Created',
                leftValue: product.createdAt != null
                    ? _formatDate(product.createdAt!)
                    : '—',
                leftIcon: product.createdAt != null
                    ? Icons.calendar_today_rounded
                    : null,
                rightLabel: 'Last Updated',
                rightValue: product.updatedAt != null
                    ? _formatDate(product.updatedAt!)
                    : '—',
                rightIcon: product.updatedAt != null
                    ? Icons.update_rounded
                    : null,
              ),
            ],
            if (product.qrData != null && product.qrData!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'QR Data', product.qrData!,
                  icon: Icons.qr_code_rounded),
            ],
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    label: 'Generate QR',
                    icon: Icons.qr_code_2_rounded,
                    color: Colors.purple,
                    onTap: () => context.push('/products/qr/${product.id}',
                        extra: product),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    context,
                    label: 'Edit Product',
                    icon: Icons.edit_rounded,
                    color: AppTheme.primaryColor,
                    onTap: () => context.push('/products/edit/${product.id}',
                        extra: product),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                context,
                label: 'Delete Product',
                icon: Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                onTap: () => _confirmDelete(context, product),
                outlined: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.inventory_2_outlined,
          color: Colors.grey[400], size: 48),
    );
  }

  Widget _descriptionRow(BuildContext context, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined,
                size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: description));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Description copied!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded,
                          size: 16, color: AppTheme.primaryColor),
                      tooltip: 'Copy description',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value,
      {IconData? icon, Color? valueColor, bool badge = false, bool inStock = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: badge
                        ? (inStock ? Colors.green[700] : Theme.of(context).colorScheme.error)
                        : (valueColor ?? Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow2(BuildContext context,
      {required String leftLabel,
      required String leftValue,
      IconData? leftIcon,
      Color? leftValueColor,
      bool leftBadge = false,
      bool leftInStock = false,
      required String rightLabel,
      required String rightValue,
      IconData? rightIcon,
      Color? rightValueColor,
      bool rightBadge = false,
      bool rightInStock = false}) {
    return Row(
      children: [
        _detailCard(context,
          label: leftLabel,
          value: leftValue,
          icon: leftIcon,
          valueColor: leftValueColor,
          badge: leftBadge,
          inStock: leftInStock,
        ),
        const SizedBox(width: 10),
        _detailCard(context,
          label: rightLabel,
          value: rightValue,
          icon: rightIcon,
          valueColor: rightValueColor,
          badge: rightBadge,
          inStock: rightInStock,
        ),
      ],
    );
  }

  Widget _detailCard(BuildContext context,
      {required String label,
      required String value,
      IconData? icon,
      Color? valueColor,
      bool badge = false,
      bool inStock = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: badge
                          ? (inStock ? Colors.green[700] : Theme.of(context).colorScheme.error)
                          : (valueColor ?? Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
      bool outlined = false}) {
    final button = outlined
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

    return button;
  }

  String? _getCategoryName(BuildContext context) {
    if (product.categoryId == null) return null;
    final categoryState = context.read<CategoryBloc>().state;
    final category = categoryState.categories
        .where((c) => c.id == product.categoryId)
        .firstOrNull;
    return category?.name;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(product.id));
                Navigator.pop(innerContext);
                context.go('/products');
              },
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
