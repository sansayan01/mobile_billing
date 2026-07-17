import 'package:equatable/equatable.dart';

/// 3-tier role system:
///  - [superAdmin] → SaaS product admin, cross-shop access (manual assign only)
///  - [owner]      → shop owner, auto-assigned on signup + gets own shop
///  - [staff]      → employee added by an owner
enum UserRole {
  superAdmin('super_admin'),
  owner('owner'),
  staff('staff');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.staff;
    }
  }
}

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'super_admin' | 'owner' | 'staff'
  final String? shopId; // staff/owner ki associated shop (nullable)
  final String? phone; // contact number (staff management)
  final DateTime? emailConfirmedAt; // null = email abhi confirm nahi hui

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'staff',
    this.shopId,
    this.phone,
    this.emailConfirmedAt,
  });

  /// Typed accessor for the role.
  UserRole get userRole => UserRole.fromString(role);

  bool get isSuperAdmin => userRole == UserRole.superAdmin;
  bool get isOwner => userRole == UserRole.owner;
  bool get isStaff => userRole == UserRole.staff;

  /// True jab email confirm ho chuki hai.
  bool get isEmailConfirmed => emailConfirmedAt != null;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? shopId,
    String? phone,
    DateTime? emailConfirmedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      phone: phone ?? this.phone,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, name, role, shopId, phone, emailConfirmedAt];
}
