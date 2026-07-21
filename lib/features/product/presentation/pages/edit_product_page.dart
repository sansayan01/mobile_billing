import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _barcode;
  late double _price;
  late int _stock;
  late String _location;
  late String _description;
  late String _imageUrl;
  late String? _categoryId;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _barcode = widget.product.barcode;
    _price = widget.product.price;
    _stock = widget.product.stock;
    _location = widget.product.location ?? '';
    _description = widget.product.description ?? '';
    _imageUrl = widget.product.imageUrl ?? '';
    _categoryId = widget.product.categoryId;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = widget.product.copyWith(
        name: _name,
        barcode: _barcode,
        price: _price,
        stock: _stock,
        categoryId: _categoryId,
        location: _location.isNotEmpty ? _location : null,
        description: _description.isNotEmpty ? _description : null,
        imageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu,
                size: 24, color: Theme.of(context).primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open menu',
          ),
          title: const Text('Edit Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Product Name'),

                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Please enter a name'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Barcode'),

                  TextFormField(
                    initialValue: _barcode,
                    decoration: InputDecoration(
                      hintText: 'Scan or enter barcode',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: AppTheme.primaryColor),
                        onPressed: () async {
                          final scanned = await context.push<String>('/scan/scanner');
                          if (scanned != null && mounted) {
                            setState(() => _barcode = scanned);
                          }
                        },
                        tooltip: 'Scan barcode',
                      ),
                    ),
                    validator: AppValidators.required('Please enter a barcode'),
                    onSaved: (value) => _barcode = value!,
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Category'),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      final cats = state.categories;
                      final selectedName = _categoryId == null
                          ? null
                          : cats.firstWhere((c) => c.id == _categoryId).name;
                      return TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: selectedName ?? '')
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: (selectedName ?? '').length)),
                        decoration: const InputDecoration(
                          hintText: 'Select category',
                          prefixIcon: Icon(Icons.category_outlined),
                          suffixIcon: Icon(Icons.search_rounded),
                        ),
                        onTap: () => _showCategoryPicker(context, cats),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Price'),

                  TextFormField(
                    initialValue: _price.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    validator: AppValidators.price,
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Stock Quantity'),
                            TextFormField(
                              initialValue: _stock.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: AppValidators.required('Please enter stock'),
                              onSaved: (value) => _stock = int.tryParse(value!) ?? 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Location'),
                            TextFormField(
                              initialValue: _location,
                              decoration: const InputDecoration(
                                hintText: 'e.g. A-12',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              onSaved: (value) => _location = value?.trim() ?? '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Description'),

                  TextFormField(
                    initialValue: _description,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Enter product description',
                      alignLabelWithHint: true,
                    ),
                    onSaved: (value) => _description = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Image URL (Optional)'),

                  TextFormField(
                    initialValue: _imageUrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                    onSaved: (value) => _imageUrl = value?.trim() ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.save,
          label: 'Save Changes',
        ));
  }

  Future<void> _showCategoryPicker(
      BuildContext context, List<Category> categories) async {
    final searchController = TextEditingController();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final queryLocal = searchController.text;
            final filtered = queryLocal.isEmpty
                ? categories
                : categories
                    .where((c) =>
                        c.name.toLowerCase().contains(queryLocal.toLowerCase()))
                    .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search category...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                      ),
                      onChanged: (val) {
                        setModalState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No categories found',
                                style: TextStyle(color: Colors.grey[500])),
                          )
                        : ListView.builder(
                            itemCount: filtered.length + 1,
                            itemBuilder: (ctx, i) {
                              if (i == 0) {
                                return InkWell(
                                  onTap: () => context.pop(null),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No Category',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: _categoryId == null
                                            ? AppTheme.primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final cat = filtered[i - 1];
                              final isSelected = _categoryId == cat.id;
                              return InkWell(
                                onTap: () => context.pop(cat.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                            .withValues(alpha: 0.06)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_rounded,
                                            size: 18,
                                            color: AppTheme.primaryColor),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _categoryId = selected);
    }
  }
}
