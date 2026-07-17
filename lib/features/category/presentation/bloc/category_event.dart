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

  const AddCategory({required this.name, this.description});

  @override
  List<Object> get props => [name, description ?? ''];
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final String name;
  final String? description;

  const UpdateCategory({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object> get props => [id, name, description ?? ''];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}
