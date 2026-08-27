import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/csv_export_import.dart';
import '../../../damaged_products/presentation/pages/mark_damaged_dialog.dart';
import '../../../damaged_products/presentation/bloc/damaged_products_bloc.dart';
import 'product_coverflow_view.dart';

enum SortOption { newest, priceLow, priceHigh, nameAZ, stockLow }

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;
  bool _isCarousel = false;
  bool _lowStockOnly = false;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleView() {
    HapticFeedback.mediumImpact();
    setState(() => _isCarousel = !_isCarousel);
  }

  void _toggleLowStock() {
    HapticFeedback.selectionClick();
    setState(() => _lowStockOnly = !_lowStockOnly);
  }

  void _enterSelection() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }
    });
  }

  void _scanQR(List<Product> products) async {
    final barcode = await context.push<String>('/scan/scanner');
    if (!mounted) return;
    if (barcode != null && barcode.isNotEmpty) {
      final matchedProduct =
          products.where((p) => p.barcode == barcode).firstOrNull;
      _searchController.text = matchedProduct?.name ?? barcode;
    }
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sortOption) {
      case SortOption.newest:
        sorted.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        break;
      case SortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.stockLow:
        sorted.sort((a, b) => a.stock.compareTo(b.stock));
        break;
    }
    return sorted;
  }

  String _sortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.nameAZ:
        return 'Name: A to Z';
      case SortOption.stockLow:
        return 'Stock: Low First';
    }
  }

  void _openDetail(Product product) {
    context.push('/products/detail/${product.id}', extra: product);
  }

  void _showLongPressMenu(Product product) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Product info header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: product.stock > 0
                                       ? AppColors.success.withValues(alpha: 0.12)
                                       : AppColors.error(Theme.of(context).brightness).withValues(alpha: 0.12),
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Text(
                                   'Stock: ${product.stock}',
                                   style: TextStyle(
                                     fontSize: 11,
                                     fontWeight: FontWeight.w600,
                                     color: product.stock > 0 ? AppColors.successText(Theme.of(context).brightness) : AppColors.error(Theme.of(context).brightness),
                                   ),
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
              const SizedBox(height: 12),
              // Action items
              _menuActionTile(
                icon: Icons.edit_rounded,
                iconBg: cs.primaryContainer,
                iconColor: cs.primary,
                label: 'Edit product',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/products/edit/${product.id}', extra: product);
                },
              ),
              _menuActionTile(
                icon: Icons.qr_code_2_rounded,
                iconBg: AppColors.accentSubtle,
                iconColor: AppColors.accentText(Theme.of(context).brightness),
                label: 'Show QR Code',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/products/qr/${product.id}', extra: product);
                },
              ),
              _menuActionTile(
                icon: Icons.copy_rounded,
                iconBg: AppColors.info.withValues(alpha: 0.14),
                iconColor: AppColors.infoText(Theme.of(context).brightness),
                label: 'Copy barcode',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _copyBarcode(product);
                },
              ),
              if (product.stock > 0)
                _menuActionTile(
                  icon: Icons.broken_image_rounded,
                  iconBg: AppColors.warning.withValues(alpha: 0.14),
                  iconColor: AppColors.warningText(Theme.of(context).brightness),
                  label: 'Mark as Damaged',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMarkDamagedDialog(product);
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _menuActionTile(
                  icon: Icons.delete_outline_rounded,
                  iconBg: AppColors.error(Theme.of(context).brightness).withValues(alpha: 0.12),
                  iconColor: AppColors.error(Theme.of(context).brightness),
                  label: 'Delete product',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(product);
                  },
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     label,
                     style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: isDestructive ? AppColors.error(Theme.of(context).brightness) : null,
                     ),
                   ),
                 ),
                 Icon(
                   Icons.chevron_right_rounded,
                   size: 18,
                   color: isDestructive
                       ? AppColors.error(Theme.of(context).brightness).withValues(alpha: 0.5)
                       : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${product.name}" ko permanently delete karna hai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error(Theme.of(context).brightness), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final bloc = context.read<ProductBloc>();
      bloc.add(DeleteProduct(product.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => bloc.add(AddProduct(product)),
          ),
        ),
      );
    }
  }

  void _quickStock(Product product) {
    final controller = TextEditingController(text: '${product.stock}');    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
              // Clear the floating bottom-nav (AppShell) so the sheet
              // doesn't clash with it.
              MediaQuery.of(sheetContext).viewPadding.bottom +
              84,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text('Update stock',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      final v = int.tryParse(controller.text) ?? product.stock;
                      controller.text = '${(v - 1).clamp(0, 99999)}';
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Stock',
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      final v = int.tryParse(controller.text) ?? product.stock;
                      controller.text = '${v + 1}';
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final v = int.tryParse(controller.text);
                    if (v != null && v >= 0) {
                      context
                          .read<ProductBloc>()
                          .add(UpdateProduct(product.copyWith(stock: v)));
                    }
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Save stock'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() => controller.dispose());
  }

  void _addToCart(Product product) {
    context.read<BillingBloc>().add(AddProductToCartEvent(product));
    // Feedback is now the persistent mini-cart bar (bottomNavigationBar),
    // which updates live on add. Removed the floating SnackBar that used to
    // overlap and hide the FAB.
  }

  void _copyBarcode(Product product) {
    Clipboard.setData(ClipboardData(text: product.barcode));
    // Visual feedback only — clipboard mein copied hai
  }

  void _showMarkDamagedDialog(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => MarkDamagedDialog(
        productName: product.name,
        currentStock: product.stock,
        onConfirm: (quantity, damageType, notes) {
          context.read<DamagedProductsBloc>().add(
                MarkProductAsDamaged(
                  productId: product.id,
                  quantity: quantity,
                  damageType: damageType,
                  notes: notes,
                ),
              );
          // Reload products
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

  Future<void> _bulkDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<ProductBloc>();
    final selected = bloc.state.products
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete products?'),
        content: Text(
            '${selected.length} products ko permanently delete karna hai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error(Theme.of(context).brightness), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    for (final p in selected) {
      bloc.add(DeleteProduct(p.id));
    }
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text('${selected.length} products deleted'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            for (final p in selected) {
              bloc.add(AddProduct(p));
            }
          },
        ),
      ),
    );
  }

  Future<void> _bulkExport() async {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<ProductBloc>();
    final selected = bloc.state.products
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    if (selected.isEmpty) return;

    await CsvExportImport.exportProducts(selected);
    if (!mounted) return;
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text('${selected.length} products exported!',
            style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _importFromCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<ProductBloc>();
    final rows = await CsvExportImport.importProducts();
    if (rows.isEmpty || !mounted) return;

    final products = rows
        .map(_productFromCsvMap)
        .where((p) => p.name.isNotEmpty)
        .toList();
    if (products.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No valid products found in CSV'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Single bulk event — ProductBloc reloads ONCE after the whole batch,
    // instead of a LoadProducts storm per row.
    bloc.add(AddProductsBulk(products));
    messenger.showSnackBar(
      SnackBar(
        content: Text('${products.length} products imported!',
            style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Product _productFromCsvMap(Map<String, String> m) {
    final location = m['Location']?.trim() ?? '';
    final description = m['Description']?.trim() ?? '';
    final unit = m['Unit']?.trim() ?? '';
    return Product(
      id: const Uuid().v4(),
      name: m['Name']?.trim() ?? '',
      barcode: m['Barcode']?.trim() ?? '',
      price: double.tryParse(m['Price'] ?? '') ?? 0,
      stock: int.tryParse(m['Stock'] ?? '') ?? 0,
      minStockLevel: int.tryParse(m['Min Stock Level'] ?? '') ?? 5,
      unit: unit.isEmpty ? 'pcs' : unit,
      categoryId: (m['Category ID']?.trim() ?? '').isEmpty
          ? null
          : m['Category ID']!.trim(),
      location: location.isEmpty ? null : location,
      description: description.isEmpty ? null : description,
      warrantyType: m['Warranty Type']?.trim() ?? 'none',
      warrantyDuration: int.tryParse(m['Warranty Duration'] ?? ''),
      warrantyUnit: (m['Warranty Unit']?.trim() ?? '').isEmpty
          ? null
          : m['Warranty Unit']!.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // FAB to add a product quickly. Re-uses the category page's approach:
      // floats ABOVE the AppShell floating bottom-nav (and the mini-cart bar
      // when present) so it never hides behind either. The earlier note about
      // "FAB removed to avoid nav collision" is resolved by _AboveNavFabLocation.
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: 'Add Product',
        onPressed: () => context.push('/products/add'),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
      floatingActionButtonLocation: _AboveNavFabLocation(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.gradientFor(context),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildHeroSearch(context),
                  const SizedBox(height: 2),
                  _buildStatsBar(context),
                  Expanded(
                    child: BlocConsumer<ProductBloc, ProductState>(
                      listener: (context, state) {
                        if (state.status == ProductStatus.error &&
                            state.message != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message!),
                              backgroundColor: Theme.of(context).colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state.status == ProductStatus.loading &&
                            state.products.isEmpty) {
                          return _isCarousel
                              ? const ProductCoverflowSkeleton()
                              : const Center(
                                  child: CircularProgressIndicator());
                        }

                        if (state.products.isEmpty) {
                          if (state.status == ProductStatus.error) {
                            return Center(
                              child: Text(
                                'Error: ${state.message}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }
                          return _EmptyState(
                            onAdd: () => context.push('/products/add'),
                          );
                        }

                        final sourceList =
                            state.filteredProducts.isNotEmpty
                                ? state.filteredProducts
                                : state.products;

                        var filtered = sourceList
                            .where((product) =>
                                product.name
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                product.barcode
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                (product.description
                                        ?.toLowerCase()
                                        .contains(_searchQuery) ??
                                    false) ||
                                (product.location
                                        ?.toLowerCase()
                                        .contains(_searchQuery) ??
                                    false))
                            .where((product) =>
                                !_lowStockOnly || product.isLowStock)
                            .toList();

                        filtered = _sortProducts(filtered);

                        if (filtered.isEmpty) {
                          return _NoMatchState(
                            onClear: () => _searchController.clear(),
                          );
                        }

                        return BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, categoryState) {
                            final categories = categoryState.categories;
                            final categoryNames = {
                              for (final c in categories) c.id: c.name,
                            };

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: _isCarousel
                              ? ProductCoverflowView(
                                  key: const ValueKey('carousel'),
                                  products: filtered,
                                  categoryNames: categoryNames,
                                  onDetail: _openDetail,
                                  onEdit: (p) => context.push(
                                      '/products/edit/${p.id}',
                                      extra: p),
                                  onQr: (p) => context.push(
                                      '/products/qr/${p.id}',
                                      extra: p),
                                )
                              : _ClassicListView(
                                  key: const ValueKey('classic'),
                                  products: filtered,
                                  allProducts: state.products,
                                  categories: categories,
                                  selectedCategoryId:
                                      state.selectedCategoryId,
                                  selectionMode: _selectionMode,
                                  selectedIds: _selectedIds,
                                  onDetail: _openDetail,
                                  onLongPress: _showLongPressMenu,
                                  onQuickStock: _quickStock,
                                  onDelete: _confirmDelete,
                                  onAddToCart: _addToCart,
                                  onToggleSelect: _toggleSelect,
                                  searchQuery: _searchQuery,
                                ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
      // NOTE: page-level FAB removed — AppShell's floating bottom-nav already
      // provides the add action, so a second FAB would collide with it.
      bottomNavigationBar: BlocBuilder<BillingBloc, BillingState>(
        builder: (context, billing) {
          if (billing.cartItems.isEmpty) return const SizedBox.shrink();
          final itemCount = billing.cartItems.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          );
          final total = billing.totalAmount;
          return SafeArea(
            top: false,
            // extendBody injects the floating nav's height as bottom padding —
            // SafeArea consumes it so the cart bar sits exactly ABOVE the nav
            // on any device (fixed 74px margin used to overlap on gesture-bar
            // phones where nav is taller).
            child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accentDark,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
                children: [
                  const Icon(Icons.shopping_cart_rounded,
                      color: AppColors.onAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$itemCount item${itemCount == 1 ? '' : 's'} in cart',
                          style: const TextStyle(
                            color: AppColors.onAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: AppMoneyText.sized(
                            14,
                            FontWeight.w700,
                            AppColors.onAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/scan/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onAccent,
                      foregroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                    ),
                    child: const Text(
                      'View Cart',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
          },
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final products = state.products;
        if (products.isEmpty) return const SizedBox.shrink();
        final total = products.length;
        final out = products.where((p) => p.stock <= 0).length;
        final low = products
            .where((p) => p.stock > 0 && p.isLowStock)
            .length;
        final attention = low + out;
        final active = _lowStockOnly;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggleLowStock,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.warning
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? AppColors.warning
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: active
                            ? AppColors.onAccent
                            : AppColors.warningText(Theme.of(context).brightness),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Low stock ($attention)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.onAccent
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$total total · $low low · $out out',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    if (_selectionMode) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: _exitSelection,
          tooltip: 'Cancel',
        ),
        title: Text('${_selectedIds.length} selected',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _bulkExport,
            icon: Icon(Icons.ios_share_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            tooltip: 'Export selected',
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _bulkDelete,
            icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
            tooltip: 'Delete selected',
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const AdaptiveAppBarLeading(),
      title: const Text('Products',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _enterSelection,
          icon: Icon(Icons.checklist_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          tooltip: 'Select multiple',
        ),
        IconButton(
          onPressed: _toggleView,
          tooltip: _isCarousel
              ? 'Switch to List view'
              : 'Switch to Cover-flow view',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
              child: Icon(
               _isCarousel
                   ? Icons.view_list_rounded
                   : Icons.view_carousel_rounded,
               key: ValueKey(_isCarousel),
               color: _isCarousel
                   ? Theme.of(context).colorScheme.onSurfaceVariant
                   : AppColors.accentText(Theme.of(context).brightness),
             ),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<ProductBloc>().add(LoadProducts());
          },
          icon: Icon(Icons.refresh_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          tooltip: 'Refresh',
        ),
        PopupMenuButton<SortOption>(
          icon: Icon(Icons.sort,
              color: Theme.of(context).colorScheme.onSurface),
          tooltip: 'Sort products',
          onSelected: (option) {
            HapticFeedback.selectionClick();
            setState(() => _sortOption = option);
          },
          itemBuilder: (context) {
            return SortOption.values.map((option) {
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    if (_sortOption == option)
                      Icon(Icons.check,
                          size: 18, color: AppColors.accentText(Theme.of(context).brightness))
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(_sortOptionLabel(option)),
                  ],
                ),
              );
            }).toList();
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface),
          tooltip: 'Export/Import',
          onSelected: (value) async {
            final messenger = ScaffoldMessenger.of(context);
            if (value == 'export') {
              final state = context.read<ProductBloc>().state;
              if (state.products.isNotEmpty) {
                await CsvExportImport.exportProducts(state.products);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Products exported! Check your files.',
                        style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('No products to export',
                        style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else if (value == 'import') {
              await _importFromCsv();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export to CSV'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 18),
                    SizedBox(width: 8),
                    Text('Import from CSV'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildHeroSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border(Theme.of(context).brightness),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded,
                      size: 22, color: AppColors.accentText(Theme.of(context).brightness)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Spotlight search...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => _searchController.clear(),
                      tooltip: 'Clear search',
                    )
                  else
                    const SizedBox(width: 6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () =>
                  _scanQR(context.read<ProductBloc>().state.products),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child:
                    const Icon(Icons.qr_code_scanner, color: AppColors.onAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ── Classic list view (default) ───────────────────────────────────────────

class _ClassicListView extends StatelessWidget {
  final List<Product> products;
  final List<Product> allProducts;
  final List<Category> categories;
  final String? selectedCategoryId;
  final bool selectionMode;
  final Set<String> selectedIds;
  final void Function(Product) onDetail;
  final void Function(Product) onLongPress;
  final void Function(Product) onQuickStock;
  final void Function(Product) onDelete;
  final void Function(Product) onAddToCart;
  final void Function(String) onToggleSelect;
  final String searchQuery;

  const _ClassicListView({
    super.key,
    required this.products,
    required this.allProducts,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectionMode,
    required this.selectedIds,
    required this.onDetail,
    required this.onLongPress,
    required this.onQuickStock,
    required this.onDelete,
    required this.onAddToCart,
    required this.onToggleSelect,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final categoryNames = {
      for (final c in categories) c.id: c.name,
    };

    return Column(
      children: [
        _buildCategoryChips(context),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 104),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final product = products[index];
              final categoryName =
                  categoryNames[product.categoryId] ?? 'No Category';
              return _buildProductTile(context, product, categoryName, searchQuery);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip(
            context,
            label: 'All',
            count: allProducts.length,
            selected: selectedCategoryId == null,
            onTap: () => context
                .read<ProductBloc>()
                .add(const FilterByCategory(null)),
          ),
          for (final category in categories)
            _filterChip(
              context,
              label: category.name,
              count: allProducts
                  .where((p) => p.categoryId == category.id)
                  .length,
              selected: selectedCategoryId == category.id,
              onTap: () => context
                  .read<ProductBloc>()
                  .add(FilterByCategory(category.id)),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context,
      {required String label,
      required int count,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.onAccent
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent,
        checkmarkColor: AppColors.onAccent,
        backgroundColor: Theme.of(context).colorScheme.surface,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected
                ? AppColors.accent
                : Theme.of(context).dividerColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  /// Show a highlighted snippet of the product description when it matches
  /// the active search query (mirrors the dashboard search behaviour).
  Widget _buildDescriptionSnippet(
      BuildContext context, String description, String query) {
    final lowerDesc = description.toLowerCase();
    final index = lowerDesc.indexOf(query);
    if (index < 0) return const SizedBox.shrink();

    int start = (index - 10).clamp(0, description.length);
    int end = (index + query.length + 20).clamp(0, description.length);
    String snippet = description.substring(start, end).trim();
    if (start > 0) snippet = '...$snippet';
    if (end < description.length) snippet = '$snippet...';

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningText(Theme.of(context).brightness).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: AppColors.warningText(Theme.of(context).brightness).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.saved_search_rounded,
              size: 12,
              color: AppColors.warningText(Theme.of(context).brightness)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              snippet,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.warningText(Theme.of(context).brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(
      BuildContext context, Product product, String categoryName, String searchQuery) {
    final stockColor = _stockColor(context, product.stock, product.minStockLevel);
    final outOfStock = product.stock <= 0;
    final isSelected = selectedIds.contains(product.id);

    final card = Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.accent : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => selectionMode
            ? onToggleSelect(product.id)
            : onDetail(product),
        onLongPress: () => selectionMode
            ? onToggleSelect(product.id)
            : onLongPress(product),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: stockColor, width: 4)),
          ),
          padding: const EdgeInsets.all(10),
          child: Opacity(
            opacity: outOfStock ? 0.5 : 1,
            child: Row(
              children: [
                _productImage(context, product),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.accentText(Theme.of(context).brightness),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _stockBadge(context, product.stock, stockColor),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (product.location != null &&
                              product.location!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '·',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                product.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                        ),
                        // Highlight matched description when searching
                        if (searchQuery.isNotEmpty &&
                            product.description != null &&
                            product.description!
                                .toLowerCase()
                                .contains(searchQuery))
                          _buildDescriptionSnippet(
                              context, product.description!, searchQuery),
                      ],
                      ),
                    ),
                    const SizedBox(width: 6),
                selectionMode
                    ? _selectionIndicator(context, isSelected)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('product-tile-${product.id}'),
      direction: selectionMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.onAccent),
            SizedBox(width: 8),
            Text('Stock +',
                style: TextStyle(
                    color: AppColors.onAccent, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_shopping_cart_rounded, color: AppColors.onAccent),
            SizedBox(width: 8),
            Text('Add to Cart',
                style: TextStyle(
                    color: AppColors.onAccent, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onQuickStock(product);
        } else {
          onAddToCart(product);
        }
        return Future.value(false);
      },
      child: card,
    );
  }

  Widget _selectionIndicator(BuildContext context, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.accent : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppColors.accent
              : Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.onAccent)
          : null,
    );
  }

  Widget _productImage(BuildContext context, Product product) {
    final hasImage =
        product.imageUrl != null && product.imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 40,
        height: 40,
        child: hasImage
            ? Image.network(
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
                    _placeholderIcon(context, product),
              )
            : _placeholderIcon(context, product),
      ),
    );
  }

  Widget _placeholderIcon(BuildContext context, Product product) {
    final letter = product.name.isNotEmpty ? product.name[0].toUpperCase() : '?';
    final color = Colors.primaries[
        product.name.hashCode.abs() % Colors.primaries.length];
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _stockBadge(BuildContext context, int stock, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$stock in stock',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

// ── Empty & no-match states ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, v, child) {
              return Transform.scale(
                scale: v,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.accentSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined,
                      size: 46, color: AppColors.accentText(Theme.of(context).brightness)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('No products yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchState extends StatelessWidget {
  final VoidCallback onClear;

  const _NoMatchState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 52,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text('No products match your search',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            'Try a different keyword or clear the filter',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            label: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}

/// Floats the FAB above the AppShell floating bottom-nav.
/// The nav pill is ~72px tall, so 90px lift clears it comfortably on all devices.
class _AboveNavFabLocation extends FloatingActionButtonLocation {
  const _AboveNavFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    const endFloat = FloatingActionButtonLocation.endFloat;
    final base = endFloat.getOffset(geometry);
    // Lift the FAB up so it sits above the floating nav.
    return Offset(base.dx, base.dy - 90);
  }

  @override
  String toString() => 'ProductListPage._AboveNavFabLocation';
}