import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.loginWithGoogle();
  }
}
