part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final double? discount;
  final bool discountIsPercentage;
  final double? grandTotalOverride;
  final bool isSubmitting;
  final bool submitSuccess;
  final List<String>? stockErrors;
  final bool isValidatingStock;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.discount,
    this.discountIsPercentage = false,
    this.grandTotalOverride,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.stockErrors,
    this.isValidatingStock = false,
  });

  double get totalAmount {
    final base = cartItems.fold<double>(0, (sum, item) => sum + item.total);

    // Grand total override takes highest priority
    if (grandTotalOverride != null) {
      return grandTotalOverride! < 0 ? 0 : grandTotalOverride!;
    }

    // Apply discount
    if (discount != null && discount! > 0) {
      double result;
      if (discountIsPercentage) {
        result = base * (1 - discount! / 100);
      } else {
        result = base - discount!;
      }
      return result < 0 ? 0 : result;
    }

    return base;
  }

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    double? discount,
    bool clearDiscount = false,
    bool? discountIsPercentage,
    double? grandTotalOverride,
    bool clearGrandTotalOverride = false,
    bool? isSubmitting,
    bool? submitSuccess,
    List<String>? stockErrors,
    bool clearStockErrors = false,
    bool? isValidatingStock,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      discount: clearDiscount ? null : (discount ?? this.discount),
      discountIsPercentage:
          discountIsPercentage ?? this.discountIsPercentage,
      grandTotalOverride: clearGrandTotalOverride
          ? null
          : (grandTotalOverride ?? this.grandTotalOverride),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      stockErrors: clearStockErrors ? null : (stockErrors ?? this.stockErrors),
      isValidatingStock: isValidatingStock ?? this.isValidatingStock,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        isPrinting,
        printSuccess,
        discount,
        discountIsPercentage,
        grandTotalOverride,
        isSubmitting,
        submitSuccess,
        stockErrors,
        isValidatingStock,
      ];
}
