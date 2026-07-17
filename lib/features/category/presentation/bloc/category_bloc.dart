import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/category/domain/entities/category.dart';
import 'package:billing_app/features/category/domain/usecases/category_usecases.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final AuthBloc authBloc;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.authBloc,
  }) : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  String? get _currentShopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await getCategoriesUseCase(NoParams(),
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, message: failure.message)),
      (categories) => emit(
          state.copyWith(status: CategoryStatus.loaded, categories: categories)),
    );
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final category = Category(
      id: const Uuid().v4(),
      name: event.name,
      description: event.description,
    );
    final result = await addCategoryUseCase(category,
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CategoryStatus.success,
            message: 'Category added successfully'));
        add(LoadCategories());
      },
    );
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final category = Category(
      id: event.id,
      name: event.name,
      description: event.description,
    );
    final result = await updateCategoryUseCase(category,
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CategoryStatus.success,
            message: 'Category updated successfully'));
        add(LoadCategories());
      },
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await deleteCategoryUseCase(event.id,
        shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CategoryStatus.success,
            message: 'Category deleted successfully'));
        add(LoadCategories());
      },
    );
  }
}
