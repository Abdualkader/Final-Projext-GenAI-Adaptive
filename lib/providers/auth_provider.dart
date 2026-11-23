import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data_service.dart';

/// State management controller for authentication, user profiles, and linked child sessions.
class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService;
  final UserRepository _userRepository;
  StreamSubscription<User?>? _authSubscription;
  bool _isDisposed = false;

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
  bool _isLocalSession = false;

  final Map<String, String> _localCredentials = {
    'educator@example.com': 'password123',
    'educator@school.edu': 'password123',
  };
  final Map<String, UserModel> _localRegisteredUsers = {};

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
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      if (_isDisposed) return;
      if (user != null) {
        if (!_isLocalSession && _currentUser?.userId != user.uid) {
          _loadUserProfile(user.uid, user.email ?? '');
        }
      } else if (!_isLocalSession) {
        _currentUser = null;
        _linkedChildren = const [];
        _selectedChild = null;
        _uiState = const UiState.initial();
        notifyListeners();
      }
    });
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Restores previous active session from persistent local storage.
  Future<void> restoreLocalSession() async {
    try {
      final lastUid = await LocalStorageService.getLastUserId();
      if (lastUid != null) {
        final savedUser = await LocalStorageService.getUserById(lastUid);
        if (savedUser != null) {
          _isLocalSession = true;
          _currentUser = savedUser;
          _linkedChildren = await _userRepository.getLinkedChildren(savedUser.userId);
          
          final savedActiveChildId = await LocalStorageService.getActiveChildId();
          if (savedActiveChildId != null &&
              _linkedChildren.any((c) => c.childId == savedActiveChildId)) {
            _selectedChild = _linkedChildren.firstWhere((c) => c.childId == savedActiveChildId);
          } else if (_linkedChildren.isNotEmpty) {
            _selectedChild = _linkedChildren.first;
          }

          _uiState = UiState.success(savedUser);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('AuthProvider session restore error: $e');
    }
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
      await LocalStorageService.saveUser(user);

      // Load linked child profiles
      _linkedChildren = await _userRepository.getLinkedChildren(uid);
      if (_selectedChild == null && _linkedChildren.isNotEmpty) {
        final savedChildId = await LocalStorageService.getActiveChildId();
        if (savedChildId != null && _linkedChildren.any((c) => c.childId == savedChildId)) {
          _selectedChild = _linkedChildren.firstWhere((c) => c.childId == savedChildId);
        } else {
          _selectedChild = _linkedChildren.first;
        }
      }

      _uiState = UiState.success(_currentUser!);
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load user profile: $e'),
      );
    }
    notifyListeners();
  }

  /// Initiates email/password sign-in with persistent offline account recovery.
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
        _currentUser = await _userRepository.getUserById(user.uid);
        await _loadUserProfile(user.uid, user.email ?? trimmedEmail);
        return true;
      }
      _uiState = const UiState.errorMessage('Sign in returned no user.');
      notifyListeners();
      return false;
    } on AppException catch (e) {
      // Check for local demo accounts or offline fallback when Firebase Auth is unconfigured
      final isDemoAccount = trimmedEmail == 'educator@example.com' || trimmedEmail == 'educator@school.edu';
      final persistentUser = await LocalStorageService.getUserByEmail(trimmedEmail);
      final hasLocalUser = _localRegisteredUsers.containsKey(trimmedEmail) || persistentUser != null;

      if (isDemoAccount || hasLocalUser) {
        final savedCreds = await LocalStorageService.getCredentials();
        final expectedPassword = isDemoAccount
            ? (_localCredentials[trimmedEmail] ?? 'password123')
            : (savedCreds[trimmedEmail.toLowerCase()] ?? _localCredentials[trimmedEmail]);

        if (expectedPassword != null && trimmedPassword != expectedPassword && !isDemoAccount) {
          _uiState = const UiState.errorMessage('Incorrect email or password. Please try again.');
          notifyListeners();
          return false;
        }

        _isLocalSession = true;
        if (isDemoAccount) {
          final demoUser = SampleDataService.sampleParentUser;
          await _userRepository.saveUser(demoUser);
          await LocalStorageService.saveUser(demoUser);
          _currentUser = demoUser;
          _linkedChildren = await _userRepository.getLinkedChildren(demoUser.userId);
          if (_linkedChildren.isNotEmpty) {
            _selectedChild = _linkedChildren.first;
          }
          _uiState = UiState.success(demoUser);
        } else {
          final localUser = persistentUser ?? _localRegisteredUsers[trimmedEmail]!;
          await _userRepository.saveUser(localUser);
          _currentUser = localUser;
          _linkedChildren = await _userRepository.getLinkedChildren(localUser.userId);
          if (_linkedChildren.isNotEmpty) {
            final savedChildId = await LocalStorageService.getActiveChildId();
            if (savedChildId != null && _linkedChildren.any((c) => c.childId == savedChildId)) {
              _selectedChild = _linkedChildren.firstWhere((c) => c.childId == savedChildId);
            } else {
              _selectedChild = _linkedChildren.first;
            }
          }
          _uiState = UiState.success(localUser);
        }
        notifyListeners();
        return true;
      }

      if (e.code == 'no-app' ||
          e.code == 'configuration-not-found' ||
          e.message.contains('CONFIGURATION_NOT_FOUND') ||
          e.message.contains('no-app')) {
        // If it's a known local account with wrong password:
        final savedCreds = await LocalStorageService.getCredentials();
        final knownPassword = savedCreds[trimmedEmail.toLowerCase()] ?? _localCredentials[trimmedEmail];
        if (knownPassword != null && knownPassword != trimmedPassword) {
          _uiState = const UiState.errorMessage(
            'Incorrect email or password. Please try again.',
          );
          notifyListeners();
          return false;
        }

        _isLocalSession = true;
        final existingUser = await LocalStorageService.getUserByEmail(trimmedEmail);
        final localUid = existingUser?.userId ??
            'user_${trimmedEmail.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

        final offlineUser = existingUser ?? UserModel(
          userId: localUid,
          email: trimmedEmail,
          displayName: trimmedEmail.split('@').first,
          role: 'parent',
          preferredLanguage: 'ar',
          linkedChildIds: const ['child_adam', 'child_sara', 'child_omar'],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
        );

        await _userRepository.saveUser(offlineUser);
        await LocalStorageService.saveUser(offlineUser);
        await LocalStorageService.saveCredentials(trimmedEmail, trimmedPassword);

        _localCredentials[trimmedEmail] = trimmedPassword;
        _localRegisteredUsers[trimmedEmail] = offlineUser;
        _currentUser = offlineUser;

        _linkedChildren = await _userRepository.getLinkedChildren(offlineUser.userId);
        if (_linkedChildren.isNotEmpty) {
          final savedChildId = await LocalStorageService.getActiveChildId();
          if (savedChildId != null && _linkedChildren.any((c) => c.childId == savedChildId)) {
            _selectedChild = _linkedChildren.firstWhere((c) => c.childId == savedChildId);
          } else {
            _selectedChild = _linkedChildren.first;
          }
        }
        _uiState = UiState.success(offlineUser);
        notifyListeners();
        return true;
      }

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
        _isLocalSession = false;
        final newUser = UserModel(
          userId: user.uid,
          email: trimmedEmail,
          displayName: displayName,
          role: role,
          preferredLanguage: preferredLanguage,
          linkedChildIds: const ['child_adam', 'child_sara', 'child_omar'],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
        );
        await _userRepository.saveUser(newUser);
        await LocalStorageService.saveUser(newUser);
        await LocalStorageService.saveCredentials(trimmedEmail, trimmedPassword);
        _currentUser = newUser;
        _linkedChildren = await _userRepository.getLinkedChildren(newUser.userId);
        if (_linkedChildren.isNotEmpty) {
          _selectedChild = _linkedChildren.first;
          await LocalStorageService.saveActiveChildId(_selectedChild!.childId);
        }
        _uiState = UiState.success(newUser);
        notifyListeners();
        return true;
      }
      _uiState = const UiState.errorMessage('Registration returned no user.');
      notifyListeners();
      return false;
    } on AppException catch (e) {
      // If Firebase Auth is not configured in console or offline, fall back to local user registration
      if (e.code == 'configuration-not-found' ||
          e.code == 'NETWORK_ERROR' ||
          e.code == 'network-request-failed' ||
          e.code == 'operation-not-allowed' ||
          e.message.contains('CONFIGURATION_NOT_FOUND') ||
          e.message.contains('no-app')) {
        _isLocalSession = true;
        final existingUser = await LocalStorageService.getUserByEmail(trimmedEmail);
        final localUid = existingUser?.userId ??
            'user_${trimmedEmail.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

        final newUser = UserModel(
          userId: localUid,
          email: trimmedEmail,
          displayName: displayName ?? trimmedEmail.split('@').first,
          role: role,
          preferredLanguage: preferredLanguage,
          linkedChildIds: existingUser?.linkedChildIds ?? const ['child_adam', 'child_sara', 'child_omar'],
          difficultyLevel: 1,
          createdAt: existingUser?.createdAt ?? DateTime.now(),
        );

        await _userRepository.saveUser(newUser);
        await LocalStorageService.saveUser(newUser);
        await LocalStorageService.saveCredentials(trimmedEmail, trimmedPassword);

        _localCredentials[trimmedEmail] = trimmedPassword;
        _localRegisteredUsers[trimmedEmail] = newUser;
        _currentUser = newUser;

        _linkedChildren = await _userRepository.getLinkedChildren(newUser.userId);
        if (_linkedChildren.isNotEmpty) {
          _selectedChild = _linkedChildren.first;
          await LocalStorageService.saveActiveChildId(_selectedChild!.childId);
        }
        _uiState = UiState.success(newUser);
        notifyListeners();
        return true;
      }

      _uiState = UiState.error(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLocalSession = true;
      final existingUser = await LocalStorageService.getUserByEmail(trimmedEmail);
      final localUid = existingUser?.userId ??
          'user_${trimmedEmail.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

      final newUser = UserModel(
        userId: localUid,
        email: trimmedEmail,
        displayName: displayName ?? trimmedEmail.split('@').first,
        role: role,
        preferredLanguage: preferredLanguage,
        linkedChildIds: existingUser?.linkedChildIds ?? const ['child_adam', 'child_sara', 'child_omar'],
        difficultyLevel: 1,
        createdAt: existingUser?.createdAt ?? DateTime.now(),
      );

      await _userRepository.saveUser(newUser);
      await LocalStorageService.saveUser(newUser);
      await LocalStorageService.saveCredentials(trimmedEmail, trimmedPassword);

      _localCredentials[trimmedEmail] = trimmedPassword;
      _localRegisteredUsers[trimmedEmail] = newUser;
      _currentUser = newUser;

      _linkedChildren = await _userRepository.getLinkedChildren(newUser.userId);
      if (_linkedChildren.isNotEmpty) {
        _selectedChild = _linkedChildren.first;
        await LocalStorageService.saveActiveChildId(_selectedChild!.childId);
      }
      _uiState = UiState.success(newUser);
      notifyListeners();
      return true;
    }
  }

  /// Signs out the active user and clears profile and child state.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (_) {}
    _isLocalSession = false;
    _currentUser = null;
    _linkedChildren = const [];
    _selectedChild = null;
    _uiState = const UiState.initial();
    notifyListeners();
  }

  /// Sets the currently active child for the learning and quiz modules and saves to local storage.
  void selectChild(ChildModel child) {
    _selectedChild = child;
    LocalStorageService.saveActiveChildId(child.childId);
    notifyListeners();
  }

  /// Adds a new child profile to the parent/educator account and sets it as active child.
  Future<ChildModel> addChildProfile({
    required String name,
    required int age,
    int initialDifficulty = 1,
    String? preferredLanguage,
  }) async {
    final parentId = _currentUser?.userId ?? 'parent_test_01';
    final childId = 'child_${DateTime.now().millisecondsSinceEpoch}';
    final newChild = ChildModel(
      childId: childId,
      parentId: parentId,
      name: name,
      birthDate: DateTime.now().subtract(Duration(days: 365 * age)),
      currentDifficultyLevel: initialDifficulty,
      preferredLanguage: preferredLanguage ?? _currentUser?.preferredLanguage ?? 'ar',
      createdAt: DateTime.now(),
    );

    await _userRepository.addChildProfile(parentId, newChild);
    await LocalStorageService.saveChild(newChild);
    await LocalStorageService.saveActiveChildId(childId);

    _linkedChildren = [..._linkedChildren, newChild];
    _selectedChild = newChild;

    if (_currentUser != null) {
      final updatedIds = <String>{..._currentUser!.linkedChildIds, childId}.toList();
      _currentUser = _currentUser!.copyWith(linkedChildIds: updatedIds);
      await _userRepository.saveUser(_currentUser!);
      await LocalStorageService.saveUser(_currentUser!);
    }

    notifyListeners();
    return newChild;
  }

  /// Reloads linked children from repository and persistent local storage.
  Future<void> loadLinkedChildren() async {
    if (_currentUser == null) return;
    try {
      _linkedChildren = await _userRepository.getLinkedChildren(_currentUser!.userId);
      final savedChildId = await LocalStorageService.getActiveChildId();
      if (savedChildId != null && _linkedChildren.any((c) => c.childId == savedChildId)) {
        _selectedChild = _linkedChildren.firstWhere((c) => c.childId == savedChildId);
      } else if (_selectedChild == null && _linkedChildren.isNotEmpty) {
        _selectedChild = _linkedChildren.first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading linked children: $e');
    }
  }

  /// Updates the user's preferred language and synchronizes with Firestore and local storage.
  Future<void> updatePreferredLanguage(String languageCode) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(preferredLanguage: languageCode);
    _currentUser = updated;
    await _userRepository.saveUser(updated);
    await LocalStorageService.saveUser(updated);
    notifyListeners();
  }
}

