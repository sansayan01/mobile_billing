import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/category_bloc.dart';
import '../../domain/entities/category.dart';
import '../../../../core/utils/app_validators.dart';

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

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                ),
                validator: AppValidators.required('Please enter a category name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
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
      ));
    } else {
      bloc.add(AddCategory(
        name: name,
        description: description.isNotEmpty ? description : null,
      ));
    }

    Navigator.pop(context);
  }
}
