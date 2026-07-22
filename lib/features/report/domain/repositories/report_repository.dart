import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<BillSummary>>> getBillHistory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
    String? shopId,
    String? searchQuery,
    String? paymentMethod,
  });

  Future<Either<Failure, BillSummary>> getBillDetail(
    String billId, {
    String? shopId,
  });

  Future<Either<Failure, DailySales>> getDailySales(
    DateTime date, {
    String? shopId,
  });

  Future<Either<Failure, List<DailySales>>> getSalesRange(
    DateTime from,
    DateTime to, {
    String? shopId,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getLowStockProducts(
    int threshold, {
    String? shopId,
  });

  Future<Either<Failure, List<StockMovement>>> getStockMovements({
    String? productId,
    DateTime? from,
    DateTime? to,
    String? changeType,
    String? shopId,
  });

  Future<Either<Failure, BillSummary>> updateBill(
    String billId,
    Map<String, dynamic> updates, {
    String? shopId,
  });

  Future<Either<Failure, void>> deleteBill(
    String billId, {
    String? shopId,
  });
}
