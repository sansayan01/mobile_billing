import 'package:equatable/equatable.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Email verification pending state — signUp hua par email confirm nahi hua.
/// [email] store karte hain taaki verification screen par dikhayein.
class EmailVerificationPending extends AuthState {
  final String email;

  const EmailVerificationPending(this.email);

  @override
  List<Object?> get props => [email];
}

/// Resend verification email request successful ho gaya.
class ResendEmailSent extends AuthState {
  final String email;

  const ResendEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Resend verification email fail ho gaya (error message ke saath).
class ResendEmailError extends AuthState {
  final String email;
  final String message;

  const ResendEmailError(this.email, this.message);

  @override
  List<Object?> get props => [email, message];
}
