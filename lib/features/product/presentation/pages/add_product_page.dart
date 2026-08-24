import 'dart:io';
import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/image_compress.dart';
import '../../../../core/utils/image_upload_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _name = '';
  String _location = '';
  String _description = '';
  String _imageUrl = '';
  double _price = 0.0;
  int _stock = 0;
  int _minStockLevel = 5;
  String _unit = 'pcs';
  String? _categoryId;
  final TextEditingController _categoryController = TextEditingController();
  String _warrantyType = 'none';
  int? _warrantyDuration;
  String? _warrantyUnit;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final result = await context.push<String>('/scan/scanner');
    if (result != null && result.isNotEmpty) {
      _barcodeController.text = result;
      _checkDuplicate(result);
    }
  }

  void _checkDuplicate(String barcode) {
    final productState = context.read<ProductBloc>().state;
    final existingProduct =
        productState.products.where((p) => p.barcode == barcode).firstOrNull;

    if (existingProduct != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
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
                    color: const Color(0xFFE8850C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: Color(0xFFE8850C), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Product Already Exists',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A product with barcode "$barcode" is already in your inventory.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/products/detail/${existingProduct.id}',
                        extra: existingProduct);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingProduct.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${existingProduct.price.toStringAsFixed(2)}  ·  Stock: ${existingProduct.stock}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Go Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/products/detail/${existingProduct.id}',
                      extra: existingProduct);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8850C),
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Product'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showCategoryPicker(
      BuildContext context, List<Category> categories) async {
    final searchController = TextEditingController();
    const kSheetRadius = Radius.circular(20);
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

            const sheetRadius = BorderRadius.vertical(top: kSheetRadius);
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: sheetRadius,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
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
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          )
                        : ListView.builder(
                            itemCount: filtered.length + 1,
                            itemBuilder: (ctx, i) {
                              if (i == 0) {
                                return InkWell(
                                  onTap: () => context.pop(null),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No Category',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: _categoryId == null
                                            ? AppTheme.primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
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
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
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

    if (mounted) {
      setState(() {
        _categoryId = selected;
        if (selected == null) {
          _categoryController.clear();
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 100, // Original quality, we'll compress later
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploading = true;
        });

        // Compress the image
        final compressedPath = await ImageCompress.compressImage(pickedFile.path);
        final compressedSize = await ImageCompress.getCompressedSizeKB(compressedPath);

        setState(() {
          _imageFile = File(compressedPath);
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image compressed: ${compressedSize.toStringAsFixed(1)} KB'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final barcode = _barcodeController.text;
      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == barcode).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product with barcode "$barcode" already exists!'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final productId = const Uuid().v4();

      // Upload image to Supabase Storage if picked
      String? uploadedImageUrl = _imageUrl.isNotEmpty ? _imageUrl : null;
      if (_imageFile != null) {
        uploadedImageUrl = await ImageUploadService.uploadProductImage(_imageFile!, productId);
      }

      if (!mounted) return;

      final product = Product(
        id: productId,
        name: _name,
        barcode: barcode,
        price: _price,
        stock: _stock,
        categoryId: _categoryId,
        location: _location.isNotEmpty ? _location : null,
        description: _description.isNotEmpty ? _description : null,
        imageUrl: uploadedImageUrl,
        qrData: barcode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        warrantyType: _warrantyType,
        warrantyDuration: _warrantyDuration,
        warrantyUnit: _warrantyUnit,
        minStockLevel: _minStockLevel,
        unit: _unit,
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
          leading: const AdaptiveAppBarLeading(),
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
                  // Image Picker
                  const InputLabel(text: 'Product Image'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Image Preview
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.inventory_2_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('Camera'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library, size: 18),
                                    label: const Text('Gallery'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Images auto-compressed (90%) for storage',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // URL Input (optional)
                  const InputLabel(text: 'Or Image URL (Optional)'),
                  TextFormField(
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                    onSaved: (value) => _imageUrl = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Barcode'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            hintText: 'Scan or enter barcode',
                          ),
                          validator:
                              AppValidators.required('Please enter a barcode'),
                          onChanged: (val) => _checkDuplicate(val),
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
                  Text('Tap the icon to open camera scanner',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7))),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Product Name'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. Apple Phone, Boat Headphone',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Please enter a name'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Category'),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      final cats = state.categories;
                      if (_categoryId != null && cats.isNotEmpty) {
                        final selected = cats
                            .where((c) => c.id == _categoryId)
                            .firstOrNull;
                        if (selected != null) {
                          _categoryController.text = selected.name;
                        }
                      }
                      return TextFormField(
                        readOnly: true,
                        controller: _categoryController,
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
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface),
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
                              keyboardType: TextInputType.number,
                              initialValue: _stock.toString(),
                              decoration: const InputDecoration(
                                hintText: '0',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: AppValidators.required(
                                  'Please enter stock'),
                              onSaved: (value) =>
                                  _stock = int.tryParse(value!) ?? 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Unit'),
                            DropdownButtonFormField<String>(
                              initialValue: _unit,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'pcs', child: Text('Pieces')),
                                DropdownMenuItem(
                                    value: 'box', child: Text('Box')),
                                DropdownMenuItem(
                                    value: 'pack', child: Text('Pack')),
                                DropdownMenuItem(
                                    value: 'kg', child: Text('Kg')),
                                DropdownMenuItem(
                                    value: 'meter', child: Text('Meter')),
                              ],
                              onChanged: (val) {
                                setState(() => _unit = val ?? 'pcs');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Min Stock Level (Reorder Point)'),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: _minStockLevel.toString(),
                    decoration: const InputDecoration(
                      hintText: '5',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      suffixText: 'units',
                    ),
                    onSaved: (value) =>
                        _minStockLevel = int.tryParse(value ?? '') ?? 5,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alert when stock falls below this level',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Location'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. A-12',
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
                  const InputLabel(text: 'Warranty'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _warrantyType,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.verified_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'none',
                                child: Text('No Warranty')),
                            DropdownMenuItem(
                                value: 'warranty',
                                child: Text('Warranty')),
                            DropdownMenuItem(
                                value: 'guarantee',
                                child: Text('Guarantee')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _warrantyType = val ?? 'none';
                              if (_warrantyType == 'none') {
                                _warrantyDuration = null;
                                _warrantyUnit = null;
                              }
                            });
                          },
                        ),
                      ),
                      if (_warrantyType != 'none') ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Duration',
                            ),
                            validator: _warrantyType != 'none'
                                ? (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(val) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  }
                                : null,
                            onSaved: (value) {
                              _warrantyDuration = int.tryParse(value ?? '');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _warrantyUnit,
                            hint: const Text('Unit'),
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'days', child: Text('Days')),
                              DropdownMenuItem(
                                  value: 'months', child: Text('Months')),
                              DropdownMenuItem(
                                  value: 'years', child: Text('Years')),
                            ],
                            onChanged: (val) {
                              setState(() => _warrantyUnit = val);
                            },
                            validator: _warrantyType != 'none'
                                ? (val) =>
                                    val == null ? 'Select unit' : null
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: PrimaryButton(
            onPressed: _isUploading ? null : _submit,
            icon: Icons.add_circle,
            label: _isUploading ? 'Uploading...' : 'Add Product',
          ),
        ));
  }
}
