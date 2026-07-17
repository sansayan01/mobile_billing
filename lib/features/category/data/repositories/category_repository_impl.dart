import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  @override
  Future<Either<Failure, List<Category>>> getCategories({String? shopId}) async {
    try {
      var query = _supabase.from('categories').select();
      if (shopId != null) {
        query = query.eq('shop_id', shopId);
      }
      final response = await query.order('created_at', ascending: false);

      final categories = (response as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch categories: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category,
      {String? shopId}) async {
    try {
      await _supabase.from('categories').insert({
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'shop_id': shopId,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category,
      {String? shopId}) async {
    try {
      await _supabase.from('categories').upsert({
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'shop_id': shopId,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id,
      {String? shopId}) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete category: $e'));
    }
  }
}
