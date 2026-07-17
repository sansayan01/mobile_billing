import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _barcode = '';
  String _location = '';
  String _description = '';
  String _imageUrl = '';
  double _price = 0.0;
  int _stock = 0;
  String? _categoryId;

  void _scanBarcode() async {
    final result = await context.push<String>('/scan/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == _barcode).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product with barcode "$_barcode" already exists!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
        stock: _stock,
        categoryId: _categoryId,
        location: _location.isNotEmpty ? _location : null,
        description: _description.isNotEmpty ? _description : null,
        imageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
        qrData: _barcode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Add Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Barcode'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          decoration: const InputDecoration(
                            hintText: 'Scan or enter barcode',
                          ),
                          validator:
                              AppValidators.required('Please enter a barcode'),
                          onSaved: (value) => _barcode = value!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Tap the icon to open camera scanner',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4C669A))),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Product Name'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. Basmati Rice',
                    ),
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.00',
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
                    keyboardType: TextInputType.number,
                    initialValue: _stock.toString(),
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
                    decoration: const InputDecoration(
                      hintText: 'e.g. A-12, Rack 3',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    onSaved: (value) => _location = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Description'),
                  TextFormField(
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
          icon: Icons.add_circle,
          label: 'Add Product',
        ));
  }
}
