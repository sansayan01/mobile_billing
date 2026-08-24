import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/due_payments/domain/entities/due_payment.dart';
import 'package:billing_app/features/due_payments/domain/repositories/due_payments_repository.dart';

class DuePaymentsRepositoryImpl implements DuePaymentsRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Resolve shopId: if not provided, fetch from current user's profile.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null) return shopId;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final profile = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        return profile['shop_id'] as String?;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<Either<Failure, List<DuePayment>>> getDuePayments({
    String? shopId,
    String? searchQuery,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('bills')
          .select('*, profiles(name)')
          .inFilter('payment_status', ['partial', 'due'])
          .gt('due_amount', 0);

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      // Add search filter for customer name or bill ID
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        query = query.or('customer_name.ilike.%$term%,id.ilike.%$term%');
      }

      final response = await query.order('created_at', ascending: false);

      final duePayments = (response as List<dynamic>).map((row) {
        final profileData = row['profiles'] as Map<String, dynamic>?;
        final staffName = profileData?['name'] as String? ?? 'Unknown';

        return DuePayment(
          billId: row['id'] as String,
          customerName: row['customer_name'] as String?,
          customerPhone: row['customer_phone'] as String?,
          grandTotal: (row['grand_total'] as num?)?.toDouble() ?? 0.0,
          amountPaid: (row['amount_paid'] as num?)?.toDouble() ?? 0.0,
          dueAmount: (row['due_amount'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: row['payment_method'] as String? ?? 'Unknown',
          staffName: staffName,
          billDate: DateTime.parse(row['created_at'] as String),
        );
      }).toList();

      return Right(duePayments);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch due payments: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPendingDue({
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('bills')
          .select('due_amount')
          .inFilter('payment_status', ['partial', 'due'])
          .gt('due_amount', 0);

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      final response = await query;

      double totalDue = 0.0;
      for (final row in response as List<dynamic>) {
        totalDue += (row['due_amount'] as num?)?.toDouble() ?? 0.0;
      }

      return Right(totalDue);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch total due: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> collectPayment({
    required String billId,
    required double amount,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);

      // 1. Fetch current bill
      var billQuery = _supabase
          .from('bills')
          .select('grand_total, amount_paid, due_amount')
          .eq('id', billId);

      if (effectiveShopId != null) {
        billQuery = billQuery.eq('shop_id', effectiveShopId);
      }

      final billRow = await billQuery.maybeSingle();
      if (billRow == null) {
        return Left(ServerFailure('Bill not found'));
      }

      final currentAmountPaid = (billRow['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final currentDueAmount = (billRow['due_amount'] as num?)?.toDouble() ?? 0.0;

      // 2. Validate payment amount
      if (amount <= 0) {
        return Left(ServerFailure('Payment amount must be greater than 0'));
      }
      if (amount > currentDueAmount) {
        return Left(ServerFailure('Payment amount exceeds due amount'));
      }

      // 3. Calculate new values
      final newAmountPaid = currentAmountPaid + amount;
      final newDueAmount = currentDueAmount - amount;
      String newPaymentStatus;
      if (newDueAmount <= 0) {
        newPaymentStatus = 'paid';
      } else {
        newPaymentStatus = 'partial';
      }

      // 4. Update bill
      var updateQuery = _supabase
          .from('bills')
          .update({
        'amount_paid': newAmountPaid,
        'due_amount': newDueAmount < 0 ? 0 : newDueAmount,
        'payment_status': newPaymentStatus,
      }).eq('id', billId);

      if (effectiveShopId != null) {
        updateQuery = updateQuery.eq('shop_id', effectiveShopId);
      }

      await updateQuery;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to collect payment: $e'));
    }
  }

  @override
  Future<Either<Failure, DuePayment>> getBillForDuePayment({
    required String billId,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('bills')
          .select('*, profiles(name)')
          .eq('id', billId);

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      final row = await query.maybeSingle();
      if (row == null) {
        return Left(ServerFailure('Bill not found'));
      }

      final profileData = row['profiles'] as Map<String, dynamic>?;
      final staffName = profileData?['name'] as String? ?? 'Unknown';

      final duePayment = DuePayment(
        billId: row['id'] as String,
        customerName: row['customer_name'] as String?,
        customerPhone: row['customer_phone'] as String?,
        grandTotal: (row['grand_total'] as num?)?.toDouble() ?? 0.0,
        amountPaid: (row['amount_paid'] as num?)?.toDouble() ?? 0.0,
        dueAmount: (row['due_amount'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: row['payment_method'] as String? ?? 'Unknown',
        staffName: staffName,
        billDate: DateTime.parse(row['created_at'] as String),
      );

      return Right(duePayment);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bill: $e'));
    }
  }
}
