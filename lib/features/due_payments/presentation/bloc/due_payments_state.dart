part of 'due_payments_bloc.dart';

class DuePaymentsState extends Equatable {
  final List<DuePayment> duePayments;
  final double totalPendingDue;
  final bool isLoading;
  final bool isCollecting;
  final String? error;
  final String? successMessage;
  final String? searchQuery;

  const DuePaymentsState({
    this.duePayments = const [],
    this.totalPendingDue = 0.0,
    this.isLoading = false,
    this.isCollecting = false,
    this.error,
    this.successMessage,
    this.searchQuery,
  });

  DuePaymentsState copyWith({
    List<DuePayment>? duePayments,
    double? totalPendingDue,
    bool? isLoading,
    bool? isCollecting,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return DuePaymentsState(
      duePayments: duePayments ?? this.duePayments,
      totalPendingDue: totalPendingDue ?? this.totalPendingDue,
      isLoading: isLoading ?? this.isLoading,
      isCollecting: isCollecting ?? this.isCollecting,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
        duePayments,
        totalPendingDue,
        isLoading,
        isCollecting,
        error,
        successMessage,
        searchQuery,
      ];
}
