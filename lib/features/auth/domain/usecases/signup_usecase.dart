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
  final String role; // 'owner' (default self-signup) | 'staff' (owner adds) | 'super_admin' (manual only)
  final String? shopName; // sirf owner signup ke liye — apni shop ka naam
  final String? emailRedirectTo; // verification deep-link (billingapp://verify)
  final String? shopId; // owner ne staff create kiya toh apni shop_id pass kare

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'owner', // naya signup hamesha owner banta hai (apni shop ke)
    this.shopName,
    this.emailRedirectTo,
    this.shopId,
  });

  @override
  List<Object?> get props =>
      [email, password, name, role, shopName, emailRedirectTo, shopId];
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
      shopId: params.shopId,
    );
  }
}
