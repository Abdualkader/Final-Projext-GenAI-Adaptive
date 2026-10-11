import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

/// State management controller for authentication and user profile session.
class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService;
  final UserRepository _userRepository;

  AuthProvider({
    AuthenticationService? authService,
    UserRepository? userRepository,
  })  : _authService = authService ?? AuthenticationService(),
        _userRepository = userRepository ?? BaseUserRepository() {
    _initAuthListener();
  }

  UiState<UserModel> _uiState = const UiState.initial();
  UserModel? _currentUser;

  UiState<UserModel> get uiState => _uiState;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.isAuthenticated || _currentUser != null;

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadUserProfile(user.uid, user.email ?? '');
      } else {
        _currentUser = null;
        _uiState = const UiState.initial();
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid, String email) async {
    try {
      final user = await _userRepository.getUserById(uid);
      _currentUser = user ??
          UserModel(
            userId: uid,
            email: email,
            role: 'parent',
            createdAt: DateTime.now(),
          );
      _uiState = UiState.success(_currentUser!);
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load user profile: $e'),
      );
    }
    notifyListeners();
  }

  /// Initiates email/password sign-in.
  Future<bool> signIn(String email, String password) async {
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        await _loadUserProfile(user.uid, user.email ?? email);
        return true;
      }
      _uiState = const UiState.errorMessage('Sign in returned no user.');
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _uiState = UiState.error(e);
      notifyListeners();
      return false;
    } catch (e) {
      _uiState = UiState.errorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Signs out the active user.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _uiState = const UiState.initial();
    notifyListeners();
  }
}
