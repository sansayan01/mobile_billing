part of 'customer_bloc.dart';

class CustomerState extends Equatable {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CustomerState({
    this.customers = const [],
    this.selectedCustomer,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CustomerState copyWith({
    List<Customer>? customers,
    Customer? selectedCustomer,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        customers,
        selectedCustomer,
        isLoading,
        error,
        successMessage,
      ];
}
