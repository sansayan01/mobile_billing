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

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
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
