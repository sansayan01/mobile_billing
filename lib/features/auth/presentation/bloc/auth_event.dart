import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role; // 'owner' ya 'staff'
  final String? shopName; // owner signup ke liye shop ka naam
  final String? shopId; // owner staff create kare toh apni shop_id pass kare

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'staff',
    this.shopName,
    this.shopId,
  });

  @override
  List<Object?> get props => [email, password, name, role, shopName, shopId];
}

class GoogleLoginRequested extends AuthEvent {
  const GoogleLoginRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Resend verification email request — pending verification screen se aayega.
class ResendVerificationEmailRequested extends AuthEvent {
  final String email;

  const ResendVerificationEmailRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? role;

  const UpdateProfileRequested({
    required this.name,
    this.role,
  });

  @override
  List<Object?> get props => [name, role];
}
