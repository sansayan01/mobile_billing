import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<BillSummary>>> getBillHistory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, BillSummary>> getBillDetail(String billId);

  Future<Either<Failure, DailySales>> getDailySales(DateTime date);

  Future<Either<Failure, List<DailySales>>> getSalesRange(
    DateTime from,
    DateTime to,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getLowStockProducts(
    int threshold,
  );

  Future<Either<Failure, List<StockMovement>>> getStockMovements({
    String? productId,
    DateTime? from,
    DateTime? to,
    String? changeType,
  });
}
