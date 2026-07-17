import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/category/domain/entities/category.dart';
import 'package:billing_app/features/category/domain/repositories/category_repository.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}

class AddCategoryUseCase implements UseCase<void, Category> {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Category params) {
    return repository.addCategory(params);
  }
}

class UpdateCategoryUseCase implements UseCase<void, Category> {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Category params) {
    return repository.updateCategory(params);
  }
}

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteCategory(params);
  }
}
