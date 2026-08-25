part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;
  final String? description;
  final int iconCodePoint;
  final int colorValue;

  const AddCategory({
    required this.name,
    this.description,
    this.iconCodePoint = 0xe559,
    this.colorValue = 0xFF6750A4,
  });

  @override
  List<Object> get props => [name, description ?? '', iconCodePoint, colorValue];
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final String name;
  final String? description;
  final int iconCodePoint;
  final int colorValue;

  const UpdateCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconCodePoint = 0xe559,
    this.colorValue = 0xFF6750A4,
  });

  @override
  List<Object> get props => [id, name, description ?? '', iconCodePoint, colorValue];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}

/// Multi-select delete — ONE reload + ONE snackbar instead of N of each
/// (dispatching N DeleteCategory events queued N LoadCategories reloads).
class DeleteCategoriesBulk extends CategoryEvent {
  final List<String> ids;

  const DeleteCategoriesBulk(this.ids);

  @override
  List<Object> get props => [ids];
}
