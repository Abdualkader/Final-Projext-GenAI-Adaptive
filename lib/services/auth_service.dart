import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Firebase Authentication.
/// Handles parent and educator authentication flows and session tracking.
class AuthenticationService {
  static final AuthenticationService _instance =
      AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Current authenticated Firebase user.
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Whether an active user session exists.
  bool get isAuthenticated => currentUser != null;

  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
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
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Sign up failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
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
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error occurred ($code).';
    }
  }
}
