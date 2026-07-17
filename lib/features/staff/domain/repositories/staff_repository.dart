import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';

abstract class StaffRepository {
  Future<Either<Failure, List<User>>> getStaffMembers({String? shopId});
  Future<Either<Failure, void>> deleteStaffMember(String id, {String? shopId});
}
