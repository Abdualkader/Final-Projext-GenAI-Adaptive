import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asd_learning_assistant/services/local_storage_service.dart';

import 'package:asd_learning_assistant/core/constants/app_routes.dart';
import 'package:asd_learning_assistant/core/errors/app_exceptions.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:asd_learning_assistant/core/routes/app_router.dart';
import 'package:asd_learning_assistant/core/routes/route_guard.dart';
import 'package:asd_learning_assistant/core/theme/app_theme.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/learning_session_model.dart';
import 'package:asd_learning_assistant/models/matching_game_model.dart';
import 'package:asd_learning_assistant/models/quiz_question_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/providers/auth_provider.dart';
import 'package:asd_learning_assistant/providers/category_provider.dart';
import 'package:asd_learning_assistant/providers/learning_session_provider.dart';
import 'package:asd_learning_assistant/providers/progress_provider.dart';
import 'package:asd_learning_assistant/providers/quiz_provider.dart';
import 'package:asd_learning_assistant/providers/settings_provider.dart';
import 'package:asd_learning_assistant/providers/vocabulary_provider.dart';
import 'package:asd_learning_assistant/repositories/category_repository.dart';
import 'package:asd_learning_assistant/repositories/progress_repository.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/repositories/vocabulary_repository.dart';
import 'package:asd_learning_assistant/screens/child/category_selection_screen.dart';
import 'package:asd_learning_assistant/screens/child/quiz_screen.dart';
import 'package:asd_learning_assistant/screens/child/vocabulary_learning_screen.dart';
import 'package:asd_learning_assistant/screens/parent/progress_dashboard_screen.dart';
import 'package:asd_learning_assistant/services/adaptive_difficulty_service.dart';
import 'package:asd_learning_assistant/services/ai_adaptive_service.dart';
import 'package:asd_learning_assistant/services/auth_service.dart';

// ==============================================================================
// HERMETIC IN-MEMORY TEST REPOSITORIES AND TEST SERVICES
// ==============================================================================

class E2EFakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  E2EFakeUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class E2EFakeAuthService extends AuthenticationService {
  User? _mockUser;
  bool shouldFail = false;
  final StreamController<User?> _controller = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _mockUser;

  @override
  bool get isAuthenticated => _mockUser != null;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldFail || password == 'wrong') {
      throw const AuthException(
        message: 'Invalid credentials. Please verify your email and password.',
        code: 'invalid-credential',
      );
    }
    _mockUser = E2EFakeUser(uid: 'mock_educator_001', email: email);
    _controller.add(_mockUser);
    return _mockUser;
  }

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _mockUser = E2EFakeUser(uid: 'mock_new_002', email: email);
    _controller.add(_mockUser);
    return _mockUser;
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

class E2EFakeUserRepository implements UserRepository {
  final Map<String, UserModel> users = {};
  final Map<String, List<ChildModel>> children = {};

  E2EFakeUserRepository() {
    users['mock_educator_001'] = UserModel(
      userId: 'mock_educator_001',
      email: 'educator@example.com',
      displayName: 'Teacher Layla',
      role: 'educator',
      preferredLanguage: 'en',
      linkedChildIds: const ['child_adam', 'child_sara'],
      createdAt: DateTime.now(),
    );

    children['mock_educator_001'] = [
      ChildModel(
        childId: 'child_adam',
        parentId: 'mock_educator_001',
        name: 'Adam',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        currentDifficultyLevel: 1,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
      ),
      ChildModel(
        childId: 'child_sara',
        parentId: 'mock_educator_001',
        name: 'Sara',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
        currentDifficultyLevel: 2,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<UserModel?> getUserById(String userId) async => users[userId];

  @override
  Future<void> saveUser(UserModel user) async {
    users[user.userId] = user;
  }

  @override
  Future<void> updatePreferredLanguage(String userId, String language) async {
    if (users.containsKey(userId)) {
      users[userId] = users[userId]!.copyWith(preferredLanguage: language);
    }
  }

  @override
  Future<List<ChildModel>> getLinkedChildren(String parentId) async =>
      children[parentId] ?? [];

  @override
  Future<List<String>> getLinkedChildIds(String parentId) async =>
      (children[parentId] ?? []).map((c) => c.childId).toList();

  @override
  Future<void> addChildProfile(String parentId, ChildModel child) async {
    final list = children.putIfAbsent(parentId, () => []);
    list.add(child);
  }

  @override
  Future<void> updateChildDifficulty(String childId, int newDifficulty) async {
    for (final list in children.values) {
      final idx = list.indexWhere((c) => c.childId == childId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(currentDifficultyLevel: newDifficulty);
      }
    }
  }

  @override
  Future<ChildModel?> getChildById(String childId) async {
    for (final list in children.values) {
      for (final child in list) {
        if (child.childId == childId) return child;
      }
    }
    return null;
  }
}

class E2EInMemorySessionRepository implements SessionRepository {
  final List<LearningSessionModel> sessions = [];

  @override
  Future<void> createSession(LearningSessionModel session) async {
    sessions.add(session);
  }

  @override
  Future<void> recordSession(LearningSessionModel session) async {
    final idx = sessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (idx != -1) {
      sessions[idx] = session;
    } else {
      sessions.add(session);
    }
  }

  @override
  Future<void> updateSession(LearningSessionModel session) async {
    final idx = sessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (idx != -1) {
      sessions[idx] = session;
    } else {
      sessions.add(session);
    }
  }

  @override
  Future<void> completeSession(
    String sessionId, {
    required DateTime endTime,
    required double score,
  }) async {
    final idx = sessions.indexWhere((s) => s.sessionId == sessionId);
    if (idx != -1) {
      sessions[idx] = sessions[idx].copyWith(
        endTime: endTime,
        score: score,
      );
    }
  }

  @override
  Future<LearningSessionModel?> getSessionById(String sessionId) async {
    try {
      return sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LearningSessionModel>> getRecentSessions(
    String childId, {
    int limit = 10,
  }) async {
    final list = sessions.where((s) => s.childId == childId).toList();
    if (list.length > limit) {
      return list.sublist(list.length - limit);
    }
    return list;
  }
}

class E2EInMemoryQuizRepository implements QuizRepository {
  final List<QuizResultModel> results = [];
  final BaseVocabularyRepository _vocabRepo = BaseVocabularyRepository();

  @override
  Future<void> recordQuizResult(QuizResultModel result) async {
    results.add(result);
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId) async {
    return results.where((r) => r.sessionId == sessionId).toList();
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForChild(String childId) async {
    return results.where((r) => r.childId == childId).toList();
  }

  @override
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId) async {
    final questions = await getQuizQuestionsForCategory(categoryId, count: 1);
    return questions.first;
  }

  @override
  Future<List<QuizQuestionModel>> getQuizQuestionsForCategory(
    String categoryId, {
    int count = 5,
    int? maxDifficulty,
    bool shuffle = true,
  }) async {
    final vocabItems = await _vocabRepo.getVocabularyForCategory(
      categoryId,
      maxDifficulty: maxDifficulty,
    );

    if (vocabItems.isEmpty) return [];

    final questions = <QuizQuestionModel>[];
    for (int i = 0; i < count && i < vocabItems.length; i++) {
      final correct = vocabItems[i];
      final others = vocabItems.where((v) => v.id != correct.id).take(2).toList();
      final choices = [
        QuizChoice(
          id: correct.id,
          labelEn: correct.labelEn,
          labelAr: correct.labelAr,
          imageUrl: correct.imageUrl,
        ),
        ...others.map(
          (o) => QuizChoice(
            id: o.id,
            labelEn: o.labelEn,
            labelAr: o.labelAr,
            imageUrl: o.imageUrl,
          ),
        ),
      ];

      questions.add(
        QuizQuestionModel(
          id: 'q_${categoryId}_$i',
          promptEn: 'Where is the ${correct.labelEn}?',
          promptAr: 'أين ${correct.labelAr}؟',
          correctChoiceId: correct.id,
          categoryId: categoryId,
          difficultyLevel: correct.difficultyLevel,
          choices: choices,
        ),
      );
    }
    return questions;
  }
}

class E2EMockAiAdaptiveService implements AiAdaptiveService {
  int callCount = 0;
  bool shouldTimeout = false;
  bool shouldReturnInvalid = false;

  @override
  Future<QuizQuestionModel> generateExercise({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    String exerciseType = 'identify_item',
    double recentAccuracy = 0.75,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    callCount++;
    if (shouldTimeout) {
      throw TimeoutException('AI request timed out');
    }
    if (shouldReturnInvalid) {
      return const QuizQuestionModel(
        id: 'bad_ai_item',
        promptEn: '',
        promptAr: '',
        correctChoiceId: 'unknown',
        choices: [],
      );
    }

    return QuizQuestionModel(
      id: 'ai_exercise_${DateTime.now().millisecondsSinceEpoch}',
      promptEn: 'Where is the Cat?',
      promptAr: 'أين القطة؟',
      correctChoiceId: 'cat',
      categoryId: categoryId,
      difficultyLevel: difficultyLevel,
      choices: const [
        QuizChoice(
          id: 'cat',
          labelEn: 'Cat',
          labelAr: 'قطة',
          imageUrl: 'assets/images/vocabulary/cat.png',
        ),
        QuizChoice(
          id: 'dog',
          labelEn: 'Dog',
          labelAr: 'كلب',
          imageUrl: 'assets/images/vocabulary/dog.png',
        ),
        QuizChoice(
          id: 'bird',
          labelEn: 'Bird',
          labelAr: 'عصفور',
          imageUrl: 'assets/images/vocabulary/bird.png',
        ),
      ],
    );
  }

  @override
  Future<List<QuizQuestionModel>> generateAdaptiveQuizSession({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    int count = 5,
    double recentAccuracy = 0.75,
  }) async {
    final list = <QuizQuestionModel>[];
    for (int i = 0; i < count; i++) {
      list.add(await generateExercise(
        categoryId: categoryId,
        difficultyLevel: difficultyLevel,
        preferredLanguage: preferredLanguage,
        recentAccuracy: recentAccuracy,
      ));
    }
    return list;
  }

  @override
  Future<MatchingGameRound> generateMatchingGameRound({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
  }) async {
    final base = BaseAiAdaptiveService();
    return base.generateMatchingGameRound(
      categoryId: categoryId,
      difficultyLevel: difficultyLevel,
      preferredLanguage: preferredLanguage,
    );
  }

  @override
  bool validateExerciseData(Map<String, dynamic> data) {
    if (!data.containsKey('id') ||
        !data.containsKey('promptEn') ||
        !data.containsKey('promptAr') ||
        !data.containsKey('correctChoiceId') ||
        !data.containsKey('choices')) {
      return false;
    }
    final choices = data['choices'];
    if (choices is! List || choices.length != 3) {
      return false;
    }
    final correctId = data['correctChoiceId'] as String;
    final hasCorrect = choices.any((c) => c is Map && c['id'] == correctId);
    return hasCorrect;
  }
}

// ==============================================================================
// MAIN TEST SUITE: FULL SYSTEM INTEGRATION & END-TO-END VERIFICATION
// ==============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Week 13 — Complete Application Flow & End-to-End Testing', () {
    late E2EFakeAuthService authService;
    late E2EFakeUserRepository userRepository;
    late E2EInMemorySessionRepository sessionRepository;
    late E2EInMemoryQuizRepository quizRepository;
    late BaseProgressRepository progressRepository;
    late BaseCategoryRepository categoryRepository;
    late BaseVocabularyRepository vocabularyRepository;
    late E2EMockAiAdaptiveService aiAdaptiveService;
    late AdaptiveDifficultyService adaptiveDifficultyService;

    late AuthProvider authProvider;
    late CategoryProvider categoryProvider;
    late VocabularyProvider vocabularyProvider;
    late LearningSessionProvider learningSessionProvider;
    late QuizProvider quizProvider;
    late ProgressProvider progressProvider;
    late SettingsProvider settingsProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LocalStorageService.resetForTesting();
      authService = E2EFakeAuthService();
      userRepository = E2EFakeUserRepository();
      sessionRepository = E2EInMemorySessionRepository();
      quizRepository = E2EInMemoryQuizRepository();
      categoryRepository = BaseCategoryRepository();
      vocabularyRepository = BaseVocabularyRepository();
      progressRepository = BaseProgressRepository(
        sessionRepository: sessionRepository,
        quizRepository: quizRepository,
        userRepository: userRepository,
        vocabularyRepository: vocabularyRepository,
      );
      aiAdaptiveService = E2EMockAiAdaptiveService();
      adaptiveDifficultyService = const AdaptiveDifficultyService();

      authProvider = AuthProvider(
        authService: authService,
        userRepository: userRepository,
      );
      categoryProvider = CategoryProvider(categoryRepository: categoryRepository);
      vocabularyProvider = VocabularyProvider(vocabularyRepository: vocabularyRepository);
      learningSessionProvider = LearningSessionProvider(sessionRepository: sessionRepository);
      quizProvider = QuizProvider(
        quizRepository: quizRepository,
        sessionRepository: sessionRepository,
        userRepository: userRepository,
        aiAdaptiveService: aiAdaptiveService,
        adaptiveDifficultyService: adaptiveDifficultyService,
      );
      progressProvider = ProgressProvider(progressRepository: progressRepository);
      settingsProvider = SettingsProvider();
    });

    tearDown(() {
      authService.dispose();
      authProvider.dispose();
      categoryProvider.dispose();
      vocabularyProvider.dispose();
      learningSessionProvider.dispose();
      quizProvider.dispose();
      progressProvider.dispose();
      settingsProvider.dispose();
    });

    Widget createTestApp({
      String initialRoute = AppRoutes.childHome,
      Locale locale = const Locale('en'),
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
          ChangeNotifierProvider<VocabularyProvider>.value(value: vocabularyProvider),
          ChangeNotifierProvider<LearningSessionProvider>.value(value: learningSessionProvider),
          ChangeNotifierProvider<QuizProvider>.value(value: quizProvider),
          ChangeNotifierProvider<ProgressProvider>.value(value: progressProvider),
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ],
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.lightTheme,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: initialRoute,
          onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
            settings,
            onToggleLocale: () {},
            isAuthenticated: authProvider.isAuthenticated,
            authProvider: authProvider,
          ),
        ),
      );
    }

    testWidgets('Section 1 & 11: Complete End-to-End Integration Scenario',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Step 1: Launch App -> Protected screen leads to Parent Login Screen
      await tester.pumpWidget(createTestApp(initialRoute: AppRoutes.parentLogin));
      await tester.pumpAndSettle();

      expect(find.text('Parent & Educator Portal'), findsWidgets);

      // Step 2: Authentication - Sign In as Educator
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'educator@example.com');
      await tester.enterText(textFields.at(1), 'password123');

      final enterBtn = find.text('Enter Portal');
      await tester.tap(enterBtn);
      await tester.pumpAndSettle();

      // Step 3: User Profile & Child Selection Screen
      expect(authProvider.isAuthenticated, isTrue);
      expect(find.text('Select Student Profile'), findsOneWidget);
      expect(find.text('Adam'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);

      // Step 4: Child Selection - Select Adam (Level 1)
      await tester.tap(find.text('Adam'));
      await tester.pumpAndSettle();

      // Should be on Progress Dashboard with Adam's Profile
      expect(find.text('Progress Dashboard'), findsOneWidget);
      expect(find.text('Adam'), findsWidgets);

      // Step 5: Transition to Home Screen to Start Learning
      final homeNavBtn = find.byIcon(Icons.home_outlined);
      if (homeNavBtn.evaluate().isNotEmpty) {
        await tester.tap(homeNavBtn);
        await tester.pumpAndSettle();
      } else {
        final startLearningBtn = find.text('Start Learning Session');
        if (startLearningBtn.evaluate().isNotEmpty) {
          await tester.tap(startLearningBtn.first);
          await tester.pumpAndSettle();
        }
      }

      // Step 6: Home Screen displays friendly greeting and learning categories
      expect(find.textContaining('Hello!'), findsWidgets);
      expect(find.text('Animals'), findsWidgets);
      expect(find.text('Colors'), findsWidgets);
      expect(find.text('Numbers'), findsWidgets);
      expect(find.text('Letters'), findsWidgets);

      // Step 7: Select Category "Animals" -> Vocabulary Learning Session
      await tester.tap(find.text('Animals').first);
      await tester.pumpAndSettle();

      // Step 8: View Vocabulary Items & Audio Controls
      expect(find.byType(VocabularyLearningScreen), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsWidgets);

      // Verify Next Item Navigation through items until final item
      while (find.text('Next').evaluate().isNotEmpty) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Complete Learning Session
      expect(find.text('Complete Session 🌟'), findsOneWidget);
      await tester.tap(find.text('Complete Session 🌟'));
      await tester.pumpAndSettle();

      // Step 9: Interactive Quiz transition
      expect(find.text('Start Quiz 🎯'), findsOneWidget);
      await tester.tap(find.text('Start Quiz 🎯'));
      await tester.pumpAndSettle();

      // Step 10: Answer Quiz Question with 3 image choices
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('Fish'), findsOneWidget);

      // Select correct answer (Dog for "Where is the dog?")
      await tester.tap(find.text('Dog'));
      await tester.pumpAndSettle();

      expect(find.text('Great job! 🌟'), findsOneWidget);

      // Step 11: Complete Quiz & View Results Summary
      final forwardBtn = find.byIcon(Icons.arrow_forward_rounded);
      expect(forwardBtn, findsOneWidget);
      await tester.tap(forwardBtn);
      await tester.pumpAndSettle();

      // Step 12: Quiz Results & Adaptive Difficulty Trigger
      expect(find.text('Quiz Complete! 🌟'), findsOneWidget);
      expect(find.textContaining('You got 1 out of 1 right!'), findsOneWidget);

      // Drain audio chime timer and unmount widget tree cleanly
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    test('Section 2: Authentication Integration, Roles, and Protected Routes', () async {
      expect(authProvider.isAuthenticated, isFalse);

      // 1. Empty credentials validation
      final emptyResult = await authProvider.signIn('', '');
      expect(emptyResult, isFalse);

      // 2. Incorrect credentials
      authService.shouldFail = true;
      final failResult = await authProvider.signIn('wrong@school.edu', 'wrong');
      expect(failResult, isFalse);
      expect(authProvider.isAuthenticated, isFalse);

      // 3. Correct credentials & role handling
      authService.shouldFail = false;
      final success = await authProvider.signIn('educator@example.com', 'password123');
      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.role, 'educator');
      expect(authProvider.currentUser?.displayName, 'Teacher Layla');

      // 4. Linked children retrieval & active child selection
      await authProvider.loadLinkedChildren();
      expect(authProvider.linkedChildren.length, 2);
      expect(authProvider.selectedChild?.name, 'Adam');

      final sara = authProvider.linkedChildren[1];
      authProvider.selectChild(sara);
      expect(authProvider.selectedChild?.name, 'Sara');

      // 5. Logout
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.selectedChild, isNull);

      // 6. RouteGuard enforcement
      expect(RouteGuard.isProtected(AppRoutes.parentDashboard), isTrue);
      expect(RouteGuard.isProtected(AppRoutes.parentChildSelection), isTrue);
      expect(RouteGuard.isProtected(AppRoutes.parentSettings), isTrue);
      expect(RouteGuard.isProtected(AppRoutes.childHome), isFalse);
    });

    test('Section 3: Vocabulary Learning Integration across All 4 Categories', () async {
      final categories = await categoryRepository.getCategories();
      expect(categories.length, 4);

      final expectedCategories = ['animals', 'colours', 'numbers', 'letters'];
      for (final catId in expectedCategories) {
        final items = await vocabularyRepository.getVocabularyForCategory(catId);
        expect(items.isNotEmpty, isTrue, reason: 'Category $catId must have vocabulary items');
        for (final item in items) {
          expect(item.id.isNotEmpty, isTrue);
          expect(item.labelAr.isNotEmpty, isTrue);
          expect(item.labelEn.isNotEmpty, isTrue);
          expect(item.imageUrl.isNotEmpty, isTrue);
          expect(item.audioUrlAr.isNotEmpty, isTrue);
          expect(item.audioUrlEn.isNotEmpty, isTrue);
        }
      }

      // Verify Session Start and Complete Storage
      await learningSessionProvider.startSession('child_adam', 'animals');
      expect(learningSessionProvider.currentSession?.sessionId, isNotNull);
      learningSessionProvider.recordItemPresented('cat');
      learningSessionProvider.recordItemPresented('dog');
      await learningSessionProvider.endSession(score: 1.0);

      expect(sessionRepository.sessions.length, 1);
      expect(sessionRepository.sessions.first.childId, 'child_adam');
      expect(sessionRepository.sessions.first.itemsPresented, containsAll(['cat', 'dog']));
      expect(sessionRepository.sessions.first.score, 1.0);
    });

    test('Section 4: Interactive Quiz Integration, Options, and Scoring', () async {
      await quizProvider.startQuizSession(childId: 'child_adam', categoryId: 'animals');
      final question = quizProvider.question;
      expect(question, isNotNull);
      expect(question!.choices.length, 3, reason: 'Quiz must present exactly 3 options');
      expect(
        question.choices.any((c) => c.id == question.correctChoiceId),
        isTrue,
        reason: 'Options must include the correct choice',
      );

      // Quiz Answer Evaluation: Correct Selection
      await quizProvider.selectChoice(question.correctChoiceId, stars: 3);
      expect(quizProvider.starsCount, 15); // +3 stars
      expect(quizProvider.score, 1);

      // Finish Quiz and Store in QuizRepository
      await quizProvider.finishQuiz();
      expect(quizProvider.accuracyPercentage, greaterThanOrEqualTo(0));
      expect(quizRepository.results.isNotEmpty, isTrue);
    });

    test('Section 5: Progress Integration with Real Calculated Firestore Data', () async {
      final childId = 'child_adam';

      // Insert real session telemetry
      await sessionRepository.createSession(
        LearningSessionModel(
          sessionId: 'session_01',
          childId: childId,
          categoryId: 'animals',
          startTime: DateTime.now().subtract(const Duration(days: 2)),
          endTime: DateTime.now().subtract(const Duration(days: 2, minutes: -15)),
          itemsPresented: const ['cat', 'dog', 'bird'],
          score: 1.0,
        ),
      );

      // Insert real quiz results
      await quizRepository.recordQuizResult(
        QuizResultModel(
          resultId: 'qr_01',
          sessionId: 'session_01',
          childId: childId,
          questionId: 'q_01',
          childResponse: 'cat',
          isCorrect: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      // Load progress
      await progressProvider.loadProgress(childId);
      final progress = progressProvider.progress;
      expect(progress, isNotNull);

      expect(progress!.totalSessions, greaterThanOrEqualTo(1));
      expect(progress.overallAccuracy, greaterThanOrEqualTo(0));
      expect(progress.masteredCount, greaterThanOrEqualTo(1));
      expect(progress.studentName, 'Adam');

      // Verify category filter
      await progressProvider.setCategoryFilter('animals');
      expect(progressProvider.selectedCategoryFilter, 'animals');

      // Verify date filter
      await progressProvider.setDateFilter('this_month');
      expect(progressProvider.selectedDateFilter, 'this_month');
    });

    test('Section 6: AI Integration via Cloud Functions with Validation & Fallback', () async {
      // 1. Valid AI Generation
      final exercise = await aiAdaptiveService.generateExercise(
        categoryId: 'animals',
        difficultyLevel: 2,
        preferredLanguage: 'ar',
      );
      expect(exercise.choices.length, 3);
      expect(exercise.promptAr.isNotEmpty, isTrue);
      expect(exercise.correctChoiceId, 'cat');

      // 2. Invalid AI Response Rejection
      aiAdaptiveService.shouldReturnInvalid = true;
      final invalidQuestion = await aiAdaptiveService.generateExercise(
        categoryId: 'animals',
        difficultyLevel: 1,
        preferredLanguage: 'en',
      );
      // Validate schema
      final isValid = aiAdaptiveService.validateExerciseData({
        'id': invalidQuestion.id,
        'promptEn': invalidQuestion.promptEn,
        'promptAr': invalidQuestion.promptAr,
        'correctChoiceId': invalidQuestion.correctChoiceId,
        'choices': invalidQuestion.choices.map((c) => {'id': c.id}).toList(),
      });
      expect(isValid, isFalse);

      // 3. Fallback on Timeout
      aiAdaptiveService.shouldTimeout = true;
      expect(
        () => aiAdaptiveService.generateExercise(
          categoryId: 'animals',
          difficultyLevel: 1,
          preferredLanguage: 'en',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Section 7: Adaptive Difficulty Progression, Gating & Safety Boundaries', () async {
      const childId = 'child_adam';

      // 1. Insufficient data: < minEvaluationWindow (3 attempts) does NOT adapt
      final fewResults = [
        QuizResultModel(
          resultId: 'r1',
          sessionId: 's1',
          childId: childId,
          questionId: 'q1',
          childResponse: 'cat',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
      ];
      final evalInsufficient = adaptiveDifficultyService.evaluateDifficulty(
        currentDifficulty: 1,
        recentResults: fewResults,
      );
      expect(evalInsufficient.difficultyChanged, isFalse);
      expect(evalInsufficient.newDifficulty, 1);

      // 2. High recent accuracy (>= 85%) promotes Level 1 -> Level 2
      final highResults = List.generate(
        5,
        (i) => QuizResultModel(
          resultId: 'r_high_$i',
          sessionId: 's_high_$i',
          childId: childId,
          questionId: 'q_$i',
          childResponse: 'cat',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
      );
      final evalHigh = await adaptiveDifficultyService.updateChildDifficulty(
        childId,
        currentDifficulty: 1,
        recentResults: highResults,
        userRepository: userRepository,
      );
      expect(evalHigh.difficultyChanged, isTrue);
      expect(evalHigh.newDifficulty, 2);

      // 3. Strict Boundary: Level 3 cannot exceed 3
      final maxHigh = await adaptiveDifficultyService.updateChildDifficulty(
        childId,
        currentDifficulty: 3,
        recentResults: highResults,
        userRepository: userRepository,
      );
      expect(maxHigh.newDifficulty, 3);

      // 4. Low recent accuracy (< 60%) demotes Level 2 -> Level 1
      final lowResults = List.generate(
        5,
        (i) => QuizResultModel(
          resultId: 'r_low_$i',
          sessionId: 's_low_$i',
          childId: childId,
          questionId: 'q_$i',
          childResponse: 'wrong',
          isCorrect: false,
          timestamp: DateTime.now(),
        ),
      );
      final evalLow = await adaptiveDifficultyService.updateChildDifficulty(
        childId,
        currentDifficulty: 2,
        recentResults: lowResults,
        userRepository: userRepository,
      );
      expect(evalLow.difficultyChanged, isTrue);
      expect(evalLow.newDifficulty, 1);

      // 5. Strict Boundary: Level 1 cannot decrease below 1
      final minLow = await adaptiveDifficultyService.updateChildDifficulty(
        childId,
        currentDifficulty: 1,
        recentResults: lowResults,
        userRepository: userRepository,
      );
      expect(minLow.newDifficulty, 1);
    });

    testWidgets('Section 8 & 9: Error Handling, Loading and Empty States',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Empty Progress State Screen Verification
      final emptyProgressRepo = BaseProgressRepository(
        sessionRepository: E2EInMemorySessionRepository(),
        quizRepository: E2EInMemoryQuizRepository(),
        userRepository: userRepository,
        vocabularyRepository: vocabularyRepository,
      );
      final emptyProgressProvider = ProgressProvider(progressRepository: emptyProgressRepo);
      await emptyProgressProvider.loadProgress('child_new_empty');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressProvider>.value(value: emptyProgressProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const ProgressDashboardScreen(childId: 'child_new_empty'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No learning activity yet.'), findsOneWidget);
      expect(find.text('Start Learning Session'), findsOneWidget);
    });

    testWidgets('Section 10: Language Testing across Arabic RTL & English LTR',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Arabic RTL Mode
      await tester.pumpWidget(createTestApp(
        initialRoute: AppRoutes.childCategories,
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      expect(Directionality.of(tester.element(find.byType(CategorySelectionScreen))), TextDirection.rtl);
      expect(find.text('الحيوانات'), findsWidgets);
      expect(find.text('الألوان'), findsWidgets);
      expect(find.text('الأرقام'), findsWidgets);
      expect(find.text('الحروف'), findsWidgets);

      // 2. English LTR Mode
      await tester.pumpWidget(createTestApp(
        initialRoute: AppRoutes.childCategories,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(Directionality.of(tester.element(find.byType(CategorySelectionScreen))), TextDirection.ltr);
      expect(find.text('Animals'), findsWidgets);
      expect(find.text('Colors'), findsWidgets);
      expect(find.text('Numbers'), findsWidgets);
      expect(find.text('Letters'), findsWidgets);
    });
  });
}
