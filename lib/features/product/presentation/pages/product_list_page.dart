import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// ignore_for_file: prefer_const_constructors
import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanQR(List<Product> products) async {
    final barcode = await context.push<String>('/scan/scanner');
    if (barcode != null && barcode.isNotEmpty) {
      final matchedProduct =
          products.where((p) => p.barcode == barcode).firstOrNull;
      if (matchedProduct != null) {
        _searchController.text = matchedProduct.name;
      } else {
        _searchController.text =
            barcode; // If not found, just put barcode in search
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey[100]!;

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
        title: const Text('Product Management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Scan or enter barcode',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[400],
                            ),
                          ),
                          validator:
                              AppValidators.required('Please enter a barcode'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: () => _scanQR(state.products),
                          padding: const EdgeInsets.all(15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Tap the icon to open camera scanner',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4C669A))),
                ],
              );
            }),
          ),

          // Category Filter Chips
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              return BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  final categories = categoryState.categories;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: productState.selectedCategoryId == null,
                          onSelected: () =>
                              context.read<ProductBloc>().add(FilterByCategory(null)),
                        ),
                        const SizedBox(width: 8),
                        ...categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _filterChip(
                              label: category.name,
                              selected: productState.selectedCategoryId == category.id,
                              onSelected: () => context
                                  .read<ProductBloc>()
                                  .add(FilterByCategory(category.id)),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state.status == ProductStatus.success &&
                      state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message!),
                          backgroundColor: Colors.green),
                    );
                  } else if (state.status == ProductStatus.error &&
                      state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message!),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == ProductStatus.loading &&
                      state.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.products.isEmpty) {
                    if (state.status == ProductStatus.error) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(
                        child: Text('No products found. Add some!'));
                  }

                  final sourceList = state.filteredProducts.isNotEmpty
                      ? state.filteredProducts
                      : state.products;

                  final filteredProducts = sourceList
                      .where((product) =>
                          product.name.toLowerCase().contains(_searchQuery) ||
                          product.barcode.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                        child: Text('No products match your search.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 100),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final categoryName = _getCategoryName(context, product);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Product image or placeholder
                            if (product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderIcon(),
                                ),
                              )
                            else
                              _placeholderIcon(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.primaryColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              (product.stock > 0 ? Colors.green : Colors.red)
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Stock: ${product.stock}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: product.stock > 0
                                                ? Colors.green[700]
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (categoryName != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (product.location != null &&
                                      product.location!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 12, color: Colors.grey[500]),
                                        const SizedBox(width: 2),
                                        Text(
                                          product.location!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // QR Code icon
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.qr_code_2_rounded,
                                        color: Colors.purple, size: 20),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () {
                                      context.push(
                                          '/products/qr/${product.id}',
                                          extra: product);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_rounded,
                                        color: AppTheme.primaryColor, size: 20),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () {
                                      context.push(
                                          '/products/edit/${product.id}',
                                          extra: product);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        color: Colors.red, size: 20),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () =>
                                        _confirmDelete(context, product),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 28),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  String? _getCategoryName(BuildContext context, Product product) {
    if (product.categoryId == null) return null;
    final categoryState = context.read<CategoryBloc>().state;
    final category = categoryState.categories
        .where((c) => c.id == product.categoryId)
        .firstOrNull;
    return category?.name;
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(product.id));
                Navigator.pop(innerContext);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
