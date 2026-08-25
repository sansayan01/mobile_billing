import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  ProductModel _fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as String,
      name: data['name'] as String? ?? '',
      // Defensive — legacy rows may have null barcode.
      barcode: data['barcode'] as String? ?? '',
      price: (data['price'] as num).toDouble(),
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      categoryId: data['category_id'] as String?,
      location: data['location'] as String?,
      description: data['description'] as String?,
      imageUrl: data['image_url'] as String?,
      qrData: data['qr_data'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      warrantyType: data['warranty_type'] as String? ?? 'none',
      warrantyDuration: (data['warranty_duration'] as num?)?.toInt(),
      warrantyUnit: data['warranty_unit'] as String?,
      minStockLevel: (data['min_stock_level'] as num?)?.toInt() ?? 5,
      unit: data['unit'] as String? ?? 'pcs',
    );
  }

  /// Resolve shopId: if not provided, fetch from current user's profile.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null) return shopId;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final profile = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        return profile['shop_id'] as String?;
      }
    } catch (_) {
      // If profile fetch fails, return null — RLS may block the operation.
    }
    return null;
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? shopId}) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false);

      final products = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      // Cache in Hive for offline fallback (batched write)
      final box = HiveDatabase.productBox;
      await box.clear();
      await box.putAll({for (final product in products) product.id: product});

      return Right(products);
    } catch (e) {
      // Fallback to Hive cache
      try {
        final box = HiveDatabase.productBox;
        final products = box.values.toList();
        return Right(products);
      } catch (cacheError) {
        return Left(CacheFailure('Failed to fetch products: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(
    String barcode, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').select().eq('barcode', barcode);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.maybeSingle();

      if (response != null) {
        final product = _fromMap(response);
        return Right(product);
      }

      // Fallback to Hive
      final box = HiveDatabase.productBox;
      final product = box.values.firstWhere(
        (element) => element.barcode == barcode,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product);
    } catch (e) {
      try {
        final box = HiveDatabase.productBox;
        final product = box.values.firstWhere(
          (element) => element.barcode == barcode,
          orElse: () => throw Exception('Product not found'),
        );
        return Right(product);
      } catch (cacheError) {
        return Left(CacheFailure('Failed to find product by barcode: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String categoryId, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('products')
          .select()
          .eq('category_id', categoryId);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false);

      final products = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch products by category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(
    Product product, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final model = ProductModel.fromEntity(product);
      await _supabase.from('products').insert({
        'id': model.id,
        'name': model.name,
        'barcode': model.barcode,
        'price': model.price,
        'stock': model.stock,
        'category_id': model.categoryId,
        'location': model.location,
        'description': model.description,
        'image_url': model.imageUrl,
        'qr_data': model.qrData,
        'shop_id': effectiveShopId,
        'warranty_type': model.warrantyType,
        'warranty_duration': model.warrantyDuration,
        'warranty_unit': model.warrantyUnit,
        'min_stock_level': model.minStockLevel,
        'unit': model.unit,
      });

      // Cache in Hive
      final box = HiveDatabase.productBox;
      await box.put(model.id, model);

      // Audit log
      await _logAudit('product.created', 'product', model.id, model.name, 'Product "${model.name}" added', null, {
        'name': model.name,
        'price': model.price,
        'stock': model.stock,
        'barcode': model.barcode,
        'category_id': model.categoryId,
        'location': model.location,
        'unit': model.unit,
        'min_stock_level': model.minStockLevel,
      }, effectiveShopId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
    Product product, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final model = ProductModel.fromEntity(product);
      // .update() (not upsert) — product must already exist; avoids clobbering
      // rows on id collision and respects RLS shop scoping.
      var updateQuery = _supabase.from('products').update({
        'name': model.name,
        'barcode': model.barcode,
        'price': model.price,
        'stock': model.stock,
        'category_id': model.categoryId,
        'location': model.location,
        'description': model.description,
        'image_url': model.imageUrl,
        'qr_data': model.qrData,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'warranty_type': model.warrantyType,
        'warranty_duration': model.warrantyDuration,
        'warranty_unit': model.warrantyUnit,
        'min_stock_level': model.minStockLevel,
        'unit': model.unit,
      }).eq('id', model.id);
      if (effectiveShopId != null) {
        updateQuery = updateQuery.eq('shop_id', effectiveShopId);
      }
      await updateQuery;

      // Fetch old product from Hive for audit comparison
      final box = HiveDatabase.productBox;
      final oldModel = box.get(model.id);

      // Build old/new values for audit
      Map<String, dynamic>? oldValue;
      if (oldModel != null) {
        oldValue = {
          'name': oldModel.name,
          'price': oldModel.price,
          'stock': oldModel.stock,
          'barcode': oldModel.barcode,
          'category_id': oldModel.categoryId,
          'location': oldModel.location,
          'unit': oldModel.unit,
          'min_stock_level': oldModel.minStockLevel,
        };
      }
      final newValue = {
        'name': model.name,
        'price': model.price,
        'stock': model.stock,
        'barcode': model.barcode,
        'category_id': model.categoryId,
        'location': model.location,
        'unit': model.unit,
        'min_stock_level': model.minStockLevel,
      };

      // Update in Hive
      await box.put(model.id, model);

      // Audit log
      await _logAudit('product.edited', 'product', model.id, model.name, 'Product "${model.name}" updated', oldValue, newValue, effectiveShopId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getCurrentStockBulk(
    List<String> productIds, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').select('id, name, stock');
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.filter('id', 'in', productIds);

      final stockMap = <String, int>{};
      for (final row in response as List<dynamic>) {
        final data = row as Map<String, dynamic>;
        stockMap[data['id'] as String] =
            (data['stock'] as num?)?.toInt() ?? 0;
      }

      return Right(stockMap);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch current stock: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(
    String id, {
    String? shopId,
  }) async {
    try {
      // Remove dependent records first (FK constraints block direct delete)
      await _supabase.from('inventory_log').delete().eq('product_id', id);
      await _supabase.from('bill_items').delete().eq('product_id', id);

      final effectiveShopId = await _resolveShopId(shopId);
      // Get product name before delete for audit
      String? deletedName;
      try {
        final p = await _supabase.from('products').select('name').eq('id', id).maybeSingle();
        deletedName = p?['name'] as String?;
      } catch (_) {}
      var query = _supabase.from('products').delete().eq('id', id);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      await query;

      // Delete from Hive
      final box = HiveDatabase.productBox;
      await box.delete(id);

      // Audit log
      await _logAudit('product.deleted', 'product', id, deletedName, 'Product "${deletedName ?? id}" deleted', null, null, effectiveShopId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete product: $e'));
    }
  }

  // Helper: log audit action
  Future<void> _logAudit(String action, String entityType, String? entityId, String? entityName, String description, Map<String, dynamic>? oldValue, Map<String, dynamic>? newValue, String? shopId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      String? staffName;
      if (userId != null) {
        final profile = await _supabase.from('profiles').select('name').eq('id', userId).maybeSingle();
        staffName = profile?['name'] as String?;
      }
      await _supabase.from('audit_logs').insert({
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
