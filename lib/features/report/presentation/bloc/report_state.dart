import 'package:equatable/equatable.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<BillSummary> billHistory;
  final BillSummary? billDetail;
  final DailySales? dailySales;
  final List<DailySales> salesRange;
  final List<Map<String, dynamic>> lowStockProducts;
  final List<StockMovement> stockMovements;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  const ReportState({
    this.status = ReportStatus.initial,
    this.billHistory = const [],
    this.billDetail,
    this.dailySales,
    this.salesRange = const [],
    this.lowStockProducts = const [],
    this.stockMovements = const [],
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  ReportState copyWith({
    ReportStatus? status,
    List<BillSummary>? billHistory,
    BillSummary? billDetail,
    DailySales? dailySales,
    List<DailySales>? salesRange,
    List<Map<String, dynamic>>? lowStockProducts,
    List<StockMovement>? stockMovements,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return ReportState(
      status: status ?? this.status,
      billHistory: billHistory ?? this.billHistory,
      billDetail: billDetail ?? this.billDetail,
      dailySales: dailySales ?? this.dailySales,
      salesRange: salesRange ?? this.salesRange,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      stockMovements: stockMovements ?? this.stockMovements,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        billHistory,
        billDetail,
        dailySales,
        salesRange,
        lowStockProducts,
        stockMovements,
        error,
        currentPage,
        hasMorePages,
      ];
}
