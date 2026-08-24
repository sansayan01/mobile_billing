import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/due_payments/domain/entities/due_payment.dart';

abstract class DuePaymentsRepository {
  /// Get all pending due payments
  Future<Either<Failure, List<DuePayment>>> getDuePayments({
    String? shopId,
    String? searchQuery,
  });

  /// Get total pending due amount across all bills
  Future<Either<Failure, double>> getTotalPendingDue({
    String? shopId,
  });

  /// Collect partial payment for a bill
  Future<Either<Failure, void>> collectPayment({
    required String billId,
    required double amount,
    String? shopId,
  });

  /// Get bill detail for due payment
  Future<Either<Failure, DuePayment>> getBillForDuePayment({
    required String billId,
    String? shopId,
  });
}
