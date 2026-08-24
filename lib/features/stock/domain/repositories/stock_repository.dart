import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/stock_adjustment.dart';

abstract class StockRepository {
  /// Adjust stock for a product (increase or decrease)
  Future<Either<Failure, void>> adjustStock({
    required String productId,
    required int quantityChange, // +ve = increase, -ve = decrease
    required StockAdjustmentReason reason,
    String? note,
    String? shopId,
  });

  /// Get stock adjustment history for a product
  Future<Either<Failure, List<StockAdjustment>>> getStockHistory(
    String productId, {
    String? shopId,
  });

  /// Get all stock adjustments for a shop
  Future<Either<Failure, List<StockAdjustment>>> getAllAdjustments({
    String? shopId,
  });
}
