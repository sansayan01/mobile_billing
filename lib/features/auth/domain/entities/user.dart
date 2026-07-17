import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'owner' or 'staff'
  final String? shopId; // staff/owner ki associated shop (nullable)
  final DateTime? emailConfirmedAt; // null = email abhi confirm nahi hui

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'staff',
    this.shopId,
    this.emailConfirmedAt,
  });

  /// True jab email confirm ho chuki hai.
  bool get isEmailConfirmed => emailConfirmedAt != null;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? shopId,
    DateTime? emailConfirmedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, name, role, shopId, emailConfirmedAt];
}
