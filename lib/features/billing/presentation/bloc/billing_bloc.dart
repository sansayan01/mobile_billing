import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final GetCurrentStockBulkUseCase getCurrentStockBulkUseCase;
  final AuthBloc authBloc;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.getCurrentStockBulkUseCase,
    required this.authBloc,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<UpdateItemPriceEvent>(_onUpdateItemPrice);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<UpdateDiscountEvent>(_onUpdateDiscount);
    on<UpdateGrandTotalOverrideEvent>(_onUpdateGrandTotalOverride);
    on<SetDiscountTypeEvent>(_onSetDiscountType);
    on<SubmitBillEvent>(_onSubmitBill);
    on<ValidateStockBeforeBill>(_onValidateStockBeforeBill);
    on<ClearStockErrorsEvent>(_onClearStockErrors);
    on<UpdateCustomerInfoEvent>(_onUpdateCustomerInfo);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final shopId = authBloc.state is Authenticated
        ? (authBloc.state as Authenticated).user.shopId
        : null;
    final result =
        await getProductByBarcodeUseCase(event.barcode, shopId: shopId);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'Product not found: ${event.barcode}')),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final cleanState = state.copyWith(error: null);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      final backendItems = List<CartItem>.from(cleanState.cartItems);
      backendItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: backendItems, error: null));
    } else {
      final newItem = CartItem(product: event.product);
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onUpdateItemPrice(
      UpdateItemPriceEvent event, Emitter<BillingState> emit) {
    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      if (event.customPrice == null || event.customPrice! < 0) {
        items[index] = items[index].copyWith(clearCustomPrice: true);
      } else {
        items[index] = items[index].copyWith(customPrice: event.customPrice);
      }
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(
              error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Printer not connected & no saved printer found!',
            clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(
        isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.unitPrice,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: state.totalAmount,
          footer: event.footer,
          customerName: event.customerName,
          customerPhone: event.customerPhone);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Print failed: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }

  void _onUpdateDiscount(
      UpdateDiscountEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(
      discount: event.discount,
      discountIsPercentage: event.isPercentage,
    ));
  }

  void _onUpdateGrandTotalOverride(
      UpdateGrandTotalOverrideEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(
      grandTotalOverride: event.grandTotal,
    ));
  }

  void _onSetDiscountType(
      SetDiscountTypeEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(
      discountIsPercentage: event.isPercentage,
    ));
  }

  Future<void> _onSubmitBill(
      SubmitBillEvent event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty'));
      return;
    }

    // Validate stock before submitting
    final stockValidation = await _validateStock(state.cartItems);
    if (stockValidation != null) {
      emit(state.copyWith(
        isSubmitting: false,
        stockErrors: stockValidation,
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      submitSuccess: false,
      stockErrors: null,
    ));

    // Get current user directly from Supabase session to avoid
    // race conditions with BLoC auth state transitions.
    final supabaseUser = SupabaseConfig.client.auth.currentUser;
    if (supabaseUser == null) {
      emit(state.copyWith(
          error: 'User not authenticated', isSubmitting: false));
      return;
    }

    // Fetch user profile for shopId
    String? shopId;
    try {
      final profile = await SupabaseConfig.client
          .from('profiles')
          .select('shop_id')
          .eq('id', supabaseUser.id)
          .maybeSingle();
      if (profile != null) {
        shopId = profile['shop_id'] as String?;
      }
    } catch (_) {
      // continue with null shopId — RLS may block if profile missing
    }

    if (shopId == null) {
      emit(state.copyWith(
          error: 'Shop not found. Please contact support.', isSubmitting: false));
      return;
    }

    try {
      final staffId = supabaseUser.id;
      final billId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();
      final baseTotal =
          state.cartItems.fold<double>(0, (sum, item) => sum + item.total);
      final calculatedTotal = state.totalAmount;

      // 1. Insert into bills table
      await SupabaseConfig.client.from('bills').insert({
        'id': billId,
        'shop_id': shopId,
        'staff_id': staffId,
        'total_amount': baseTotal,
        'discount': state.discount,
        'grand_total': calculatedTotal,
        'item_count': state.cartItems.length,
        'payment_method': 'upi',
        'created_at': now,
        'customer_name': state.customerName,
        'customer_phone': state.customerPhone,
      });

      // 2. Insert bill items, update stock, and log inventory
      for (final item in state.cartItems) {
        await SupabaseConfig.client.from('bill_items').insert({
          'id': const Uuid().v4(),
          'bill_id': billId,
          'shop_id': shopId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'price': item.unitPrice,
          'total': item.total,
        });

        // Update product stock (scoped by shop_id for defense-in-depth)
        await SupabaseConfig.client
            .from('products')
            .update({'stock': item.product.stock - item.quantity})
            .eq('id', item.product.id)
            .eq('shop_id', shopId);

        // Log to inventory_log table
        await SupabaseConfig.client.from('inventory_log').insert({
          'id': const Uuid().v4(),
          'product_id': item.product.id,
          'shop_id': shopId,
          'staff_id': staffId,
          'change_type': 'sell',
          'quantity': -item.quantity,
          'created_at': now,
          'notes': 'Sale: bill $billId',
        });
      }

      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Failed to save bill: $e',
      ));
    }
  }

  Future<void> _onValidateStockBeforeBill(
      ValidateStockBeforeBill event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty'));
      return;
    }

    emit(state.copyWith(
      isValidatingStock: true,
      stockErrors: null,
    ));

    final errors = await _validateStock(state.cartItems);

    if (errors != null && errors.isNotEmpty) {
      emit(state.copyWith(
        isValidatingStock: false,
        stockErrors: errors,
      ));
    } else {
      // Stock is sufficient, proceed to submit bill
      emit(state.copyWith(
        isValidatingStock: false,
        stockErrors: null,
      ));
      add(const SubmitBillEvent());
    }
  }

  void _onClearStockErrors(
      ClearStockErrorsEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(clearStockErrors: true));
  }

  void _onUpdateCustomerInfo(
      UpdateCustomerInfoEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(
      customerName: event.customerName,
      customerPhone: event.customerPhone,
    ));
  }

  /// Validates cart item quantities against current stock in Supabase.
  /// Returns a list of error messages if any item has insufficient stock,
  /// or null if all items have sufficient stock.
  Future<List<String>?> _validateStock(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) return null;

    final productIds = cartItems.map((item) => item.product.id).toList();

    final shopId = authBloc.state is Authenticated
        ? (authBloc.state as Authenticated).user.shopId
        : null;

    final result =
        await getCurrentStockBulkUseCase(productIds, shopId: shopId);

    return result.fold(
      (failure) => ['Stock validation failed: ${failure.message}'],
      (stockMap) {
        final errors = <String>[];

        for (final item in cartItems) {
          final availableStock = stockMap[item.product.id];
          if (availableStock == null) {
            errors.add(
                '${item.product.name}: Product not found in inventory');
          } else if (availableStock < item.quantity) {
            errors.add(
                '${item.product.name} only has $availableStock in stock (requested ${item.quantity})');
          }
        }

        return errors.isNotEmpty ? errors : null;
      },
    );
  }
}
