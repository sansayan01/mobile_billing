part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  const LoadCustomers();
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCustomer extends CustomerEvent {
  final String name;
  final String phone;

  const AddCustomer({required this.name, required this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class GetCustomerDetail extends CustomerEvent {
  final String customerId;

  const GetCustomerDetail(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class ClearCustomerMessage extends CustomerEvent {
  const ClearCustomerMessage();
}
