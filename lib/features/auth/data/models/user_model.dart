import 'package:billing_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role = 'staff',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
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

    if (profile != null) {
      name = profile['name'] as String? ?? email.split('@').first;
      role = profile['role'] as String? ?? 'staff';
    } else {
      name = email.split('@').first;
      role = 'staff';
    }

    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
    );
  }

  /// Creates a UserModel from a 'profiles' table row JSON.
  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
    );
  }
}
