part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, loaded, error, success }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<Category> categories;
  final String? message;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.message,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? message,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, categories, message];
}
