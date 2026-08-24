import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;
  final AuthBloc authBloc;

  StockBloc({
    required this.stockRepository,
    required this.authBloc,
  }) : super(const StockState()) {
    on<AdjustStock>(_onAdjustStock);
    on<LoadStockHistory>(_onLoadStockHistory);
    on<LoadAllAdjustments>(_onLoadAllAdjustments);
  }

  String? get _currentShopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  Future<void> _onAdjustStock(
      AdjustStock event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final result = await stockRepository.adjustStock(
      productId: event.productId,
      quantityChange: event.quantityChange,
      reason: event.reason,
      note: event.note,
      shopId: _currentShopId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: StockStatus.error, message: failure.message)),
      (_) => emit(state.copyWith(
          status: StockStatus.success,
          message: 'Stock updated successfully')),
    );
  }

  Future<void> _onLoadStockHistory(
      LoadStockHistory event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final result = await stockRepository.getStockHistory(
      event.productId,
      shopId: _currentShopId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: StockStatus.error, message: failure.message)),
      (adjustments) => emit(state.copyWith(
          status: StockStatus.loaded, adjustments: adjustments)),
    );
  }

  Future<void> _onLoadAllAdjustments(
      LoadAllAdjustments event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: StockStatus.loading));
    final result = await stockRepository.getAllAdjustments(
      shopId: _currentShopId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: StockStatus.error, message: failure.message)),
      (adjustments) => emit(state.copyWith(
          status: StockStatus.loaded, adjustments: adjustments)),
    );
  }
}
