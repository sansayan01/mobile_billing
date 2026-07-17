import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signUp(
      String email, String password, String name);
  Future<Either<Failure, User>> loginWithGoogle();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, User>> updateProfile(String name, String? role);
  Stream<User?> get authStateChanges;
}
