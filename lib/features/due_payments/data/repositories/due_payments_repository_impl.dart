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

      // Add search filter for customer name or phone. NOTE: do NOT include
      // id.ilike here — PostgREST .or() breaks on UUID hyphens/format and any
      // unescaped comma/percent in the term crashes the whole query.
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final sanitized = searchQuery
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[,()%*]'), '');
        if (sanitized.isNotEmpty) {
          query = query.or(
            'customer_name.ilike.%$sanitized%,customer_phone.ilike.%$sanitized%',
          );
        }
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
        return const Left(ServerFailure('Bill not found'));
      }

      final currentAmountPaid = (billRow['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final currentDueAmount = (billRow['due_amount'] as num?)?.toDouble() ?? 0.0;

      // 2. Validate payment amount
      if (amount <= 0) {
        return const Left(ServerFailure('Payment amount must be greater than 0'));
      }
      if (amount > currentDueAmount) {
        return const Left(ServerFailure('Payment amount exceeds due amount'));
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
      // NOTE (accepted race): fetch -> compute -> update is not atomic. Two
      // concurrent collects on the same bill could read the same amount_paid
      // and one write would be lost. PostgREST has no server-side increment,
      // so a safe fix needs an RPC/transaction — intentionally out of scope
      // for this minimal fix.
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
}
