import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';
import 'package:billing_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;
  final AuthBloc authBloc;

  CustomerBloc({
    required this.repository,
    required this.authBloc,
  }) : super(const CustomerState()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<GetCustomerDetail>(_onGetCustomerDetail);
    on<ClearCustomerMessage>(_onClearCustomerMessage);
  }

  /// Resolve the current shop id from the authenticated user, mirroring the
  /// DuePaymentsBloc convention. Falls back to null (the repository then
  /// resolves the shop from the logged-in Supabase user's profile).
  String? get _currentShopId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.shopId;
    }
    return null;
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, clearError: true));

    try {
      final result =
          await repository.getCustomers(shopId: _currentShopId);
      result.fold(
        (failure) => emit(state.copyWith(
              isLoading: false,
              error: failure.message,
            )),
        (customers) => emit(state.copyWith(
              isLoading: false,
              customers: customers,
              error: null,
              clearError: true,
            )),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load customers: $e',
      ));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, clearError: true));

    try {
      final result = await repository.getCustomers(
        shopId: _currentShopId,
        searchQuery: event.query,
      );
      result.fold(
        (failure) => emit(state.copyWith(
              isLoading: false,
              error: failure.message,
            )),
        (customers) => emit(state.copyWith(
              isLoading: false,
              customers: customers,
              error: null,
              clearError: true,
            )),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to search customers: $e',
      ));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      clearError: true,
      successMessage: null,
      clearSuccessMessage: true,
    ));

    try {
      // Pass null when the shop can't be resolved from AuthBloc so the
      // repository falls back to the logged-in Supabase user's profile.
      // (Passing '' would silently insert an empty shop_id instead.)
      final result = await repository.addCustomer(
        name: event.name,
        phone: event.phone,
        shopId: _currentShopId,
      );

      result.fold(
        (failure) => emit(state.copyWith(
              isLoading: false,
              error: failure.message,
            )),
        (customer) {
          emit(state.copyWith(
            isLoading: false,
            successMessage: 'Customer added successfully',
          ));
          // Reload the list so the new customer appears immediately.
          add(const LoadCustomers());
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to add customer: $e',
      ));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      clearError: true,
      successMessage: null,
      clearSuccessMessage: true,
    ));

    try {
      final result = await repository.updateCustomer(event.customer);
      result.fold(
        (failure) => emit(state.copyWith(
              isLoading: false,
              error: failure.message,
            )),
        (customer) {
          emit(state.copyWith(
            isLoading: false,
            successMessage: 'Customer updated successfully',
          ));
          // Reload so the updated fields show up immediately.
          add(const LoadCustomers());
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update customer: $e',
      ));
    }
  }

  Future<void> _onGetCustomerDetail(
    GetCustomerDetail event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, clearError: true));

    try {
      final result = await repository.getCustomerDetail(event.customerId);
      result.fold(
        (failure) => emit(state.copyWith(
              isLoading: false,
              error: failure.message,
            )),
        (customer) => emit(state.copyWith(
              isLoading: false,
              selectedCustomer: customer,
              error: null,
              clearError: true,
            )),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to fetch customer detail: $e',
      ));
    }
  }

  Future<void> _onClearCustomerMessage(
    ClearCustomerMessage event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      error: null,
      clearError: true,
      successMessage: null,
      clearSuccessMessage: true,
    ));
  }
}
