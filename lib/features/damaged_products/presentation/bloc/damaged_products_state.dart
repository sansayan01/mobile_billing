part of 'damaged_products_bloc.dart';

class DamagedProductsState extends Equatable {
  final List<DamagedProduct> damagedProducts;
  final double totalLoss;
  final int totalCount;
  final bool isLoading;
  final bool isMarking;
  final String? error;
  final String? successMessage;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const DamagedProductsState({
    this.damagedProducts = const [],
    this.totalLoss = 0.0,
    this.totalCount = 0,
    this.isLoading = false,
    this.isMarking = false,
    this.error,
    this.successMessage,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  DamagedProductsState copyWith({
    List<DamagedProduct>? damagedProducts,
    double? totalLoss,
    int? totalCount,
    bool? isLoading,
    bool? isMarking,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? searchQuery,
    bool clearSearchQuery = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return DamagedProductsState(
      damagedProducts: damagedProducts ?? this.damagedProducts,
      totalLoss: totalLoss ?? this.totalLoss,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isMarking: isMarking ?? this.isMarking,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      searchQuery:
          clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [
        damagedProducts,
        totalLoss,
        totalCount,
        isLoading,
        isMarking,
        error,
        successMessage,
        searchQuery,
        startDate,
        endDate,
      ];
}
