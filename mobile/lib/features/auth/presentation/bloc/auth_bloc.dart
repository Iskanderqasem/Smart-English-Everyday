import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/storage_service.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent { const AuthCheckRequested(); }
class AuthLogoutRequested extends AuthEvent { const AuthLogoutRequested(); }
class AuthGoogleSignInRequested extends AuthEvent { const AuthGoogleSignInRequested(); }
class AuthAppleSignInRequested extends AuthEvent { const AuthAppleSignInRequested(); }
class AuthFacebookSignInRequested extends AuthEvent { const AuthFacebookSignInRequested(); }
class AuthResendVerificationRequested extends AuthEvent { const AuthResendVerificationRequested(); }

class AuthLoginRequested extends AuthEvent {
  final String email, password;
  const AuthLoginRequested({required this.email, required this.password});
  @override List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email, password, fullName, username, country, englishVariant;
  const AuthRegisterRequested({required this.email, required this.password, required this.fullName, required this.username, required this.country, required this.englishVariant});
  @override List<Object?> get props => [email, password, fullName, username, country, englishVariant];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
  @override List<Object?> get props => [email];
}

class AuthUserUpdated extends AuthEvent {
  final UserModel? user;
  const AuthUserUpdated({this.user});
  @override List<Object?> get props => [user];
}

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthVerificationResent extends AuthState { const AuthVerificationResent(); }

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});
  @override List<Object?> get props => [user];
}

class AuthNeedsEmailVerification extends AuthState {
  final String email;
  const AuthNeedsEmailVerification({required this.email});
  @override List<Object?> get props => [email];
}

class AuthNeedsAssessment extends AuthState {
  final UserModel user;
  const AuthNeedsAssessment({required this.user});
  @override List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;
  const AuthPasswordResetSent({required this.email});
  @override List<Object?> get props => [email];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({required AuthService authService, required StorageService storageService})
      : _authService = authService,
        _storageService = storageService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleSignInRequested>(_onGoogle);
    on<AuthAppleSignInRequested>(_onApple);
    on<AuthFacebookSignInRequested>(_onFacebook);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPasswordRequested>(_onForgot);
    on<AuthResendVerificationRequested>(_onResend);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final data = _storageService.getUserData();
      if (data != null) emit(AuthAuthenticated(user: UserModel.fromJson(data)));
      else emit(const AuthUnauthenticated());
    } catch (_) { emit(const AuthUnauthenticated()); }
  }

  Future<void> _onLogin(AuthLoginRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mu = await _authService.signInWithEmail(email: e.email, password: e.password);
      final user = _build(mu);
      await _storageService.saveUserData(user.toJson());
      emit(AuthAuthenticated(user: user));
    } catch (_) { emit(const AuthError(message: 'Login failed.')); }
  }

  Future<void> _onRegister(AuthRegisterRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mu = await _authService.registerWithEmail(email: e.email, password: e.password, fullName: e.fullName);
      final user = UserModel(
        id: mu.uid, email: e.email, username: e.username, fullName: e.fullName,
        country: e.country, englishVariant: e.englishVariant, cefrLevel: 'A1',
        streakDays: 0, totalXp: 0, dailyGoalMinutes: 15, createdAt: DateTime.now(),
        isEmailVerified: false, isPremium: false, role: 'student',
        achievements: const [], skillScores: const {}, childrenIds: const [],
      );
      await _storageService.saveUserData(user.toJson());
      emit(AuthNeedsAssessment(user: user));
    } catch (_) { emit(const AuthError(message: 'Registration failed.')); }
  }

  Future<void> _onGoogle(AuthGoogleSignInRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mu = await _authService.signInWithGoogle();
      if (mu == null) { emit(const AuthUnauthenticated()); return; }
      final user = _build(mu);
      await _storageService.saveUserData(user.toJson());
      emit(AuthNeedsAssessment(user: user));
    } catch (err) { emit(AuthError(message: err.toString())); }
  }

  Future<void> _onApple(AuthAppleSignInRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mu = await _authService.signInWithApple();
      if (mu == null) { emit(const AuthUnauthenticated()); return; }
      final user = _build(mu);
      await _storageService.saveUserData(user.toJson());
      emit(AuthNeedsAssessment(user: user));
    } catch (err) { emit(AuthError(message: err.toString())); }
  }

  Future<void> _onFacebook(AuthFacebookSignInRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mu = await _authService.signInWithFacebook();
      if (mu == null) { emit(const AuthUnauthenticated()); return; }
      final user = _build(mu);
      await _storageService.saveUserData(user.toJson());
      emit(AuthNeedsAssessment(user: user));
    } catch (err) { emit(AuthError(message: err.toString())); }
  }

  Future<void> _onLogout(AuthLogoutRequested e, Emitter<AuthState> emit) async {
    await _authService.signOut();
    await _storageService.clearTokens();
    await _storageService.clearUserData();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgot(AuthForgotPasswordRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(e.email);
      emit(AuthPasswordResetSent(email: e.email));
    } catch (_) { emit(const AuthError(message: 'Failed to send reset email.')); }
  }

  Future<void> _onResend(AuthResendVerificationRequested e, Emitter<AuthState> emit) async {
    try {
      await _authService.sendEmailVerification();
      emit(const AuthVerificationResent());
    } catch (err) { emit(AuthError(message: err.toString())); }
  }

  Future<void> _onUserUpdated(AuthUserUpdated e, Emitter<AuthState> emit) async {
    if (e.user != null) {
      await _storageService.saveUserData(e.user!.toJson());
      emit(AuthAuthenticated(user: e.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  UserModel _build(MockUser mu) => UserModel(
    id: mu.uid, email: mu.email ?? '', username: (mu.email ?? '').split('@').first,
    fullName: mu.displayName ?? 'New User', avatarUrl: mu.photoURL,
    country: 'GB', englishVariant: 'British English', cefrLevel: 'A1',
    streakDays: 0, totalXp: 0, dailyGoalMinutes: 15, createdAt: DateTime.now(),
    isEmailVerified: mu.emailVerified, isPremium: false, role: 'student',
    achievements: const [], skillScores: const {}, childrenIds: const [],
  );
}
