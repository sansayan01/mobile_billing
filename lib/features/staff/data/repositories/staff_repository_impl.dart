import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  @override
  Future<Either<Failure, List<User>>> getStaffMembers({String? shopId}) async {
    try {
      var query = _supabase.from('profiles').select();
      if (shopId != null) {
        query = query.eq('shop_id', shopId);
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
      await _supabase.from('profiles').delete().eq('id', id);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete staff: $e'));
    }
  }
}
