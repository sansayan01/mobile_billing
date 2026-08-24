import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

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
    } catch (_) {}
    return null;
  }

  @override
  Future<Either<Failure, void>> adjustStock({
    required String productId,
    required int quantityChange,
    required StockAdjustmentReason reason,
    String? note,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);

      // Get current stock
      var productQuery =
          _supabase.from('products').select('stock').eq('id', productId);
      final productData = await productQuery.maybeSingle();
      if (productData == null) {
        return const Left(ServerFailure('Product not found'));
      }

      final currentStock = productData['stock'] as int;
      final newStock = currentStock + quantityChange;

      // Prevent negative stock
      if (newStock < 0) {
        return const Left(ServerFailure('Stock cannot go below zero'));
      }

      // Update product stock
      await _supabase
          .from('products')
          .update({'stock': newStock}).eq('id', productId);

      // Log the adjustment
      await _supabase.from('stock_adjustments').insert({
        'id': const Uuid().v4(),
        'product_id': productId,
        'previous_stock': currentStock,
        'new_stock': newStock,
        'quantity_changed': quantityChange,
        'reason': reason.name,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
        'created_by': _supabase.auth.currentUser?.id,
        'shop_id': effectiveShopId,
      });

      // Audit log
      final action = quantityChange > 0 ? 'stock.added' : 'stock.removed';
      final userId = _supabase.auth.currentUser?.id;
      String? staffName;
      try {
        if (userId != null) {
          final profile = await _supabase.from('profiles').select('name').eq('id', userId).maybeSingle();
          staffName = profile?['name'] as String?;
        }
      } catch (_) {}

      await _supabase.from('audit_logs').insert({
        'action': action,
        'entity_type': 'stock',
        'entity_id': productId,
        'description': '${quantityChange > 0 ? "Added" : "Removed"} ${quantityChange.abs()} units (${reason.name})${note != null && note.isNotEmpty ? " — $note" : ""}',
        'old_value': {'stock': currentStock},
        'new_value': {'stock': newStock},
        'staff_name': staffName,
        'shop_id': effectiveShopId,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to adjust stock: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StockAdjustment>>> getStockHistory(
    String productId, {
    String? shopId,
  }) async {
    try {
      final response = await _supabase
          .from('stock_adjustments')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false)
          .limit(50);

      final adjustments = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(adjustments);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch stock history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StockAdjustment>>> getAllAdjustments({
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('stock_adjustments').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false).limit(100);

      final adjustments = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(adjustments);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch adjustments: $e'));
    }
  }

  StockAdjustment _fromMap(Map<String, dynamic> data) {
    return StockAdjustment(
      id: data['id'] as String,
      productId: data['product_id'] as String,
      previousStock: data['previous_stock'] as int,
      newStock: data['new_stock'] as int,
      quantityChanged: data['quantity_changed'] as int,
      reason: StockAdjustmentReason.values.firstWhere(
        (e) => e.name == data['reason'],
        orElse: () => StockAdjustmentReason.adjustment,
      ),
      note: data['note'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      createdBy: data['created_by'] as String?,
    );
  }
}
