import 'package:bloc/bloc.dart';

import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
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
  final UpdateBillUseCase updateBillUseCase;
  final DeleteBillUseCase deleteBillUseCase;
  final AuthBloc authBloc;

  ReportBloc({
    required this.getBillHistoryUseCase,
    required this.getBillDetailUseCase,
    required this.getDailySalesUseCase,
    required this.getSalesRangeUseCase,
    required this.getLowStockProductsUseCase,
    required this.getStockMovementsUseCase,
    required this.updateBillUseCase,
    required this.deleteBillUseCase,
    required this.authBloc,
  }) : super(const ReportState()) {
    on<LoadBillHistory>(_onLoadBillHistory);
    on<LoadBillDetail>(_onLoadBillDetail);
    on<LoadDailySales>(_onLoadDailySales);
    on<LoadSalesRange>(_onLoadSalesRange);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<LoadStockMovements>(_onLoadStockMovements);
    on<ResetReport>(_onResetReport);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  String? get _currentShopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  Future<void> _onLoadBillHistory(
      LoadBillHistory event, Emitter<ReportState> emit) async {
    // Preserve existing data while loading (don't clear billHistory)
    emit(state.copyWith(status: ReportStatus.loading));

    final result = await getBillHistoryUseCase(
      BillHistoryParams(
        from: event.from ?? DateTime(2020, 1, 1),
        to: event.to ?? DateTime.now(),
        page: event.page,
        shopId: _currentShopId,
        searchQuery: event.searchQuery,
        paymentMethod: event.paymentMethod,
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
        BillDetailParams(billId: event.billId, shopId: _currentShopId));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (bill) => emit(state.copyWith(
          status: ReportStatus.loaded, billDetail: bill)),
    );
  }

  Future<void> _onLoadDailySales(
      LoadDailySales event, Emitter<ReportState> emit) async {
    // Preserve existing data while loading (don't clear billHistory)
    emit(state.copyWith(status: ReportStatus.loading));

    final result = await getDailySalesUseCase(
        DailySalesParams(date: event.date, shopId: _currentShopId));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (sales) => emit(state.copyWith(
          status: ReportStatus.loaded, dailySales: sales)),
    );
  }

  Future<void> _onLoadSalesRange(
      LoadSalesRange event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));

    final result = await getSalesRangeUseCase(
      SalesRangeParams(from: event.from, to: event.to, shopId: _currentShopId),
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
    emit(state.copyWith(status: ReportStatus.loading));

    final result = await getLowStockProductsUseCase(
        LowStockParams(threshold: event.threshold, shopId: _currentShopId));

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message)),
      (products) => emit(state.copyWith(
          status: ReportStatus.loaded, lowStockProducts: products)),
    );
  }

  Future<void> _onLoadStockMovements(
      LoadStockMovements event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));

    final result = await getStockMovementsUseCase(
      StockMovementParams(
        productId: event.productId,
        from: event.from,
        to: event.to,
        changeType: event.changeType,
        shopId: _currentShopId,
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

  Future<void> _onUpdateBill(
      UpdateBill event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null, message: null, clearMessage: true));

    final result = await updateBillUseCase(
      UpdateBillParams(
        billId: event.billId,
        updates: event.updates,
        shopId: _currentShopId,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message, message: failure.message)),
      (updatedBill) {
        emit(state.copyWith(
            status: ReportStatus.loaded,
            message: 'Bill updated successfully',
            billDetail: updatedBill));
        add(LoadBillDetail(event.billId));
      },
    );
  }

  Future<void> _onDeleteBill(
      DeleteBill event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading, error: null, message: null, clearMessage: true));

    final result = await deleteBillUseCase(
      DeleteBillParams(billId: event.billId, shopId: _currentShopId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, error: failure.message, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ReportStatus.loaded,
            message: 'Bill deleted successfully',
            billDetail: null));
        add(ResetReport());
      },
    );
  }
}
