import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Firebase Authentication.
/// Handles parent and educator authentication flows and session tracking.
class AuthenticationService {
  final FirebaseAuth? _customAuth;

  AuthenticationService({FirebaseAuth? firebaseAuth})
      : _customAuth = firebaseAuth;

  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth {
    final custom = _customAuth;
    if (custom != null) return custom;
    if (!_isFirebaseAvailable) return null;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth instance unavailable: $e');
      return null;
    }
  }

  /// Current authenticated Firebase user.
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Whether an active user session exists.
  bool get isAuthenticated => currentUser != null;

  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges {
    try {
      final auth = _auth;
      if (auth == null) return Stream.value(null);
      return auth.authStateChanges();
    } catch (e) {
      debugPrint('AuthService stream warning: $e');
      return Stream.value(null);
    }
  }

  /// Signs in an existing parent/educator with email and password.
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw const AuthException(
        message: 'Firebase is not initialized or offline.',
        code: 'no-app',
      );
    }

    try {
      final credential = await auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(
            const Duration(seconds: 4),
            onTimeout: () => throw const AuthException(
              message: 'Authentication request timed out.',
              code: 'network-request-failed',
            ),
          );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Registers a new parent/educator with email and password.
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw const AuthException(
        message: 'Firebase is not initialized or offline.',
        code: 'no-app',
      );
    }

    try {
      final credential = await auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(
            const Duration(seconds: 4),
            onTimeout: () => throw const AuthException(
              message: 'Registration request timed out.',
              code: 'network-request-failed',
            ),
          );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Sign up failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Sign out failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'configuration-not-found':
        return 'Firebase Authentication is not configured or enabled in the console.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project.';
      default:
        return 'Authentication error occurred ($code).';
    }
  }
}
