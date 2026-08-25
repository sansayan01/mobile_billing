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
        'icon_code_point': category.iconCodePoint,
        'color_value': category.colorValue,
      };
      if (resolvedShopId != null) payload['shop_id'] = resolvedShopId;
      await _supabase.from('categories').insert(payload);

      // Audit log
      await _logAudit('category.created', 'category', category.id, category.name, 'Category "${category.name}" created', null, {
        'name': category.name,
        'description': category.description,
      }, resolvedShopId);

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
        'icon_code_point': category.iconCodePoint,
        'color_value': category.colorValue,
      };
      if (resolvedShopId != null) payload['shop_id'] = resolvedShopId;
      // Fetch old category name for audit
      String? oldName;
      try {
        final old = await _supabase.from('categories').select('name, description').eq('id', category.id).maybeSingle();
        oldName = old?['name'] as String?;
      } catch (_) {}

      await _supabase.from('categories').upsert(payload);

      // Audit log
      await _logAudit('category.edited', 'category', category.id, category.name, 'Category "${category.name}" updated',
        oldName != null ? {'name': oldName} : null,
        {'name': category.name, 'description': category.description},
        resolvedShopId);

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
      // Get name before delete for audit
      String? deletedName;
      try {
        final c = await _supabase.from('categories').select('name').eq('id', id).maybeSingle();
        deletedName = c?['name'] as String?;
      } catch (_) {}

      // Guard instead of `resolvedShopId!` — a null here used to crash with a
      // cryptic "Null check operator" error swallowed into a generic failure.
      if (resolvedShopId == null) {
        return Left(ServerFailure('Shop not found — please log in again'));
      }
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('shop_id', resolvedShopId);

      // Audit log
      await _logAudit('category.deleted', 'category', id, deletedName, 'Category "${deletedName ?? id}" deleted', null, null, resolvedShopId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete category: $e'));
    }
  }

  // Helper: log audit action
  Future<void> _logAudit(String action, String entityType, String? entityId, String? entityName, String description, Map<String, dynamic>? oldValue, Map<String, dynamic>? newValue, String? shopId) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      String? staffName;
      if (userId != null) {
        final profile = await SupabaseConfig.client.from('profiles').select('name').eq('id', userId).maybeSingle();
        staffName = profile?['name'] as String?;
      }
      await SupabaseConfig.client.from('audit_logs').insert({
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'entity_name': entityName,
        'description': description,
        'old_value': oldValue,
        'new_value': newValue,
        'staff_name': staffName,
        'shop_id': shopId,
      });
    } catch (_) {}
  }
}
