import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  const AuthLoginRequested({required this.email, required this.password, this.rememberMe = false});
  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String username;
  final String country;
  final String englishVariant;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.username,
    required this.country,
    required this.englishVariant,
  });
  @override
  List<Object?> get props => [email, password, fullName, username, country, englishVariant];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

class AuthFacebookSignInRequested extends AuthEvent {
  const AuthFacebookSignInRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}

class AuthUserUpdated extends AuthEvent {
  final UserModel? user;
  const AuthUserUpdated({this.user});
  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthNeedsEmailVerification extends AuthState {
  final String email;
  const AuthNeedsEmailVerification({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthNeedsAssessment extends AuthState {
  final UserModel user;
  const AuthNeedsAssessment({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;
  const AuthPasswordResetSent({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthVerificationResent extends AuthState {
  const AuthVerificationResent();
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
    on<AuthFacebookSignInRequested>(_onFacebookSignIn);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResendVerificationRequested>(_onResendVerification);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      if (!firebaseUser.emailVerified) {
        emit(AuthNeedsEmailVerification(email: firebaseUser.email ?? ''));
        return;
      }

      final userData = _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        if (user.cefrLevel == 'A1' && user.totalXp == 0) {
          emit(AuthNeedsAssessment(user: user));
        } else {
          emit(AuthAuthenticated(user: user));
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (credential.user == null) {
        emit(const AuthError(message: 'Login failed. Please try again.'));
        return;
      }

      if (!credential.user!.emailVerified) {
        emit(AuthNeedsEmailVerification(email: credential.user!.email ?? ''));
        return;
      }

      final userData = _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        emit(AuthAuthenticated(user: user));
      } else {
        final mockUser = _createMockUser(credential.user!);
        await _storageService.saveUserData(mockUser.toJson());
        emit(AuthNeedsAssessment(user: mockUser));
      }
    } on Exception catch (e) {
      emit(AuthError(message: _parseAuthError(e.toString())));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.registerWithEmail(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );

      if (credential.user == null) {
        emit(const AuthError(message: 'Registration failed. Please try again.'));
        return;
      }

      final newUser = UserModel(
        id: credential.user!.uid,
        email: event.email,
        username: event.username,
        fullName: event.fullName,
        country: event.country,
        englishVariant: event.englishVariant,
        cefrLevel: 'A1',
        streakDays: 0,
        totalXp: 0,
        dailyGoalMinutes: 15,
        createdAt: DateTime.now(),
        isEmailVerified: false,
        isPremium: false,
        role: 'student',
        achievements: [],
        skillScores: {},
        childrenIds: [],
      );

      await _storageService.saveUserData(newUser.toJson());
      emit(AuthNeedsEmailVerification(email: event.email));
    } on Exception catch (e) {
      emit(AuthError(message: _parseAuthError(e.toString())));
    }
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final userData = _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        emit(AuthAuthenticated(user: user));
      } else {
        final mockUser = _createMockUser(credential.user!);
        await _storageService.saveUserData(mockUser.toJson());
        emit(AuthNeedsAssessment(user: mockUser));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAppleSignIn(AuthAppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithApple();
      if (credential == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final userData = _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        emit(AuthAuthenticated(user: user));
      } else {
        final mockUser = _createMockUser(credential.user!);
        await _storageService.saveUserData(mockUser.toJson());
        emit(AuthNeedsAssessment(user: mockUser));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onFacebookSignIn(AuthFacebookSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithFacebook();
      if (credential == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final userData = _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        emit(AuthAuthenticated(user: user));
      } else {
        final mockUser = _createMockUser(credential.user!);
        await _storageService.saveUserData(mockUser.toJson());
        emit(AuthNeedsAssessment(user: mockUser));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authService.signOut();
      await _storageService.clearTokens();
      await _storageService.clearUserData();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onForgotPassword(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: _parseAuthError(e.toString())));
    }
  }

  Future<void> _onResendVerification(AuthResendVerificationRequested event, Emitter<AuthState> emit) async {
    try {
      await _authService.sendEmailVerification();
      emit(const AuthVerificationResent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      await _storageService.saveUserData(event.user!.toJson());
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  UserModel _createMockUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid as String,
      email: (firebaseUser.email as String?) ?? '',
      username: ((firebaseUser.email as String?) ?? '').split('@').first,
      fullName: (firebaseUser.displayName as String?) ?? 'New User',
      avatarUrl: firebaseUser.photoURL as String?,
      country: 'GB',
      englishVariant: 'British English',
      cefrLevel: 'A1',
      streakDays: 0,
      totalXp: 0,
      dailyGoalMinutes: 15,
      createdAt: DateTime.now(),
      isEmailVerified: (firebaseUser.emailVerified as bool?) ?? false,
      isPremium: false,
      role: 'student',
      achievements: [],
      skillScores: {},
      childrenIds: [],
    );
  }

  String _parseAuthError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (error.contains('email-already-in-use')) return 'An account already exists with this email.';
    if (error.contains('weak-password')) return 'Password is too weak. Please choose a stronger password.';
    if (error.contains('invalid-email')) return 'Please enter a valid email address.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
    if (error.contains('network-request-failed')) return 'Network error. Please check your connection.';
    return 'Authentication failed. Please try again.';
  }
}
