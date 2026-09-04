import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';

abstract class CustomerRepository {
  /// Get customers for a shop, optionally filtered by a name/phone search query.
  Future<Either<Failure, List<Customer>>> getCustomers({
    String? shopId,
    String? searchQuery,
  });

  /// Find a single customer by their (normalized) phone number within a shop.
  Future<Either<Failure, Customer?>> findCustomerByPhone(
    String phone,
    String shopId,
  );

  /// Add a new customer. Returns a Failure if the phone already exists for the shop.
  /// [shopId] may be null — the repository then resolves the shop from the
  /// logged-in Supabase user's profile.
  Future<Either<Failure, Customer>> addCustomer({
    required String name,
    required String phone,
    String? shopId,
  });

  /// Fetch a single customer's detail by id.
  Future<Either<Failure, Customer>> getCustomerDetail(String customerId);

  /// Update an existing customer's name/phone. Phone uniqueness per shop is
  /// enforced server-side (unique index); surfaced as a Failure here.
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);
}
