import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/category/domain/entities/category.dart';
import 'package:billing_app/features/category/domain/repositories/category_repository.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params,
      {String? shopId}) {
    return repository.getCategories(shopId: shopId);
  }
}

class AddCategoryUseCase implements UseCase<void, Category> {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Category params, {String? shopId}) {
    return repository.addCategory(params, shopId: shopId);
  }
}

class UpdateCategoryUseCase implements UseCase<void, Category> {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Category params, {String? shopId}) {
    return repository.updateCategory(params, shopId: shopId);
  }
}

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params, {String? shopId}) {
    return repository.deleteCategory(params, shopId: shopId);
  }
}
