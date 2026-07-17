import 'package:billing_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role = 'staff',
    super.shopId,
    super.emailConfirmedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      shopId: json['shop_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'shop_id': shopId,
    };
  }

  /// Creates a UserModel from a Supabase auth User and an optional profile row
  /// from the 'profiles' table.
  factory UserModel.fromSupabaseAuth(
    dynamic supabaseUser,
    Map<String, dynamic>? profile,
  ) {
    final String id = supabaseUser.id as String;
    final String email = supabaseUser.email as String? ?? '';
    final String name;
    final String role;
    final String? shopId;
    final DateTime? emailConfirmedAt =
        supabaseUser.emailConfirmedAt == null
            ? null
            : DateTime.tryParse(supabaseUser.emailConfirmedAt as String);

    if (profile != null) {
      name = profile['name'] as String? ?? email.split('@').first;
      role = profile['role'] as String? ?? 'staff';
      shopId = profile['shop_id'] as String?;
    } else {
      name = email.split('@').first;
      role = 'staff';
      shopId = null;
    }

    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
      shopId: shopId,
      emailConfirmedAt: emailConfirmedAt,
    );
  }

  /// Creates a UserModel from a 'profiles' table row JSON.
  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      shopId: json['shop_id'] as String?,
    );
  }
}
