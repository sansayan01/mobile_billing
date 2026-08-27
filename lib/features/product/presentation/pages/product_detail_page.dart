import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../category/presentation/bloc/category_bloc.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../../../stock/presentation/bloc/stock_bloc.dart';
import '../../../stock/domain/entities/stock_adjustment.dart';
import '../../../damaged_products/presentation/pages/mark_damaged_dialog.dart';
import '../../../damaged_products/presentation/bloc/damaged_products_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(context);
    final product = _currentProduct;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AdaptiveAppBarLeading(),
        title: const Text('Product Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/products/edit/${product.id}',
                extra: product),
            icon: Icon(Icons.edit_rounded,
                color: AppColors.accentText(Theme.of(context).brightness), size: 22),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Hero(
                tag: 'product-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest),
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
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
            const SizedBox(height: 8),

            // Unit Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Unit: ${product.unit.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
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
              leftValueColor: AppColors.accentText(Theme.of(context).brightness),
              rightLabel: 'Stock',
              rightValue: '${product.stock} ${product.unit}',
              rightIcon: Icons.inventory_2_rounded,
              rightBadge: true,
              rightInStock: product.stock > 0,
            ),
            const SizedBox(height: 14),

            // Min Stock Level + Stock Status
            _detailRow2(context,
              leftLabel: 'Min Stock Level',
              leftValue: '${product.minStockLevel}',
              leftIcon: Icons.warning_amber_outlined,
              leftValueColor: product.isLowStock ? AppColors.warningText(Theme.of(context).brightness) : null,
              rightLabel: 'Stock Status',
              rightValue: product.isLowStock ? 'LOW STOCK' : 'IN STOCK',
              rightIcon: product.isLowStock
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              rightBadge: true,
              rightInStock: !product.isLowStock,
            ),

            // Stock Adjustment Buttons
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Adjustment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showStockDialog(
                              context, isIncrease: true),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Add Stock'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.successText(Theme.of(context).brightness),
                            side: BorderSide(color: AppColors.successText(Theme.of(context).brightness)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showStockDialog(
                              context, isIncrease: false),
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          label: const Text('Remove Stock'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: product.stock > 0
                          ? () => _showMarkDamagedDialog(context, product)
                          : null,
                      icon: const Icon(Icons.broken_image_rounded, size: 20),
                      label: const Text('Mark as Damaged'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: product.stock > 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (categoryName != null ||
                (product.location != null &&
                    product.location!.isNotEmpty)) ...[
              const SizedBox(height: 14),
              _detailRow2(
                context,
                leftLabel: 'Category',
                leftValue: categoryName ?? '—',
                leftIcon:
                    categoryName != null ? Icons.category_rounded : null,
                rightLabel: 'Location',
                rightValue: product.location != null &&
                        product.location!.isNotEmpty
                    ? product.location!
                    : '—',
                rightIcon: product.location != null &&
                        product.location!.isNotEmpty
                    ? Icons.location_on_outlined
                    : null,
              ),
            ],
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _descriptionRow(context, product.description!),
            ],
            if (product.createdAt != null ||
                product.updatedAt != null) ...[
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
            if (product.hasWarranty) ...[
              const SizedBox(height: 14),
              _detailRow(context, 'Warranty', product.warrantyLabel,
                  icon: Icons.verified_outlined,
                  valueColor: AppColors.infoText(Theme.of(context).brightness)),
            ],
            if (product.qrData != null &&
                product.qrData!.isNotEmpty) ...[
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
                    color: AppColors.infoText(Theme.of(context).brightness),
                    onTap: () => context.push(
                        '/products/qr/${product.id}',
                        extra: product),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    context,
                    label: 'Edit Product',
                    icon: Icons.edit_rounded,
                    color: AppColors.accentText(Theme.of(context).brightness),
                    onTap: () => context.push(
                        '/products/edit/${product.id}',
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

  void _showStockDialog(BuildContext context,
      {required bool isIncrease}) {
    final quantityController = TextEditingController(text: '1');
    StockAdjustmentReason selectedReason =
        isIncrease ? StockAdjustmentReason.restock : StockAdjustmentReason.sale;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isIncrease
                              ? AppColors.successText(Theme.of(context).brightness)
                              : Theme.of(context).colorScheme.error)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncrease
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: isIncrease
                          ? AppColors.successText(Theme.of(context).brightness)
                          : Theme.of(context).colorScheme.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isIncrease ? 'Add Stock' : 'Remove Stock',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Stock
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Stock',
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                        Text('${_currentProduct.stock}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  Text('Quantity',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      prefixIcon: Icon(
                        isIncrease
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        color: isIncrease
                            ? AppColors.successText(Theme.of(context).brightness)
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reason
                  Text('Reason',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<StockAdjustmentReason>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    items: _getReasonItems(isIncrease),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedReason = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Note (optional)
                  Text('Note (Optional)',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      hintText: 'Add a note...',
                      prefixIcon: Icon(Icons.note_outlined),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(quantityController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a valid quantity'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    final change = isIncrease ? qty : -qty;
                    final newStock = _currentProduct.stock + change;

                    if (newStock < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Stock cannot go below zero'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      return;
                    }

                    // INSTANT local update — no delay!
                    setState(() {
                      _currentProduct = _currentProduct.copyWith(stock: newStock);
                    });

                    // DB update in background
                    context.read<StockBloc>().add(AdjustStock(
                          productId: _currentProduct.id,
                          quantityChange: change,
                          reason: selectedReason,
                          note: noteController.text.isNotEmpty
                              ? noteController.text
                              : null,
                        ));

                    // Background reload for list page sync
                    context.read<ProductBloc>().add(LoadProducts());

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isIncrease ? 'Added $qty to stock' : 'Removed $qty from stock',
                          style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncrease
                        ? AppColors.successText(Theme.of(context).brightness)
                        : Theme.of(context).colorScheme.error,
                    foregroundColor:
                        isIncrease && Theme.of(context).brightness == Brightness.dark
                            ? AppColors.onAccent
                            : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
      // Dialog-local controllers ko dialog close hote hi free karo.
    ).then((_) {
      quantityController.dispose();
      noteController.dispose();
    });
  }

  void _showMarkDamagedDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => MarkDamagedDialog(
        productName: product.name,
        currentStock: product.stock,
        onConfirm: (quantity, damageType, notes) {
          // Instant local update
          setState(() {
            _currentProduct = _currentProduct.copyWith(
              stock: _currentProduct.stock - quantity,
            );
          });

          // BLoC event
          context.read<DamagedProductsBloc>().add(
                MarkProductAsDamaged(
                  productId: product.id,
                  quantity: quantity,
                  damageType: damageType,
                  notes: notes,
                ),
              );

          // Reload products list
          context.read<ProductBloc>().add(LoadProducts());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marked $quantity units as damaged'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<StockAdjustmentReason>> _getReasonItems(
      bool isIncrease) {
    if (isIncrease) {
      return const [
        DropdownMenuItem(
            value: StockAdjustmentReason.restock, child: Text('Restock')),
        DropdownMenuItem(
            value: StockAdjustmentReason.return_, child: Text('Customer Return')),
        DropdownMenuItem(
            value: StockAdjustmentReason.found, child: Text('Found')),
        DropdownMenuItem(
            value: StockAdjustmentReason.adjustment,
            child: Text('Adjustment')),
      ];
    } else {
      return const [
        DropdownMenuItem(
            value: StockAdjustmentReason.sale, child: Text('Sale')),
        DropdownMenuItem(
            value: StockAdjustmentReason.damage, child: Text('Damage')),
        DropdownMenuItem(
            value: StockAdjustmentReason.sample, child: Text('Sample')),
        DropdownMenuItem(
            value: StockAdjustmentReason.theft, child: Text('Theft/Loss')),
        DropdownMenuItem(
            value: StockAdjustmentReason.adjustment,
            child: Text('Adjustment')),
      ];
    }
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
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_outlined,
                size: 18, color: AppColors.accentText(Theme.of(context).brightness)),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: description));
                        // Visual feedback only — copied to clipboard
                      },
                      icon: Icon(Icons.copy_rounded,
                          size: 16, color: AppColors.accentText(Theme.of(context).brightness)),
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
      {IconData? icon,
      Color? valueColor,
      bool badge = false,
      bool inStock = false}) {
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
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 18, color: AppColors.accentText(Theme.of(context).brightness)),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
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
                         ? (inStock
                             ? AppColors.successText(Theme.of(context).brightness)
                             : Theme.of(context).colorScheme.error)
                         : (valueColor ??
                             Theme.of(context).colorScheme.onSurface),
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
        _detailCard(
          context,
          label: leftLabel,
          value: leftValue,
          icon: leftIcon,
          valueColor: leftValueColor,
          badge: leftBadge,
          inStock: leftInStock,
        ),
        const SizedBox(width: 10),
        _detailCard(
          context,
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
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.accentText(Theme.of(context).brightness)),
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
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
                          ? (inStock
                              ? AppColors.successText(Theme.of(context).brightness)
                              : Theme.of(context).colorScheme.error)
                          : (valueColor ??
                              Theme.of(context).colorScheme.onSurface),
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
    if (_currentProduct.categoryId == null) return null;
    final categoryState = context.read<CategoryBloc>().state;
    final category = categoryState.categories
        .where((c) => c.id == _currentProduct.categoryId)
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
          content:
              Text('Are you sure you want to delete ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<ProductBloc>()
                    .add(DeleteProduct(product.id));
                Navigator.pop(innerContext);
                context.go('/products');
              },
              child: Text('Delete',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
