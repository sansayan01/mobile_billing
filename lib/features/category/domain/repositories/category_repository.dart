import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/category/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories({String? shopId});
  Future<Either<Failure, void>> addCategory(Category category, {String? shopId});
  Future<Either<Failure, void>> updateCategory(Category category,
      {String? shopId});
  Future<Either<Failure, void>> deleteCategory(String id, {String? shopId});
}
