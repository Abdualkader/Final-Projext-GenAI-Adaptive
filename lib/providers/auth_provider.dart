import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

/// State management controller for authentication, user profiles, and linked child sessions.
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
  List<ChildModel> _linkedChildren = const [];
  ChildModel? _selectedChild;

  UiState<UserModel> get uiState => _uiState;
  UserModel? get currentUser => _currentUser;
  List<ChildModel> get linkedChildren => _linkedChildren;
  ChildModel? get selectedChild => _selectedChild;

  /// Whether an active authenticated user session is established.
  bool get isAuthenticated => _authService.isAuthenticated || _currentUser != null;

  /// Role verification helpers
  bool get isParent => _currentUser?.isParent ?? false;
  bool get isEducator => _currentUser?.isEducator ?? false;
  bool get isChild => _currentUser?.isChild ?? false;

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadUserProfile(user.uid, user.email ?? '');
      } else {
        _currentUser = null;
        _linkedChildren = const [];
        _selectedChild = null;
        _uiState = const UiState.initial();
        notifyListeners();
      }
    });
  }

  /// Retrieves the authenticated user profile and their linked children.
  Future<void> _loadUserProfile(String uid, String email) async {
    try {
      var user = await _userRepository.getUserById(uid);
      if (user == null) {
        // Create initial parent profile if none exists
        user = UserModel(
          userId: uid,
          email: email,
          role: 'parent',
          preferredLanguage: 'en',
          linkedChildIds: const ['child_adam', 'child_sara', 'child_omar'],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
        );
        await _userRepository.saveUser(user);
      }
      _currentUser = user;

      // Load linked child profiles
      _linkedChildren = await _userRepository.getLinkedChildren(uid);
      if (_selectedChild == null && _linkedChildren.isNotEmpty) {
        _selectedChild = _linkedChildren.first;
      }

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
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      _uiState = const UiState.errorMessage('Email and password cannot be empty.');
      notifyListeners();
      return false;
    }

    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      if (user != null) {
        await _loadUserProfile(user.uid, user.email ?? trimmedEmail);
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

  /// Registers a new parent or educator with email, password, and role.
  Future<bool> signUp(
    String email,
    String password, {
    String role = 'parent',
    String preferredLanguage = 'en',
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      _uiState = const UiState.errorMessage('Email and password cannot be empty.');
      notifyListeners();
      return false;
    }

    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      if (user != null) {
        final newUser = UserModel(
          userId: user.uid,
          email: trimmedEmail,
          displayName: displayName,
          role: role,
          preferredLanguage: preferredLanguage,
          linkedChildIds: const [],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
        );
        await _userRepository.saveUser(newUser);
        _currentUser = newUser;
        _linkedChildren = const [];
        _uiState = UiState.success(newUser);
        notifyListeners();
        return true;
      }
      _uiState = const UiState.errorMessage('Registration returned no user.');
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

  /// Signs out the active user and clears profile and child state.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _linkedChildren = const [];
    _selectedChild = null;
    _uiState = const UiState.initial();
    notifyListeners();
  }

  /// Sets the currently active child for the learning and quiz modules.
  void selectChild(ChildModel child) {
    _selectedChild = child;
    notifyListeners();
  }

  /// Reloads linked children from repository.
  Future<void> loadLinkedChildren() async {
    if (_currentUser == null) return;
    try {
      _linkedChildren = await _userRepository.getLinkedChildren(_currentUser!.userId);
      if (_selectedChild == null && _linkedChildren.isNotEmpty) {
        _selectedChild = _linkedChildren.first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading linked children: $e');
    }
  }

  /// Updates the user's preferred language and synchronizes with Firestore.
  Future<void> updatePreferredLanguage(String languageCode) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(preferredLanguage: languageCode);
    _currentUser = updated;
    await _userRepository.saveUser(updated);
    notifyListeners();
  }
}
