import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/warranty_claim.dart';
import '../../domain/repositories/warranty_repository.dart';

class WarrantyRepositoryImpl implements WarrantyRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

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

  WarrantyClaim _fromMap(Map<String, dynamic> data) {
    return WarrantyClaim(
      id: data['id'] as String,
      billId: data['bill_id'] as String,
      productId: data['product_id'] as String,
      productName: data['product_name'] as String,
      customerName: data['customer_name'] as String?,
      customerPhone: data['customer_phone'] as String?,
      claimReason: data['claim_reason'] as String,
      claimStatus: data['claim_status'] as String? ?? 'pending',
      claimType: data['claim_type'] as String? ?? 'warranty',
      warrantyDuration: data['warranty_duration'] as int?,
      warrantyUnit: data['warranty_unit'] as String?,
      claimedByStaffId: data['claimed_by_staff_id'] as String?,
      staffName: data['staff_name'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }

  @override
  Future<Either<Failure, WarrantyClaim>> createClaim(
    WarrantyClaim claim, {
    String? shopId,
    String? customerId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final staffId = _supabase.auth.currentUser?.id;

      // Get staff name from profile
      String? staffName;
      if (staffId != null) {
        final profile = await _supabase
            .from('profiles')
            .select('name')
            .eq('id', staffId)
            .maybeSingle();
        staffName = profile?['name'] as String?;
      }

      final data = {
        'id': claim.id,
        'bill_id': claim.billId,
        'product_id': claim.productId,
        'product_name': claim.productName,
        'customer_name': claim.customerName,
        'customer_phone': claim.customerPhone,
        'claim_reason': claim.claimReason,
        'claim_status': claim.claimStatus,
        'claim_type': claim.claimType,
        'warranty_duration': claim.warrantyDuration,
        'warranty_unit': claim.warrantyUnit,
        'claimed_by_staff_id': staffId,
        'staff_name': staffName,
        'shop_id': effectiveShopId,
        'created_at': claim.createdAt.toUtc().toIso8601String(),
      };
      // Only include customer_id when actually provided — sending an explicit
      // null is harmless, but this keeps the insert payload identical to
      // before when no caller can supply a customer id yet.
      if (customerId != null && customerId.isNotEmpty) {
        data['customer_id'] = customerId;
      }

      await _supabase.from('warranty_claims').insert(data);

      return Right(claim.copyWith(claimedByStaffId: staffId, staffName: staffName));
    } catch (e) {
      return Left(ServerFailure('Failed to create warranty claim: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WarrantyClaim>>> getClaims({
    String? shopId,
    String? status,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('warranty_claims').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('claim_status', status);
      }
      final response = await query.order('created_at', ascending: false);

      final claims = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(claims);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch warranty claims: $e'));
    }
  }

  @override
  Future<Either<Failure, WarrantyClaim>> updateClaimStatus(
    String claimId,
    String status, {
    String? shopId,
  }) async {
    try {
      await _supabase
          .from('warranty_claims')
          .update({
            'claim_status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', claimId);

      // Fetch updated claim
      final response = await _supabase
          .from('warranty_claims')
          .select()
          .eq('id', claimId)
          .maybeSingle();

      if (response != null) {
        return Right(_fromMap(response));
      }

      return const Left(ServerFailure('Claim not found after update'));
    } catch (e) {
      return Left(ServerFailure('Failed to update claim status: $e'));
    }
  }
}
