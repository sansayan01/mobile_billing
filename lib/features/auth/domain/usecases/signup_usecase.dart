import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return repository.signUp(params.email, params.password, params.name);
  }
}
