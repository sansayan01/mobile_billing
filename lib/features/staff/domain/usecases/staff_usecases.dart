import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/staff/domain/repositories/staff_repository.dart';

class GetStaffMembersUseCase implements UseCase<List<User>, NoParams> {
  final StaffRepository repository;

  GetStaffMembersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params,
      {String? shopId}) {
    return repository.getStaffMembers(shopId: shopId);
  }
}

class DeleteStaffMemberUseCase implements UseCase<void, String> {
  final StaffRepository repository;

  DeleteStaffMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params, {String? shopId}) {
    return repository.deleteStaffMember(params, shopId: shopId);
  }
}
