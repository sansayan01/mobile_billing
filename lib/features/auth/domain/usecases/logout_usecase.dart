import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
