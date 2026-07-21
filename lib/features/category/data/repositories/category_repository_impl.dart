import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Fallback: if the caller didn't pass a shopId (e.g. stale auth state
  /// in the BLoC), fetch the current user's shop_id directly from DB so
  /// RLS `belongs_to_shop(shop_id)` can resolve correctly.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null && shopId.isNotEmpty) return shopId;
    try {
      final uid = SupabaseConfig.client.auth.currentUser?.id;
      if (uid == null) return null;
      final row = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', uid)
          .maybeSingle();
      if (row is Map<String, dynamic>) return row['shop_id'] as String?;
    } catch (_) {}
    return null;
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({String? shopId}) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('categories').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
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
      final resolvedShopId = await _resolveShopId(shopId);
      final payload = <String, dynamic>{
        'id': category.id,
        'name': category.name,
        'description': category.description,
      };
      if (resolvedShopId != null) payload['shop_id'] = resolvedShopId;
      await _supabase.from('categories').insert(payload);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category,
      {String? shopId}) async {
    try {
      final resolvedShopId = await _resolveShopId(shopId);
      final payload = <String, dynamic>{
        'id': category.id,
        'name': category.name,
        'description': category.description,
      };
      if (resolvedShopId != null) payload['shop_id'] = resolvedShopId;
      await _supabase.from('categories').upsert(payload);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id,
      {String? shopId}) async {
    try {
      final resolvedShopId = await _resolveShopId(shopId);
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('shop_id', resolvedShopId!);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete category: $e'));
    }
  }
}
