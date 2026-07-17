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
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.menu,
                  size: 24, color: Theme.of(context).primaryColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open menu',
            ),
            IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ],
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Details
            _detailRow(context, 'Barcode', product.barcode,
                icon: Icons.qr_code_rounded),
            const SizedBox(height: 14),
            _detailRow(context, 'Price', '₹${product.price.toStringAsFixed(2)}',
                icon: Icons.currency_rupee_rounded,
                valueColor: AppTheme.primaryColor),
            const SizedBox(height: 14),
            _detailRow(
              context,
              'Stock',
              '${product.stock}',
              icon: Icons.inventory_2_rounded,
              badge: true,
              inStock: product.stock > 0,
            ),
            if (categoryName != null) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'Category', categoryName,
                  icon: Icons.category_rounded),
            ],
            if (product.location != null && product.location!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'Location', product.location!,
                  icon: Icons.location_on_outlined),
            ],
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _descriptionRow(context, product.description!),
            ],
            if (product.createdAt != null) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'Created', _formatDate(product.createdAt!),
                  icon: Icons.calendar_today_rounded),
            ],
            if (product.updatedAt != null) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'Last Updated', _formatDate(product.updatedAt!),
                  icon: Icons.update_rounded),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                        color: Colors.grey[500],
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                    color: Colors.grey[500],
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
                        ? (inStock ? Colors.green[700] : Colors.red)
                        : (valueColor ?? Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              foregroundColor: Colors.white,
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
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
