import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final borderColor = Theme.of(context).dividerColor;

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
                            hintText: 'Search product name, barcode or description',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  Text('Tap the icon to open camera scanner',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7))),
                ],
              );
            }),
          ),

          // Category Filter Chips
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, productState) {
              final categories = context.read<CategoryBloc>().state.categories;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'All',
                      selected: productState.selectedCategoryId == null,
                      onSelected: () =>
                          context.read<ProductBloc>().add(const FilterByCategory(null)),
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
                          backgroundColor: Theme.of(context).colorScheme.error),
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
                          product.barcode.toLowerCase().contains(_searchQuery) ||
                          (product.description?.toLowerCase().contains(_searchQuery) ?? false))
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
                      final stockColor = _stockColor(product.stock);
                      return GestureDetector(
                        onTap: () => context.push('/products/detail/${product.id}',
                            extra: product),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: stockColor.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Left accent bar
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: stockColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Image
                              if (product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _placeholderIcon(),
                                  ),
                                )
                              else
                                _placeholderIcon(),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Line 1: Product Name
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Line 2: Price | Stock | Category | Location
                                      Row(
                                        children: [
                                          Text(
                                            '₹${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          _dotSeparator(),
                                          _stockBadge(product.stock),
                                          if (categoryName != null) ...[
                                            _dotSeparator(),
                                            _metaText(categoryName, Icons.category_outlined),
                                          ],
                                          if (product.location != null &&
                                              product.location!.isNotEmpty) ...[
                                            _dotSeparator(),
                                            Flexible(
                                              child: _metaText(
                                                product.location!,
                                                Icons.location_on_outlined,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      // Line 3: Description snippet (only when search matches)
                                      if (_searchQuery.isNotEmpty &&
                                          product.description != null &&
                                          product.description!
                                              .toLowerCase()
                                              .contains(_searchQuery)) ...[
                                        const SizedBox(height: 4),
                                        _buildDescriptionSnippet(
                                            product.description!, _searchQuery),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              // Chevron tap hint
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
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
        foregroundColor: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.inventory_2_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
    );
  }

  Color _stockColor(int stock) {
    if (stock <= 0) return const Color(0xFFEF4444);
    if (stock <= 5) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  Widget _stockBadge(int stock) {
    final color = _stockColor(stock);
    final bg = color.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'Stock: $stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _dotSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _metaText(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDescriptionSnippet(String description, String query) {
    final lowerDesc = description.toLowerCase();
    final index = lowerDesc.indexOf(query);

    // Extract surrounding snippet around matched query
    int start = (index - 10).clamp(0, description.length);
    int end = (index + query.length + 20).clamp(0, description.length);
    String snippet = description.substring(start, end).trim();
    if (start > 0) snippet = '...$snippet';
    if (end < description.length) snippet = '$snippet...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Amber 100 highlight
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.saved_search_rounded,
              size: 12, color: Color(0xFFD97706)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              snippet,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF92400E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
            color: selected ? Theme.of(context).colorScheme.onPrimary : AppTheme.primaryColor,
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

}
