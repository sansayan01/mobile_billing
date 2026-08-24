import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/category_bloc.dart';
import '../../domain/entities/category.dart';
import '../../../../core/utils/app_validators.dart';

// Predefined category icons for phone shop
const List<IconData> _categoryIcons = [
  Icons.headphones_rounded,        // Headphones
  Icons.phone_iphone_rounded,      // Phones
  Icons.cable_rounded,             // Chargers/Cables
  Icons.shield_rounded,            // Cases/Covers
  Icons.screen_lock_portrait_rounded, // Screens
  Icons.speaker_rounded,           // Speakers
  Icons.watch_rounded,             // Watches
  Icons.memory_rounded,            // Memory/Storage
  Icons.devices_other_rounded,     // Other devices
  Icons.build_rounded,             // Accessories
  Icons.laptop_rounded,            // Laptops
  Icons.headset_mic_rounded,       // Headset/Mic
  Icons.keyboard_rounded,          // Keyboard/Mouse
  Icons.battery_charging_full_rounded, // Power Banks
  Icons.wifi_rounded,              // WiFi/Routers
  Icons.camera_alt_rounded,        // Cameras
  Icons.videocam_rounded,          // Video
  Icons.mic_rounded,               // Microphone
  Icons.music_note_rounded,        // Music
  Icons.local_offer_rounded,       // Offers/Deals
  Icons.inventory_2_rounded,       // General
  Icons.category_rounded,          // Category default
];

// Predefined colors for categories
const List<Color> _categoryColors = [
  Color(0xFF6750A4), // Purple
  Color(0xFF0061A4), // Blue
  Color(0xFF006D3C), // Green
  Color(0xFFBA1A1A), // Red
  Color(0xFFE8850C), // Orange
  Color(0xFF006874), // Teal
  Color(0xFF7C4D00), // Brown
  Color(0xFF984061), // Pink
  Color(0xFF3F5AA6), // Indigo
  Color(0xFF006E1C), // Light Green
  Color(0xFF8B5000), // Amber
  Color(0xFF6E5700), // Yellow
  Color(0xFF00695C), // Dark Teal
  Color(0xFF8C4351), // Deep Purple
  Color(0xFF4A6178), // Blue Grey
  Color(0xFF5C5D5F), // Grey
];

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;

  const AddEditCategoryDialog({super.key, this.category});

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late int _selectedIconCodePoint;
  late Color _selectedColor;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    _selectedIconCodePoint = widget.category?.iconCodePoint ?? _categoryIcons[21].codePoint;
    _selectedColor = Color(widget.category?.colorValue ?? _categoryColors[0].toARGB32());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_isEditMode ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Headphones',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: AppValidators.required('Please enter a category name'),
                autofocus: true,
              ),
              const SizedBox(height: 20),

              // Color Picker
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categoryColors.map((color) {
                  final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Icon Picker
              Text(
                'Icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _categoryIcons.map((icon) {
                  final isSelected = _selectedIconCodePoint == icon.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCodePoint = icon.codePoint),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? _selectedColor : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),

              // Preview
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        // ignore: non_const_argument_for_const_parameter
                        IconData(_selectedIconCodePoint, fontFamily: 'MaterialIcons'),
                        color: _selectedColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _nameController.text.isNotEmpty ? _nameController.text : 'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(_isEditMode ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final bloc = context.read<CategoryBloc>();

    if (_isEditMode) {
      bloc.add(UpdateCategory(
        id: widget.category!.id,
        name: name,
        description: description.isNotEmpty ? description : null,
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColor.toARGB32(),
      ));
    } else {
      bloc.add(AddCategory(
        name: name,
        description: description.isNotEmpty ? description : null,
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColor.toARGB32(),
      ));
    }

    Navigator.pop(context);
  }
}
