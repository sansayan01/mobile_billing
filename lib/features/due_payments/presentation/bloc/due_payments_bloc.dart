import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billing_app/features/due_payments/domain/entities/due_payment.dart';
import 'package:billing_app/features/due_payments/domain/repositories/due_payments_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';

part 'due_payments_event.dart';
part 'due_payments_state.dart';

class DuePaymentsBloc extends Bloc<DuePaymentsEvent, DuePaymentsState> {
  final DuePaymentsRepository repository;
  final AuthBloc authBloc;

  DuePaymentsBloc({
    required this.repository,
    required this.authBloc,
  }) : super(const DuePaymentsState()) {
    on<LoadDuePayments>(_onLoadDuePayments);
    on<CollectPayment>(_onCollectPayment);
    on<SearchDuePayments>(_onSearchDuePayments);
  }

  String? get _currentShopId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.shopId;
    }
    return null;
  }

  Future<void> _onLoadDuePayments(
    LoadDuePayments event,
    Emitter<DuePaymentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repository.getDuePayments(shopId: _currentShopId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (duePayments) {
        final totalDue = duePayments.fold<double>(
          0, (sum, payment) => sum + payment.dueAmount,
        );
        emit(state.copyWith(
          isLoading: false,
          duePayments: duePayments,
          totalPendingDue: totalDue,
        ));
      },
    );
  }

  Future<void> _onCollectPayment(
    CollectPayment event,
    Emitter<DuePaymentsState> emit,
  ) async {
    emit(state.copyWith(isCollecting: true, error: null, successMessage: null));

    final result = await repository.collectPayment(
      billId: event.billId,
      amount: event.amount,
      shopId: _currentShopId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isCollecting: false,
        error: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isCollecting: false,
          successMessage: 'Payment of ₹${event.amount.toStringAsFixed(2)} collected successfully!',
        ));
        // Reload due payments after collection
        add(const LoadDuePayments());
      },
    );
  }

  Future<void> _onSearchDuePayments(
    SearchDuePayments event,
    Emitter<DuePaymentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, searchQuery: event.query));

    final result = await repository.getDuePayments(
      shopId: _currentShopId,
      searchQuery: event.query,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (duePayments) {
        final totalDue = duePayments.fold<double>(
          0, (sum, payment) => sum + payment.dueAmount,
        );
        emit(state.copyWith(
          isLoading: false,
          duePayments: duePayments,
          totalPendingDue: totalDue,
        ));
      },
    );
  }
}
