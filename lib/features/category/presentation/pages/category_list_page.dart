import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';
import 'add_edit_category_dialog.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
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

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey[100]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: _searchController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state.status == CategoryStatus.success &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state.status == CategoryStatus.error &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == CategoryStatus.loading &&
                    state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.categories.isEmpty) {
                  if (state.status == CategoryStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredCategories = state.categories
                    .where((category) =>
                        category.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No categories match your search.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 100),
                  itemCount: filteredCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                if (category.description != null &&
                                    category.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    category.description!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                  onPressed: () =>
                                      _openAddEditDialog(category: category),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () =>
                                      _confirmDelete(context, category),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _openAddEditDialog({Category? category}) {
    showDialog(
      context: context,
      builder: (innerContext) => AddEditCategoryDialog(category: category),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content:
              Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<CategoryBloc>()
                    .add(DeleteCategory(category.id));
                Navigator.pop(innerContext);
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
