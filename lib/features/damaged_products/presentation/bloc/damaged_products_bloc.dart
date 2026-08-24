import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billing_app/features/damaged_products/domain/entities/damaged_product.dart';
import 'package:billing_app/features/damaged_products/domain/repositories/damaged_products_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';

part 'damaged_products_event.dart';
part 'damaged_products_state.dart';

class DamagedProductsBloc extends Bloc<DamagedProductsEvent, DamagedProductsState> {
  final DamagedProductsRepository repository;
  final AuthBloc authBloc;

  DamagedProductsBloc({
    required this.repository,
    required this.authBloc,
  }) : super(const DamagedProductsState()) {
    on<LoadDamagedProducts>(_onLoadDamagedProducts);
    on<SearchDamagedProducts>(_onSearchDamagedProducts);
    on<FilterDamagedProductsByDate>(_onFilterByDate);
    on<MarkProductAsDamaged>(_onMarkAsDamaged);
    on<UndoDamagedProduct>(_onUndoDamagedProduct);
  }

  String? get _currentShopId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.shopId;
    }
    return null;
  }

  Future<void> _onLoadDamagedProducts(
    LoadDamagedProducts event,
    Emitter<DamagedProductsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repository.getDamagedProducts(
      shopId: _currentShopId,
      searchQuery: state.searchQuery,
      startDate: state.startDate,
      endDate: state.endDate,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (damagedProducts) {
        final totalLoss = damagedProducts.fold<double>(
          0,
          (sum, dp) => sum + dp.estimatedLoss,
        );
        emit(state.copyWith(
          isLoading: false,
          damagedProducts: damagedProducts,
          totalLoss: totalLoss,
          totalCount: damagedProducts.length,
        ));
      },
    );
  }

  Future<void> _onSearchDamagedProducts(
    SearchDamagedProducts event,
    Emitter<DamagedProductsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query, clearSearchQuery: event.query == null));
    add(const LoadDamagedProducts());
  }

  Future<void> _onFilterByDate(
    FilterDamagedProductsByDate event,
    Emitter<DamagedProductsState> emit,
  ) async {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      clearStartDate: event.startDate == null,
      clearEndDate: event.endDate == null,
    ));
    add(const LoadDamagedProducts());
  }

  Future<void> _onMarkAsDamaged(
    MarkProductAsDamaged event,
    Emitter<DamagedProductsState> emit,
  ) async {
    emit(state.copyWith(isMarking: true, error: null, clearSuccessMessage: true));

    final result = await repository.markAsDamaged(
      productId: event.productId,
      quantity: event.quantity,
      damageType: event.damageType,
      notes: event.notes,
      shopId: _currentShopId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isMarking: false,
        error: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isMarking: false,
          successMessage: 'Product marked as damaged successfully!',
        ));
        // Reload the list
        add(const LoadDamagedProducts());
      },
    );
  }

  Future<void> _onUndoDamagedProduct(
    UndoDamagedProduct event,
    Emitter<DamagedProductsState> emit,
  ) async {
    emit(state.copyWith(isMarking: true, error: null, clearSuccessMessage: true));

    final result = await repository.undoDamage(
      adjustmentId: event.adjustmentId,
      productId: event.productId,
      quantityRestored: event.quantityRestored,
      shopId: _currentShopId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isMarking: false,
        error: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isMarking: false,
          successMessage: 'Damage entry reversed successfully!',
        ));
        add(const LoadDamagedProducts());
      },
    );
  }
}
