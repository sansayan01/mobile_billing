import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final RealtimeService realtimeService;
  final AuthBloc authBloc;

  Timer? _realtimeDebounce;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.realtimeService,
    required this.authBloc,
  }) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<FilterByCategory>(_onFilterByCategory);
    on<GenerateQrCode>(_onGenerateQrCode);
    on<InitRealtime>(_onInitRealtime);
    on<ProductsRealtimeUpdated>(_onProductsRealtimeUpdated);
  }

  /// Current shop id from the authenticated AuthBloc state, or null if not
  /// authenticated. Used to scope product queries/inserts to the tenant.
  String? get _currentShopId {
    final s = authBloc.state;
    return s is Authenticated ? s.user.shopId : null;
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await getProductsUseCase(NoParams(), shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (products) => emit(state.copyWith(
          status: ProductStatus.loaded,
          products: products,
          filteredProducts: products,
          selectedCategoryId: null)),
    );
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await addProductUseCase(event.product, shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'Product added successfully'));
        add(LoadProducts());
      },
    );
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await updateProductUseCase(event.product, shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'Product updated successfully'));
        add(LoadProducts());
      },
    );
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await deleteProductUseCase(event.id, shopId: _currentShopId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'Product deleted successfully'));
        add(LoadProducts());
      },
    );
  }

  void _onFilterByCategory(
      FilterByCategory event, Emitter<ProductState> emit) {
    if (event.categoryId == null) {
      // Show all products
      emit(state.copyWith(
        clearSelectedCategory: true,
        filteredProducts: state.products,
      ));
    } else {
      // Filter by category
      final filtered = state.products
          .where((p) => p.categoryId == event.categoryId)
          .toList();
      emit(state.copyWith(
        selectedCategoryId: event.categoryId,
        filteredProducts: filtered,
      ));
    }
  }

  void _onGenerateQrCode(
      GenerateQrCode event, Emitter<ProductState> emit) {
    // Generate QR data combining product info
    final qrData =
        '${event.product.name}|${event.product.barcode}|₹${event.product.price.toStringAsFixed(2)}';
    emit(state.copyWith(qrCodeData: qrData));
  }

  void _onInitRealtime(
      InitRealtime event, Emitter<ProductState> emit) {
    try {
      realtimeService.subscribeToProducts((payload) {
        final eventType = payload['event_type'] as String;
        add(ProductsRealtimeUpdated(
          changeType: eventType,
          payload: payload,
        ));
      });
    } catch (_) {
      // Realtime init failed — app continues without live updates
    }
  }

  Future<void> _onProductsRealtimeUpdated(
      ProductsRealtimeUpdated event, Emitter<ProductState> emit) async {
    try {
      if (event.changeType == 'DELETE') {
        // Remove from state directly — no full reload needed
        final deletedId = (event.payload['old'] as Map<String, dynamic>?)?
            ['id'] as String?;
        if (deletedId == null) return;

        final updatedProducts =
            state.products.where((p) => p.id != deletedId).toList();
        final updatedFiltered =
            state.filteredProducts.where((p) => p.id != deletedId).toList();

        emit(state.copyWith(
          status: ProductStatus.loaded,
          products: updatedProducts,
          filteredProducts: updatedFiltered,
        ));
      } else {
        // INSERT or UPDATE — debounce reload to batch rapid changes
        _realtimeDebounce?.cancel();
        _realtimeDebounce = Timer(
          const Duration(milliseconds: 300),
          () => add(LoadProducts()),
        );
      }
    } catch (_) {
      // Silently handle real-time update errors
    }
  }

  @override
  Future<void> close() {
    _realtimeDebounce?.cancel();
    realtimeService.dispose();
    return super.close();
  }
}
