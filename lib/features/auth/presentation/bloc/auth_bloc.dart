import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:billing_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/core/config/deep_link_config.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  StreamSubscription<User?>? _authSubscription;
  bool _isLoggingOut = false;
  bool _suppressStatusCheck = false;
  int _statusToken = 0;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
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
        shopId: event.shopId,
        phone: event.phone,
      ),
    );

    Failure? failure;
    User? newUser;
    result.fold(
      (f) => failure = f,
      (u) => newUser = u,
    );
    if (failure != null) {
      emit(AuthError(failure!.message));
      return;
    }
    final user = newUser!;

    // KNOWN LIMITATION: client-side Supabase SDK se admin API (admin
    // delete/create user without session) possible nahi hai. signUp call
    // OWNER ki current session ko STAFF ke naye session se replace kar
    // deti hai (session hijack). Isliye staff signup success ke turant
    // baad hum sign out karte hain — owner clean login screen par jaata
    // hai, silent hijack nahi hota. Proper fix = Edge Function / service
    // role key (server-side), jo abhi scope mein nahi hai.
    if (event.role == 'staff') {
      await _signOutAfterStaffSignup();
      // Email confirm ho ya na ho — session ab sign-out ho chuka hai,
      // isliye terminal state Unauthenticated hi emit karo.
      emit(const Unauthenticated(message: kStaffAccountCreatedMessage));
      return;
    }
    // Agar session mila aur email confirm hai → direct authenticated.
    // Agar signUp ne session return kiya (confirmation off) → authenticated.
    if (user.emailConfirmedAt != null) {
      emit(Authenticated(user));
    } else {
      // Email confirmation pending hai — verification screen par bhejo.
      emit(EmailVerificationPending(user.email));
    }
  }

  /// Staff signup ke baad owner ki replaced session ko saaf karta hai.
  /// signUp se Supabase SIGNED_IN fire hota hai jo concurrent CheckAuthStatus
  /// trigger karta hai — [_suppressStatusCheck] + [_statusToken] se stale /
  /// mid-flight silent checks drop hote hain, warna wo is flow ke baad emit
  /// hue Unauthenticated(message) ko overwrite kar dete hain.
  Future<void> _signOutAfterStaffSignup() async {
    _suppressStatusCheck = true;
    _statusToken++;
    _isLoggingOut = true;
    try {
      await logoutUseCase(NoParams());
    } finally {
      _isLoggingOut = false;
      _suppressStatusCheck = false;
    }
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

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _statusToken++;
    // Pehle signOut complete karo, phir terminal state emit — warna UI
    // Unauthenticated dikha dega jabki session abhi bhi live ho sakta hai.
    final result = await logoutUseCase(NoParams());
    _isLoggingOut = false;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    // NOTE: yahan AuthLoading emit NAHI karte. Ye event silent refresh ke
    // liye bhi fire hota hai (email-verification poll, authStateChanges
    // listener) — AuthLoading emit karne se AuthGate splash flash loop
    // ho jaata hai. State ko current terminal state par hi rehne do, sirf
    // result aane par naya terminal state emit karo.
    if (_suppressStatusCheck || _isLoggingOut) return;
    final token = _statusToken;
    final result = await getCurrentUserUseCase(NoParams());
    // Stale silent check — staff-signup / logout flow ne iske beech session
    // badal diya, is result ko drop karo (overwrite race).
    if (_suppressStatusCheck || _isLoggingOut || token != _statusToken) {
      return;
    }
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
      if (_isLoggingOut) return;
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
