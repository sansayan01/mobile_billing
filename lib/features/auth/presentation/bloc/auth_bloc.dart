import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/core/config/deep_link_config.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  StreamSubscription<User?>? _authSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.loginWithGoogleUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Login ke baad bhi email confirm check karo — unverified user ko
        // verification screen par bhejo, sirf startup pe nahi.
        if (user.emailConfirmedAt != null) {
          emit(Authenticated(user));
        } else {
          emit(EmailVerificationPending(user.email));
        }
      },
    );
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
        shopName: event.shopName,
        emailRedirectTo: DeepLinkConfig.emailRedirectTo,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Agar session mila aur email confirm hai → direct authenticated.
        // Agar signUp ne session return kiya (confirmation off) → authenticated.
        if (user.emailConfirmedAt != null) {
          emit(Authenticated(user));
        } else {
          // Email confirmation pending hai — verification screen par bhejo.
          emit(EmailVerificationPending(user.email));
        }
      },
    );
  }

  Future<void> _onResendVerificationEmailRequested(
      ResendVerificationEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.resendVerificationEmail(event.email);
    result.fold(
      (failure) => emit(ResendEmailError(event.email, failure.message)),
      (_) => emit(ResendEmailSent(event.email)),
    );
  }

  Future<void> _onGoogleLoginRequested(
      GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await loginWithGoogleUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Google login mein bhi email confirm check karo consistency ke liye.
        if (user.emailConfirmedAt != null) {
          emit(Authenticated(user));
        } else {
          emit(EmailVerificationPending(user.email));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          // Agar email confirm nahi hui toh verification screen dikhao.
          if (user.emailConfirmedAt != null) {
            emit(Authenticated(user));
          } else {
            emit(EmailVerificationPending(user.email));
          }
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
      UpdateProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(const AuthLoading());
      final result =
          await authRepository.updateProfile(event.name, event.role);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    }
  }

  /// Set up a subscription to auth state changes from Supabase.
  /// Call this once during initialization (e.g. in main.dart).
  void subscribeToAuthChanges(
      Stream<User?> Function() authStateChangesProvider) {
    _authSubscription?.cancel();
    _authSubscription = authStateChangesProvider().listen((user) {
      if (user != null) {
        add(const CheckAuthStatus());
      } else {
        add(const LogoutRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
