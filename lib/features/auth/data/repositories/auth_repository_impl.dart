// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:billing_app/core/config/deep_link_config.dart';
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
    String? shopId,
  }) async {
    final insert = {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
    if (shopId != null) {
      insert['shop_id'] = shopId;
    }
    await SupabaseConfig.client.from('profiles').insert(insert);
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
    String email,
    String password,
    String name, {
    String role = 'owner',
    String? shopName,
    String? emailRedirectTo,
    String? shopId,
    String? phone,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
        data: {
          'name': name,
          'shop_name': shopName ?? '$name ki Shop',
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        return Left(const ServerFailure('Sign up failed. No user returned.'));
      }

      // DB trigger (handle_new_user) auto-creates the owner profile + shop
      // for every new signup. We only step in for the staff case (owner adds
      // an employee and passes their shopId) and as a best-effort fallback.
      if (role == 'staff' && shopId != null) {
        await _ensureProfileRole(
          userId: supabaseUser.id,
          role: 'staff',
          shopId: shopId,
          phone: phone,
        );
      }

      // Give the trigger a moment, then read back the final profile
      // (trigger-created). If it's not there yet, fetch once more.
      Map<String, dynamic>? profile = await _fetchProfile(supabaseUser.id);
      profile ??= await _fetchProfile(supabaseUser.id);

      final user = UserModel.fromSupabaseAuth(supabaseUser, profile);
      return Right(user);
    } catch (e) {
      return Left(
          ServerFailure('Sign up failed: ${_extractErrorMessage(e)}'));
    }
  }

  /// Best-effort: make sure a profile exists with the given role/shop.
  /// Used when the DB trigger hasn't run yet or for staff created by an owner.
  Future<void> _ensureProfileRole({
    required String userId,
    required String role,
    String? shopId,
    String? phone,
  }) async {
    try {
      final existing = await _fetchProfile(userId);
      final updates = <String, dynamic>{'role': role};
      if (shopId != null) updates['shop_id'] = shopId;
      // Best-effort phone update — RLS owner-row-only ho sakta hai, isliye
      // fail hone par silently ignore (trigger/metadata path fallback).
      if (phone != null && phone.trim().isNotEmpty) {
        updates['phone'] = phone.trim();
      }
      if (existing == null) {
        await _createProfile(
          id: userId,
          email: '',
          name: '',
          role: role,
          shopId: shopId,
        );
      } else {
        await SupabaseConfig.client
            .from('profiles')
            .update(updates)
            .eq('id', userId);
      }
    } catch (_) {
      // ignore — trigger will handle it
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

  /// Resends the email confirmation link for an unconfirmed user.
  /// Uses Supabase's `auth.resend` with [OtpType.signup] and the same
  /// deep-link redirect so the app re-opens after confirmation.
  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) async {
    try {
      await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: DeepLinkConfig.emailRedirectTo,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
          'Failed to resend email: ${_extractErrorMessage(e)}'));
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
        'updated_at': DateTime.now().toUtc().toIso8601String(),
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
      return _friendlyMessage(error.message);
    }
    if (error is PostgrestException) {
      return _friendlyMessage(error.message);
    }
    // SocketException / ClientException / parsing errors etc — never leak raw.
    return 'Something went wrong. Please try again.';
  }

  /// Maps known server messages to friendly copy; anything unknown, empty,
  /// or overly technical falls back to a generic line.
  String _friendlyMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password should be at least') ||
        lower.contains('requires a valid password')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('duplicate key')) {
      return 'This entry already exists.';
    }
    if (lower.contains('row-level security')) {
      return 'You do not have permission to do this.';
    }
    final clean = message.trim();
    if (clean.isEmpty ||
        lower.contains('exception') ||
        lower.contains('failed host lookup')) {
      return 'Something went wrong. Please try again.';
    }
    return clean;
  }
}
