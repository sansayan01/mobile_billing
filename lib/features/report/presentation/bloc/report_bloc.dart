import 'package:bloc/bloc.dart';

import 'package:billing_app/features/report/domain/usecases/report_usecases.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetBillHistoryUseCase getBillHistoryUseCase;
  final GetBillDetailUseCase getBillDetailUseCase;
  final GetDailySalesUseCase getDailySalesUseCase;
  final GetSalesRangeUseCase getSalesRangeUseCase;
  final GetLowStockProductsUseCase getLowStockProductsUseCase;
  final GetStockMovementsUseCase getStockMovementsUseCase;

  ReportBloc({
    required this.getBillHistoryUseCase,
    required this.getBillDetailUseCase,
    required this.getDailySalesUseCase,
    required this.getSalesRangeUseCase,
    required this.getLowStockProductsUseCase,
    required this.getStockMovementsUseCase,
  }) : super(const ReportState()) {
    on<LoadBillHistory>(_onLoadBillHistory);
    on<LoadBillDetail>(_onLoadBillDetail);
    on<LoadDailySales>(_onLoadDailySales);
    on<LoadSalesRange>(_onLoadSalesRange);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<LoadStockMovements>(_onLoadStockMovements);
    on<ResetReport>(_onResetReport);
  }

  Future<void> _onLoadBillHistory(
      LoadBillHistory event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getBillHistoryUseCase(
      BillHistoryParams(
        from: event.from ?? DateTime(2020, 1, 1),
        to: event.to ?? DateTime.now(),
        page: event.page,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (bills) {
        if (event.page == 1) {
          emit(state.copyWith(
            status: ReportStatus.loaded,
            billHistory: bills,
            currentPage: event.page,
            hasMorePages: bills.length >= 20,
          ));
        } else {
          emit(state.copyWith(
            status: ReportStatus.loaded,
            billHistory: [...state.billHistory, ...bills],
            currentPage: event.page,
            hasMorePages: bills.length >= 20,
          ));
        }
      },
    );
  }

  Future<void> _onLoadBillDetail(
      LoadBillDetail event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getBillDetailUseCase(
        BillDetailParams(billId: event.billId));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (bill) => emit(state.copyWith(
          status: ReportStatus.loaded, billDetail: bill)),
    );
  }

  Future<void> _onLoadDailySales(
      LoadDailySales event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getDailySalesUseCase(
        DailySalesParams(date: event.date));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (sales) => emit(state.copyWith(
          status: ReportStatus.loaded, dailySales: sales)),
    );
  }

  Future<void> _onLoadSalesRange(
      LoadSalesRange event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getSalesRangeUseCase(
      SalesRangeParams(from: event.from, to: event.to),
    );

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (sales) => emit(state.copyWith(
          status: ReportStatus.loaded, salesRange: sales)),
    );
  }

  Future<void> _onLoadLowStockProducts(
      LoadLowStockProducts event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getLowStockProductsUseCase(
        LowStockParams(threshold: event.threshold));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (products) => emit(state.copyWith(
          status: ReportStatus.loaded, lowStockProducts: products)),
    );
  }

  Future<void> _onLoadStockMovements(
      LoadStockMovements event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null));

    final result = await getStockMovementsUseCase(
      StockMovementParams(
        productId: event.productId,
        from: event.from,
        to: event.to,
        changeType: event.changeType,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (movements) => emit(state.copyWith(
          status: ReportStatus.loaded, stockMovements: movements)),
    );
  }

  void _onResetReport(ResetReport event, Emitter<ReportState> emit) {
    emit(const ReportState());
  }
}
