import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/core/utils/phone_utils.dart';
import 'package:billing_app/features/customer/data/models/customer_model.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';
import 'package:billing_app/features/customer/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
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
  Future<Either<Failure, List<Customer>>> getCustomers({
    String? shopId,
    String? searchQuery,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('customers').select();

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        // Sanitize PostgREST .or() delimiters — a raw comma/percent in the
        // query breaks the filter syntax and crashes the request.
        final sanitized = searchQuery
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[,()%*]'), '');
        if (sanitized.isNotEmpty) {
          query = query.or('name.ilike.%$sanitized%,phone.ilike.%$sanitized%');
        }
      }

      final response = await query.order('created_at', ascending: false);

      final customers = (response as List<dynamic>)
          .map((row) =>
              CustomerModel.fromJson(row as Map<String, dynamic>).toEntity())
          .toList();

      return Right(customers);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch customers: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer?>> findCustomerByPhone(
    String phone,
    String shopId,
  ) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final normalized = normalizePhone(phone);
      var query = _supabase
          .from('customers')
          .select()
          .eq('phone', normalized);

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      final row = await query.maybeSingle();
      if (row == null) return const Right(null);

      return Right(CustomerModel.fromJson(row).toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to find customer: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> addCustomer({
    required String name,
    required String phone,
    String? shopId,
  }) async {
    try {
      // Treat null OR empty string as "resolve from the Supabase user's profile".
      final effectiveShopId = await _resolveShopId(
        (shopId == null || shopId.isEmpty) ? null : shopId,
      );
      final normalized = normalizePhone(phone);

      if (effectiveShopId == null || effectiveShopId.isEmpty) {
        return const Left(ServerFailure(
          'Could not determine the current shop. Make sure you are logged in.',
        ));
      }

      final data = {
        'shop_id': effectiveShopId,
        'name': name,
        'phone': normalized,
      };

      final response = await _supabase
          .from('customers')
          .insert(data)
          .select()
          .single();

      return Right(CustomerModel.fromJson(response).toEntity());
    } on PostgrestException catch (e) {
      // 23505 = unique_violation. This branch only triggers because the
      // customers table has a unique index on (shop_id, phone); without that
      // index duplicates would insert silently instead of erroring here.
      if (e.code == '23505') {
        return const Left(ServerFailure('Customer with this phone already exists'));
      }
      return Left(ServerFailure('Failed to add customer: $e'));
    } catch (e) {
      return Left(ServerFailure('Failed to add customer: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerDetail(
    String customerId,
  ) async {
    try {
      final row = await _supabase
          .from('customers')
          .select()
          .eq('id', customerId)
          .maybeSingle();

      if (row == null) {
        return const Left(ServerFailure('Customer not found'));
      }

      return Right(CustomerModel.fromJson(row).toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to fetch customer detail: $e'));
    }
  }
}
