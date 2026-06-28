import 'package:flutter/foundation.dart';

class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  const MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });
}

class AuthService {
  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  Future<MockUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = MockUser(
      uid: 'user_${email.hashCode.abs()}',
      email: email,
      displayName: email.split('@').first,
      emailVerified: true,
    );
    return _currentUser!;
  }

  Future<MockUser> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _currentUser = MockUser(
      uid: 'user_${email.hashCode.abs()}',
      email: email,
      displayName: fullName,
      emailVerified: false,
    );
    return _currentUser!;
  }

  Future<MockUser?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = const MockUser(
      uid: 'google_demo_001',
      email: 'demo@gmail.com',
      displayName: 'Demo User',
      emailVerified: true,
    );
    return _currentUser;
  }

  Future<MockUser?> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = const MockUser(
      uid: 'apple_demo_001',
      email: 'demo@icloud.com',
      displayName: 'Demo User',
      emailVerified: true,
    );
    return _currentUser;
  }

  Future<MockUser?> signInWithFacebook() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = const MockUser(
      uid: 'fb_demo_001',
      email: 'demo@facebook.com',
      displayName: 'Demo User',
      emailVerified: true,
    );
    return _currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Password reset email sent to $email');
  }

  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('Verification email sent');
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
