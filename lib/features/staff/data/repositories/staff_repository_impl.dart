import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Resolve shopId: if not provided, fetch from current user's profile.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null && shopId.isNotEmpty) return shopId;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final row = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', userId)
          .maybeSingle();
      if (row is Map<String, dynamic>) return row['shop_id'] as String?;
    } catch (_) {}
    return null;
  }

  @override
  Future<Either<Failure, List<User>>> getStaffMembers({String? shopId}) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('profiles').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false);

      final staff = (response as List<dynamic>)
          .map((e) => UserModel.fromProfileJson(e as Map<String, dynamic>))
          .toList();

      return Right(staff);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch staff: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStaffMember(String id,
      {String? shopId}) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('profiles').delete().eq('id', id);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      await query;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete staff: $e'));
    }
  }
}
