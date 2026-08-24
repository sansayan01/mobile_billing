import 'dart:io';
import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/product_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/image_compress.dart';
import '../../../../core/utils/image_upload_service.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _barcodeController;
  late String _name;
  late double _price;
  late int _stock;
  late int _minStockLevel;
  late String _unit;
  late String _location;
  late String _description;
  late String _imageUrl;
  late String? _categoryId;
  late String _warrantyType;
  late int? _warrantyDuration;
  late String? _warrantyUnit;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _barcodeController = TextEditingController(text: widget.product.barcode);
    _price = widget.product.price;
    _stock = widget.product.stock;
    _minStockLevel = widget.product.minStockLevel;
    _unit = widget.product.unit;
    _location = widget.product.location ?? '';
    _description = widget.product.description ?? '';
    _imageUrl = widget.product.imageUrl ?? '';
    _categoryId = widget.product.categoryId;
    _warrantyType = widget.product.warrantyType;
    _warrantyDuration = widget.product.warrantyDuration;
    _warrantyUnit = widget.product.warrantyUnit;
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploading = true;
        });

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

      // Upload compressed image to Supabase Storage if new image picked
      String? uploadedImageUrl = _imageUrl.isNotEmpty ? _imageUrl : null;
      if (_imageFile != null) {
        uploadedImageUrl = await ImageUploadService.uploadProductImage(
          _imageFile!, widget.product.id,
        );
      }

      if (!mounted) return;

      final updatedProduct = widget.product.copyWith(
        name: _name,
        barcode: _barcodeController.text.trim(),
        price: _price,
        stock: _stock,
        categoryId: _categoryId,
        location: _location.isNotEmpty ? _location : null,
        description: _description.isNotEmpty ? _description : null,
        imageUrl: uploadedImageUrl,
        updatedAt: DateTime.now(),
        warrantyType: _warrantyType,
        warrantyDuration: _warrantyDuration,
        warrantyUnit: _warrantyUnit,
        clearWarrantyDuration: _warrantyType == 'none',
        clearWarrantyUnit: _warrantyType == 'none',
        minStockLevel: _minStockLevel,
        unit: _unit,
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
          leading: const AdaptiveAppBarLeading(),
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
                  // Image Picker
                  const InputLabel(text: 'Product Image'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.inventory_2_outlined,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 32,
                                      ),
                                    ),
                                  )
                                : Icon(Icons.inventory_2_outlined,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: 'Scan or enter barcode',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: AppTheme.primaryColor),
                        onPressed: () async {
                          final scanned = await context.push<String>('/scan/scanner');
                          if (scanned != null && mounted) {
                            _barcodeController.text = scanned;
                          }
                        },
                        tooltip: 'Scan barcode',
                      ),
                    ),
                    validator: AppValidators.required('Please enter a barcode'),
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
                    decoration: InputDecoration(
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
                            const InputLabel(text: 'Unit'),
                            DropdownButtonFormField<String>(
                              initialValue: _unit,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'pcs', child: Text('Pieces')),
                                DropdownMenuItem(value: 'box', child: Text('Box')),
                                DropdownMenuItem(value: 'pack', child: Text('Pack')),
                                DropdownMenuItem(value: 'kg', child: Text('Kg')),
                                DropdownMenuItem(value: 'meter', child: Text('Meter')),
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
                    initialValue: _minStockLevel.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '5',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      suffixText: 'units',
                    ),
                    onSaved: (value) => _minStockLevel = int.tryParse(value ?? '') ?? 5,
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
                    initialValue: _location,
                    decoration: const InputDecoration(
                      hintText: 'e.g. A-12',
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
                            DropdownMenuItem(value: 'none', child: Text('No Warranty')),
                            DropdownMenuItem(value: 'warranty', child: Text('Warranty')),
                            DropdownMenuItem(value: 'guarantee', child: Text('Guarantee')),
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
                            initialValue: _warrantyDuration?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Duration',
                            ),
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
                              DropdownMenuItem(value: 'days', child: Text('Days')),
                              DropdownMenuItem(value: 'months', child: Text('Months')),
                              DropdownMenuItem(value: 'years', child: Text('Years')),
                            ],
                            onChanged: (val) {
                              setState(() => _warrantyUnit = val);
                            },
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
            icon: Icons.save,
            label: _isUploading ? 'Uploading...' : 'Save Changes',
          ),
        ));
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

    if (selected != null && mounted) {
      setState(() => _categoryId = selected);
    }
  }
}
