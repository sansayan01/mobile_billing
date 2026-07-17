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
  final String role; // 'owner' ya 'staff'
  final String? shopName; // sirf owner signup ke liye — apni shop ka naam
  final String? emailRedirectTo; // verification deep-link (billingapp://verify)

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'staff',
    this.shopName,
    this.emailRedirectTo,
  });

  @override
  List<Object?> get props =>
      [email, password, name, role, shopName, emailRedirectTo];
}

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return repository.signUp(
      params.email,
      params.password,
      params.name,
      role: params.role,
      shopName: params.shopName,
      emailRedirectTo: params.emailRedirectTo,
    );
  }
}
