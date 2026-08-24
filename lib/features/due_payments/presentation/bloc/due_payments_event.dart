part of 'due_payments_bloc.dart';

abstract class DuePaymentsEvent extends Equatable {
  const DuePaymentsEvent();
  @override
  List<Object> get props => [];
}

class LoadDuePayments extends DuePaymentsEvent {
  const LoadDuePayments();
}

class CollectPayment extends DuePaymentsEvent {
  final String billId;
  final double amount;

  const CollectPayment({
    required this.billId,
    required this.amount,
  });

  @override
  List<Object> get props => [billId, amount];
}

class SearchDuePayments extends DuePaymentsEvent {
  final String? query;

  const SearchDuePayments(this.query);

  @override
  List<Object> get props => [query ?? ''];
}
