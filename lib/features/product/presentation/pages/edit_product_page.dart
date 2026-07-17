import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
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
            icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
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
                  // Display Barcode details (immutable block)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BARCODE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.7))),
                            const SizedBox(height: 2),
                            Text(widget.product.barcode,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const InputLabel(text: 'Product Name'),

                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Please enter a name'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Category'),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Select category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        initialValue: _categoryId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('No Category'),
                          ),
                          ...state.categories.map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _categoryId = value;
                          });
                        },
                        onSaved: (value) => _categoryId = value,
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
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Location (Shelf/Rack)'),

                  TextFormField(
                    initialValue: _location,
                    decoration: const InputDecoration(
                      hintText: 'e.g. A-12, Rack 3',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    onSaved: (value) => _location = value?.trim() ?? '',
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
}
