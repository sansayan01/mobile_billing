import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/domain/repositories/report_repository.dart';

// ===================== Params =====================

class BillHistoryParams extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int limit;
  final String? shopId;

  const BillHistoryParams({
    this.from,
    this.to,
    this.page = 1,
    this.limit = 20,
    this.shopId,
  });

  @override
  List<Object?> get props => [from, to, page, limit, shopId];
}

class BillDetailParams extends Equatable {
  final String billId;
  final String? shopId;

  const BillDetailParams({required this.billId, this.shopId});

  @override
  List<Object?> get props => [billId, shopId];
}

class DailySalesParams extends Equatable {
  final DateTime date;
  final String? shopId;

  const DailySalesParams({required this.date, this.shopId});

  @override
  List<Object?> get props => [date, shopId];
}

class SalesRangeParams extends Equatable {
  final DateTime from;
  final DateTime to;
  final String? shopId;

  const SalesRangeParams({required this.from, required this.to, this.shopId});

  @override
  List<Object?> get props => [from, to, shopId];
}

class LowStockParams extends Equatable {
  final int threshold;
  final String? shopId;

  const LowStockParams({required this.threshold, this.shopId});

  @override
  List<Object?> get props => [threshold, shopId];
}

class StockMovementParams extends Equatable {
  final String? productId;
  final DateTime? from;
  final DateTime? to;
  final String? changeType;
  final String? shopId;

  const StockMovementParams({
    this.productId,
    this.from,
    this.to,
    this.changeType,
    this.shopId,
  });

  @override
  List<Object?> get props => [productId, from, to, changeType, shopId];
}

// ===================== Use Cases =====================

class GetBillHistoryUseCase
    implements UseCase<List<BillSummary>, BillHistoryParams> {
  final ReportRepository repository;

  GetBillHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<BillSummary>>> call(BillHistoryParams params) {
    return repository.getBillHistory(
      from: params.from,
      to: params.to,
      page: params.page,
      limit: params.limit,
      shopId: params.shopId,
    );
  }
}

class GetBillDetailUseCase
    implements UseCase<BillSummary, BillDetailParams> {
  final ReportRepository repository;

  GetBillDetailUseCase(this.repository);

  @override
  Future<Either<Failure, BillSummary>> call(BillDetailParams params) {
    return repository.getBillDetail(
      params.billId,
      shopId: params.shopId,
    );
  }
}

class GetDailySalesUseCase implements UseCase<DailySales, DailySalesParams> {
  final ReportRepository repository;

  GetDailySalesUseCase(this.repository);

  @override
  Future<Either<Failure, DailySales>> call(DailySalesParams params) {
    return repository.getDailySales(
      params.date,
      shopId: params.shopId,
    );
  }
}

class GetSalesRangeUseCase
    implements UseCase<List<DailySales>, SalesRangeParams> {
  final ReportRepository repository;

  GetSalesRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<DailySales>>> call(SalesRangeParams params) {
    return repository.getSalesRange(
      params.from,
      params.to,
      shopId: params.shopId,
    );
  }
}

class GetLowStockProductsUseCase
    implements UseCase<List<Map<String, dynamic>>, LowStockParams> {
  final ReportRepository repository;

  GetLowStockProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      LowStockParams params) {
    return repository.getLowStockProducts(
      params.threshold,
      shopId: params.shopId,
    );
  }
}

class GetStockMovementsUseCase
    implements UseCase<List<StockMovement>, StockMovementParams> {
  final ReportRepository repository;

  GetStockMovementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockMovement>>> call(
      StockMovementParams params) {
    return repository.getStockMovements(
      productId: params.productId,
      from: params.from,
      to: params.to,
      changeType: params.changeType,
      shopId: params.shopId,
    );
  }
}
