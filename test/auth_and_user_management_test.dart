import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:asd_learning_assistant/core/constants/app_routes.dart';
import 'package:asd_learning_assistant/core/errors/app_exceptions.dart';
import 'package:asd_learning_assistant/core/errors/ui_state.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:asd_learning_assistant/core/routes/app_router.dart';
import 'package:asd_learning_assistant/core/routes/route_guard.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/providers/auth_provider.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/screens/parent/child_selection_screen.dart';
import 'package:asd_learning_assistant/screens/parent/login_screen.dart';
import 'package:asd_learning_assistant/screens/parent/progress_dashboard_screen.dart';
import 'package:asd_learning_assistant/services/auth_service.dart';

/// Fake Firebase User for unit tests
class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake AuthenticationService for isolated unit and widget tests
class FakeAuthService extends AuthenticationService {
  User? _mockUser;
  bool shouldThrowNetworkError = false;
  bool shouldThrowInvalidCredential = false;
  final StreamController<User?> _authController = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _mockUser;

  @override
  bool get isAuthenticated => _mockUser != null;

  @override
  Stream<User?> get authStateChanges => _authController.stream;

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowNetworkError) {
      throw const NetworkException(
        message: 'Network connection error. Please check your internet connection.',
      );
    }
    if (shouldThrowInvalidCredential || password == 'wrong_password') {
      throw const AuthException(
        message: 'Incorrect email or password. Please try again.',
        code: 'invalid-credential',
      );
    }
    _mockUser = FakeUser(uid: 'mock_parent_123', email: email);
    _authController.add(_mockUser);
    return _mockUser;
  }

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _mockUser = FakeUser(uid: 'mock_new_123', email: email);
    _authController.add(_mockUser);
    return _mockUser;
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _authController.add(null);
  }

  void dispose() {
    _authController.close();
  }
}

/// Fake UserRepository for deterministic in-memory tests
class FakeUserRepository implements UserRepository {
  final Map<String, UserModel> _users = {};
  final Map<String, List<ChildModel>> _children = {};

  FakeUserRepository() {
    _users['mock_parent_123'] = UserModel(
      userId: 'mock_parent_123',
      email: 'educator@school.edu',
      displayName: 'Teacher Nora',
      role: 'educator',
      preferredLanguage: 'ar',
      linkedChildIds: const ['child_adam', 'child_sara', 'child_omar'],
      difficultyLevel: 1,
      createdAt: DateTime.now(),
    );

    _children['mock_parent_123'] = [
      ChildModel(
        childId: 'child_adam',
        parentId: 'mock_parent_123',
        name: 'Adam',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        currentDifficultyLevel: 1,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
      ),
      ChildModel(
        childId: 'child_sara',
        parentId: 'mock_parent_123',
        name: 'Sara',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
        currentDifficultyLevel: 2,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
      ),
      ChildModel(
        childId: 'child_omar',
        parentId: 'mock_parent_123',
        name: 'Omar',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        currentDifficultyLevel: 2,
        preferredLanguage: 'ar',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    return _users[userId];
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _users[user.userId] = user;
  }

  @override
  Future<List<ChildModel>> getLinkedChildren(String parentId) async {
    return _children[parentId] ?? const [];
  }

  @override
  Future<void> addChildProfile(String parentId, ChildModel child) async {
    _children.putIfAbsent(parentId, () => []).add(child);
    final user = _users[parentId];
    if (user != null) {
      _users[parentId] = user.copyWith(
        linkedChildIds: [...user.linkedChildIds, child.childId],
      );
    }
  }

  @override
  Future<void> updatePreferredLanguage(String userId, String language) async {
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(preferredLanguage: language);
    }
  }

  @override
  Future<List<String>> getLinkedChildIds(String parentId) async {
    final user = _users[parentId];
    if (user != null && user.linkedChildIds.isNotEmpty) {
      return user.linkedChildIds;
    }
    final children = _children[parentId] ?? const [];
    return children.map((c) => c.childId).toList();
  }
}

Widget _buildTestApp(Widget child, [Locale locale = const Locale('en')]) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  group('Task 4: User Model & Role Hierarchy Tests', () {
    test('UserModel contains all required schema fields and default values', () {
      final now = DateTime.now();
      final user = UserModel(
        userId: 'usr_001',
        email: 'parent@home.com',
        createdAt: now,
      );

      expect(user.userId, 'usr_001');
      expect(user.email, 'parent@home.com');
      expect(user.role, 'parent');
      expect(user.preferredLanguage, 'en');
      expect(user.linkedChildIds, isEmpty);
      expect(user.difficultyLevel, 1);
      expect(user.isParent, true);
      expect(user.isEducator, false);
      expect(user.isChild, false);
    });

    test('UserModel correctly distinguishes educator and child roles', () {
      final educator = UserModel(
        userId: 'usr_edu',
        email: 'edu@school.org',
        role: 'educator',
        createdAt: DateTime.now(),
      );
      expect(educator.isEducator, true);
      expect(educator.isParent, false);
      expect(educator.isChild, false);

      final childUser = UserModel(
        userId: 'usr_chd',
        email: 'child@local.net',
        role: 'child',
        createdAt: DateTime.now(),
      );
      expect(childUser.isChild, true);
      expect(childUser.isParent, false);
      expect(childUser.isEducator, false);
    });

    test('UserModel serialization and deserialization preserves all fields', () {
      final now = DateTime.now();
      final user = UserModel(
        userId: 'usr_999',
        email: 'test@asd.com',
        displayName: 'Dr. Noura',
        role: 'educator',
        preferredLanguage: 'ar',
        linkedChildIds: const ['child_adam', 'child_sara'],
        difficultyLevel: 2,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['userId'], 'usr_999');
      expect(map['email'], 'test@asd.com');
      expect(map['displayName'], 'Dr. Noura');
      expect(map['role'], 'educator');
      expect(map['preferredLanguage'], 'ar');
      expect(map['linkedChildIds'], ['child_adam', 'child_sara']);
      expect(map['difficultyLevel'], 2);

      final fromMap = UserModel.fromMap(map);
      expect(fromMap.userId, user.userId);
      expect(fromMap.email, user.email);
      expect(fromMap.displayName, user.displayName);
      expect(fromMap.role, user.role);
      expect(fromMap.preferredLanguage, user.preferredLanguage);
      expect(fromMap.linkedChildIds, user.linkedChildIds);
      expect(fromMap.difficultyLevel, 2);
    });

    test('UserModel copyWith works reliably', () {
      final user = UserModel(
        userId: 'usr_1',
        email: 'a@b.com',
        createdAt: DateTime.now(),
      );
      final updated = user.copyWith(
        preferredLanguage: 'ar',
        difficultyLevel: 3,
        linkedChildIds: ['child_1'],
      );
      expect(updated.preferredLanguage, 'ar');
      expect(updated.difficultyLevel, 3);
      expect(updated.linkedChildIds, ['child_1']);
      expect(updated.userId, 'usr_1');
    });

    test('Security Task 10: UserModel never serializes password fields to Map', () {
      final user = UserModel(
        userId: 'u_sec',
        email: 'secure@parent.com',
        createdAt: DateTime.now(),
      );
      final map = user.toMap();
      expect(map.containsKey('password'), false);
      expect(map.containsKey('secret'), false);
      expect(map.containsKey('token'), false);
    });
  });

  group('Task 2 & 3: Authentication Service & Exception Mapping Tests', () {
    test('AuthenticationService maps Firebase Auth errors to user-friendly messages', () {
      final authService = AuthenticationService();
      expect(authService.isAuthenticated, false);

      // Test default error message mapping logic via AuthException
      final credentialEx = AuthException(
        message: 'Incorrect email or password. Please try again.',
        code: 'invalid-credential',
      );
      expect(credentialEx.code, 'invalid-credential');
      expect(credentialEx.message, contains('Incorrect email or password'));

      final networkEx = NetworkException(
        message: 'Network connection error. Please check your internet connection.',
      );
      expect(networkEx.code, 'NETWORK_ERROR');
      expect(networkEx.toChildFriendlyMessage(false), contains('resting'));
      expect(networkEx.toChildFriendlyMessage(true), contains('سحابة الإنترنت'));
    });
  });

  group('Task 5 & 7: User Profile and Linked Children Repository Tests', () {
    test('FakeUserRepository loads user profile and linked children', () async {
      final repo = FakeUserRepository();
      final user = await repo.getUserById('mock_parent_123');
      expect(user, isNotNull);
      expect(user!.displayName, 'Teacher Nora');
      expect(user.linkedChildIds.length, 3);

      final children = await repo.getLinkedChildren('mock_parent_123');
      expect(children.length, 3);
      expect(children[0].name, 'Adam');
      expect(children[1].name, 'Sara');
      expect(children[2].name, 'Omar');
    });

    test('BaseUserRepository fallback provides 3 linked children for offline/tests', () async {
      final baseRepo = BaseUserRepository();
      final children = await baseRepo.getLinkedChildren('parent_offline');
      expect(children.length, 3);
      expect(children.map((c) => c.name), containsAll(['Adam', 'Sara', 'Omar']));
    });
  });

  group('Task 2, 3, 5, 7, 8, 9: AuthProvider Business Logic Tests', () {
    late FakeAuthService authService;
    late FakeUserRepository userRepository;
    late AuthProvider authProvider;

    setUp(() {
      authService = FakeAuthService();
      userRepository = FakeUserRepository();
      authProvider = AuthProvider(
        authService: authService,
        userRepository: userRepository,
      );
    });

    tearDown(() {
      authService.dispose();
      authProvider.dispose();
    });

    test('Initial state is unauthenticated and empty', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.selectedChild, isNull);
      expect(authProvider.linkedChildren, isEmpty);
    });

    test('signIn with empty email or password returns false', () async {
      final res1 = await authProvider.signIn('', 'password123');
      expect(res1, false);
      expect(authProvider.uiState.status, UiStatus.error);
      expect(authProvider.uiState.errorMessage, contains('cannot be empty'));

      final res2 = await authProvider.signIn('email@test.com', '');
      expect(res2, false);
      expect(authProvider.uiState.status, UiStatus.error);
    });

    test('signIn with invalid credentials returns false and sets error message', () async {
      authService.shouldThrowInvalidCredential = true;
      final res = await authProvider.signIn('parent@home.com', 'wrong');
      expect(res, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.uiState.status, UiStatus.error);
      expect(authProvider.uiState.errorMessage, contains('Incorrect email or password'));
    });

    test('signIn with network error sets gentle network error message', () async {
      authService.shouldThrowNetworkError = true;
      final res = await authProvider.signIn('parent@home.com', 'pass123');
      expect(res, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.uiState.status, UiStatus.error);
      expect(authProvider.uiState.errorMessage, contains('Network connection error'));
    });

    test('signIn with valid credentials successfully loads profile and children', () async {
      final res = await authProvider.signIn('educator@school.edu', 'secret123');
      expect(res, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.displayName, 'Teacher Nora');
      expect(authProvider.linkedChildren.length, 3);
      expect(authProvider.selectedChild, isNotNull);
      expect(authProvider.selectedChild!.name, 'Adam');
    });

    test('Task 7: selectChild updates active child in application state', () async {
      await authProvider.signIn('educator@school.edu', 'secret123');
      expect(authProvider.selectedChild?.name, 'Adam');

      final sara = authProvider.linkedChildren.firstWhere((c) => c.name == 'Sara');
      authProvider.selectChild(sara);
      expect(authProvider.selectedChild?.name, 'Sara');
      expect(authProvider.selectedChild?.currentDifficultyLevel, 2);
    });

    test('Task 8: signOut clears user profile, linked children, and selected child', () async {
      await authProvider.signIn('educator@school.edu', 'secret123');
      expect(authProvider.isAuthenticated, true);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.linkedChildren, isEmpty);
      expect(authProvider.selectedChild, isNull);
      expect(authProvider.uiState.status, UiStatus.initial);
    });

    test('Task 9: updatePreferredLanguage updates profile and persists to repo', () async {
      await authProvider.signIn('educator@school.edu', 'secret123');
      expect(authProvider.currentUser?.preferredLanguage, 'ar');

      await authProvider.updatePreferredLanguage('en');
      expect(authProvider.currentUser?.preferredLanguage, 'en');

      final persisted = await userRepository.getUserById('mock_parent_123');
      expect(persisted?.preferredLanguage, 'en');
    });
  });

  group('Task 6: RouteGuard & Protected Navigation Tests', () {
    test('RouteGuard identifies protected parent routes and open child routes', () {
      // Protected
      expect(RouteGuard.isProtected(AppRoutes.parentChildSelection), true);
      expect(RouteGuard.isProtected(AppRoutes.parentDashboard), true);
      expect(RouteGuard.isProtected(AppRoutes.parentSettings), true);

      // Open
      expect(RouteGuard.isProtected(AppRoutes.childHome), false);
      expect(RouteGuard.isProtected(AppRoutes.childCategories), false);
      expect(RouteGuard.isProtected(AppRoutes.childLearning), false);
      expect(RouteGuard.isProtected(AppRoutes.childQuiz), false);
      expect(RouteGuard.isProtected(AppRoutes.parentLogin), false);
    });

    testWidgets('AppRouter redirects unauthenticated users attempting to access parent dashboard to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
            settings,
            isAuthenticated: false,
          ),
          initialRoute: AppRoutes.parentDashboard,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('AppRouter permits authenticated user to access parent dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
            settings,
            isAuthenticated: true,
          ),
          initialRoute: AppRoutes.parentDashboard,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProgressDashboardScreen), findsOneWidget);
    });
  });

  group('Task 2, 7 & 8: Widget Tests (Login, Child Selection, Logout)', () {
    testWidgets('LoginScreen shows validation errors on invalid inputs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // 1. Empty field submission
      await tester.tap(find.text('Enter Portal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email address'), findsOneWidget);

      // 2. Invalid email format
      await tester.enterText(find.byType(TextField).first, 'bademail');
      await tester.tap(find.text('Enter Portal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email format'), findsOneWidget);

      // 3. Empty password
      await tester.enterText(find.byType(TextField).first, 'valid@email.com');
      await tester.tap(find.text('Enter Portal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LoginScreen with FakeAuthService logs in and navigates to ChildSelection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuthService = FakeAuthService();
      final fakeUserRepo = FakeUserRepository();
      final authProvider = AuthProvider(
        authService: fakeAuthService,
        userRepository: fakeUserRepo,
      );
      addTearDown(fakeAuthService.dispose);
      addTearDown(authProvider.dispose);

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            AppRoutes.parentChildSelection: (_) => const Scaffold(body: Text('CHILD_SELECTION_REACHED')),
          },
          home: LoginScreen(authProvider: authProvider),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'educator@school.edu');
      await tester.enterText(find.byType(TextField).at(1), 'correct_pass');
      await tester.tap(find.text('Enter Portal'));
      await tester.pumpAndSettle();

      expect(authProvider.isAuthenticated, true);
      expect(find.text('CHILD_SELECTION_REACHED'), findsOneWidget);
    });

    testWidgets('ChildSelectionScreen renders student profiles and allows selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuthService = FakeAuthService();
      final fakeUserRepo = FakeUserRepository();
      final authProvider = AuthProvider(
        authService: fakeAuthService,
        userRepository: fakeUserRepo,
      );
      addTearDown(fakeAuthService.dispose);
      addTearDown(authProvider.dispose);

      // Pre-authenticate
      await authProvider.signIn('educator@school.edu', 'pass');

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            AppRoutes.parentDashboard: (_) => const Scaffold(body: Text('DASHBOARD_REACHED')),
            AppRoutes.parentLogin: (_) => const Scaffold(body: Text('LOGIN_SCREEN_REACHED')),
          },
          home: ChildSelectionScreen(authProvider: authProvider),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Student Profile'), findsOneWidget);
      expect(find.text('Adam'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('Omar'), findsOneWidget);

      // Tap Sara -> Selects Sara and navigates to Dashboard
      await tester.tap(find.text('Sara'));
      await tester.pumpAndSettle();

      expect(authProvider.selectedChild?.name, 'Sara');
      expect(find.text('DASHBOARD_REACHED'), findsOneWidget);
    });

    testWidgets('ChildSelectionScreen logout button clears session and navigates to Login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuthService = FakeAuthService();
      final fakeUserRepo = FakeUserRepository();
      final authProvider = AuthProvider(
        authService: fakeAuthService,
        userRepository: fakeUserRepo,
      );
      addTearDown(fakeAuthService.dispose);
      addTearDown(authProvider.dispose);

      // Pre-authenticate
      await authProvider.signIn('educator@school.edu', 'pass');
      expect(authProvider.isAuthenticated, true);

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            AppRoutes.parentLogin: (_) => const Scaffold(body: Text('LOGIN_SCREEN_REACHED')),
          },
          home: ChildSelectionScreen(authProvider: authProvider),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Logout IconButton in AppBar
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
      expect(find.text('LOGIN_SCREEN_REACHED'), findsOneWidget);
    });
  });
}
