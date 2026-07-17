import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  /// Helper to fetch a user profile from the 'profiles' table.
  /// Returns null if the profile doesn't exist yet (e.g., during signup
  /// before the DB trigger has created the row).
  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      // maybeSingle() returns dynamic; we cast it safely
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      // Log and return null — caller decides how to handle
      return null;
    }
  }

  /// Creates a profile row in the 'profiles' table.
  Future<void> _createProfile({
    required String id,
    required String email,
    required String name,
    String role = 'staff',
  }) async {
    await SupabaseConfig.client.from('profiles').insert({
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    });
  }

  @override
  Future<Either<Failure, User>> login(
      String email, String password) async {
    try {
      final response = await SupabaseConfig.client.auth
          .signInWithPassword(email: email, password: password);

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        return Left(const ServerFailure('Login failed. No user returned.'));
      }

      final profile = await _fetchProfile(supabaseUser.id);
      final user = UserModel.fromSupabaseAuth(supabaseUser, profile);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Login failed: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(
      String email, String password, String name) async {
    try {
      final response = await SupabaseConfig.client.auth
          .signUp(email: email, password: password);

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        return Left(const ServerFailure('Sign up failed. No user returned.'));
      }

      // Create the profile row manually.
      // A DB trigger may also do this, but we ensure it exists here.
      try {
        await _createProfile(
          id: supabaseUser.id,
          email: email,
          name: name,
        );
      } catch (_) {
        // Profile may already exist from trigger — ignore conflict
      }

      final profile = await _fetchProfile(supabaseUser.id);
      final user = UserModel.fromSupabaseAuth(supabaseUser, profile);
      return Right(user);
    } catch (e) {
      return Left(
          ServerFailure('Sign up failed: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    try {
      // On mobile, this opens the system browser for Google OAuth.
      // The user authenticates there, and Supabase redirects back to the app
      // via the deep-link URL 'io.supabase.flutter://callback'.
      //
      // REQUIRED SETUP for the redirect to work:
      //
      // Android — In android/app/src/main/AndroidManifest.xml, add an intent-filter:
      //   <intent-filter>
      //     <action android:name="android.intent.action.VIEW" />
      //     <category android:name="android.intent.category.DEFAULT" />
      //     <category android:name="android.intent.category.BROWSABLE" />
      //     <data android:scheme="io.supabase.flutter" android:host="callback" />
      //   </intent-filter>
      //
      // iOS — In ios/Runner/Info.plist, add:
      //   <key>CFBundleURLTypes</key>
      //   <array>
      //     <dict>
      //       <key>CFBundleURLSchemes</key>
      //       <array>
      //         <string>io.supabase.flutter</string>
      //       </array>
      //     </dict>
      //   </array>
      //
      // Also set the redirect URL in your Supabase Dashboard:
      //   Authentication → URL Configuration → Redirect URLs
      //   Add: io.supabase.flutter://callback

      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );

      // After the browser flow completes, Supabase returns to the app
      // and the session becomes available. We wait briefly for the
      // auth state to update with the new session.
      //
      // A more robust approach is to listen on authStateChanges, but for
      // simplicity we poll currentUser after a short delay.
      await Future.delayed(const Duration(seconds: 1));

      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser == null) {
        return Left(
            const ServerFailure('Google login failed. No user returned.'));
      }

      final profile = await _fetchProfile(supabaseUser.id);

      // If no profile exists yet (first-time Google login), create one.
      if (profile == null) {
        final displayName =
            supabaseUser.userMetadata?['full_name'] as String? ??
                supabaseUser.email?.split('@').first ??
                'User';
        try {
          await _createProfile(
            id: supabaseUser.id,
            email: supabaseUser.email ?? '',
            name: displayName,
          );
        } catch (_) {
          // Ignore if profile already exists
        }
      }

      final updatedProfile = await _fetchProfile(supabaseUser.id);
      final user =
          UserModel.fromSupabaseAuth(supabaseUser, updatedProfile);
      return Right(user);
    } catch (e) {
      return Left(
          ServerFailure('Google login failed: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure('Logout failed: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser == null) {
        return const Right(null);
      }

      final profile = await _fetchProfile(supabaseUser.id);
      final user = UserModel.fromSupabaseAuth(supabaseUser, profile);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(
          'Failed to get current user: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      String name, String? role) async {
    try {
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser == null) {
        return Left(const ServerFailure('No authenticated user.'));
      }

      final updates = <String, dynamic>{
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (role != null) {
        updates['role'] = role;
      }

      await SupabaseConfig.client
          .from('profiles')
          .update(updates)
          .eq('id', supabaseUser.id);

      final profile = await _fetchProfile(supabaseUser.id);
      final user = UserModel.fromSupabaseAuth(supabaseUser, profile);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(
          'Failed to update profile: ${_extractErrorMessage(e)}'));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return SupabaseConfig.client.auth.onAuthStateChange.asyncMap(
      (authState) async {
        final supabaseUser = authState.session?.user;
        if (supabaseUser == null) return null;

        try {
          final profile = await _fetchProfile(supabaseUser.id);
          return UserModel.fromSupabaseAuth(supabaseUser, profile);
        } catch (_) {
          return UserModel.fromSupabaseAuth(supabaseUser, null);
        }
      },
    );
  }

  /// Extracts a human-readable message from various error types thrown by
  /// Supabase (AuthException, PostgrestException, or generic Exception).
  String _extractErrorMessage(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }
}
