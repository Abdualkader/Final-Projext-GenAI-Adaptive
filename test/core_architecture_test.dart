import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/core/constants/app_constants.dart';
import 'package:asd_learning_assistant/core/constants/firebase_collections.dart';
import 'package:asd_learning_assistant/core/constants/app_routes.dart';
import 'package:asd_learning_assistant/core/routes/route_guard.dart';
import 'package:asd_learning_assistant/core/errors/app_exceptions.dart';
import 'package:asd_learning_assistant/core/errors/ui_state.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/category_model.dart';
import 'package:asd_learning_assistant/models/vocabulary_item_model.dart';
import 'package:asd_learning_assistant/models/learning_session_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/models/progress_model.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/repositories/category_repository.dart';
import 'package:asd_learning_assistant/repositories/vocabulary_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/progress_repository.dart';
import 'package:asd_learning_assistant/providers/category_provider.dart';
import 'package:asd_learning_assistant/providers/vocabulary_provider.dart';
import 'package:asd_learning_assistant/providers/learning_session_provider.dart';
import 'package:asd_learning_assistant/providers/quiz_provider.dart';
import 'package:asd_learning_assistant/providers/progress_provider.dart';
import 'package:asd_learning_assistant/providers/settings_provider.dart';
import 'package:asd_learning_assistant/widgets/app_card.dart';
import 'package:asd_learning_assistant/widgets/loading_widget.dart';
import 'package:asd_learning_assistant/widgets/app_error_widget.dart';
import 'package:asd_learning_assistant/widgets/empty_state_widget.dart';
import 'package:asd_learning_assistant/widgets/audio_button.dart';
import 'package:asd_learning_assistant/widgets/app_progress_indicator.dart';

Widget _wrapWidget(Widget child, [Locale locale = const Locale('en')]) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  group('Task 3: Core Constants Tests', () {
    test('AppConstants contains correct defaults and category IDs', () {
      expect(AppConstants.appNameEn, 'ASD Learning Assistant');
      expect(AppConstants.allCategoryIds, contains('letters'));
      expect(AppConstants.allCategoryIds, contains('numbers'));
      expect(AppConstants.allCategoryIds, contains('colours'));
      expect(AppConstants.allCategoryIds, contains('animals'));
      expect(AppConstants.minTouchTargetSize, 48.0);
      expect(AppConstants.preferredTouchTargetSize, 64.0);
      expect(AppConstants.targetSessionMinutes, 5);
      expect(AppConstants.optionsPerQuizQuestion, 3);
    });

    test('FirebaseCollections contains correct collection names', () {
      expect(FirebaseCollections.users, 'users');
      expect(FirebaseCollections.children, 'children');
      expect(FirebaseCollections.categories, 'categories');
      expect(FirebaseCollections.vocabularyItems, 'vocabularyItems');
      expect(FirebaseCollections.sessions, 'sessions');
      expect(FirebaseCollections.quizResults, 'quizResults');
      expect(FirebaseCollections.progressRecords, 'progressRecords');
    });
  });

  group('Task 4: Data Models Serialization Tests', () {
    test('UserModel serialization and helper properties', () {
      final now = DateTime.now();
      final user = UserModel(
        userId: 'u_123',
        email: 'parent@example.com',
        displayName: 'Sarah',
        role: 'parent',
        preferredLanguage: 'ar',
        linkedChildIds: const ['child_adam'],
        createdAt: now,
      );

      expect(user.isParent, true);
      expect(user.isEducator, false);

      final map = user.toMap();
      expect(map['userId'], 'u_123');
      expect(map['email'], 'parent@example.com');

      final reconstructed = UserModel.fromMap(map);
      expect(reconstructed.userId, 'u_123');
      expect(reconstructed.email, 'parent@example.com');
      expect(reconstructed.linkedChildIds, contains('child_adam'));
    });

    test('ChildModel serialization and age calculation', () {
      final birthDate = DateTime.now().subtract(const Duration(days: 365 * 6));
      final child = ChildModel(
        childId: 'c_1',
        parentId: 'p_1',
        name: 'Omar',
        birthDate: birthDate,
        currentDifficultyLevel: 2,
        preferredLanguage: 'ar',
        createdAt: DateTime.now(),
      );

      expect(child.ageYears, isNotNull);
      expect(child.ageYears! >= 5, true);

      final map = child.toMap();
      expect(map['name'], 'Omar');
      expect(map['currentDifficultyLevel'], 2);

      final reconstructed = ChildModel.fromMap(map);
      expect(reconstructed.childId, 'c_1');
      expect(reconstructed.name, 'Omar');
      expect(reconstructed.currentDifficultyLevel, 2);
    });

    test('CategoryModel database schema compatibility', () {
      const cat = CategoryModel(
        id: 'animals',
        nameEn: 'Animals',
        nameAr: 'الحيوانات',
        iconUrl: 'https://storage/animals.png',
        orderIndex: 4,
      );

      expect(cat.categoryId, 'animals');
      expect(cat.localizedName(true), 'الحيوانات');
      expect(cat.localizedName(false), 'Animals');

      final map = cat.toMap();
      expect(map['categoryId'], 'animals');
      expect(map['orderIndex'], 4);

      final reconstructed = CategoryModel.fromMap(map);
      expect(reconstructed.id, 'animals');
      expect(reconstructed.orderIndex, 4);
    });

    test('VocabularyItemModel schema and legacy compatibility', () {
      const item = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قطة',
        transliteration: 'Qittah',
        imageUrl: 'assets/cat.png',
        audioUrlEn: '/audio/cat.mp3',
        audioUrlAr: '/audio/ar_cat.mp3',
        difficultyLevel: 1,
      );

      expect(item.itemId, 'cat');
      expect(item.wordEn, 'Cat');
      expect(item.wordAr, 'قطة');
      expect(item.imagePath, 'assets/cat.png');
      expect(item.audioPathEn, '/audio/cat.mp3');
      expect(item.audioPathAr, '/audio/ar_cat.mp3');

      final map = item.toMap();
      expect(map['itemId'], 'cat');
      expect(map['difficultyLevel'], 1);

      final reconstructed = VocabularyItemModel.fromMap(map);
      expect(reconstructed.id, 'cat');
      expect(reconstructed.labelEn, 'Cat');
    });

    test('LearningSessionModel serialization and duration', () {
      final start = DateTime.now().subtract(const Duration(minutes: 5));
      final end = DateTime.now();
      final session = LearningSessionModel(
        sessionId: 'sess_1',
        childId: 'c_1',
        categoryId: 'animals',
        startTime: start,
        endTime: end,
        itemsPresented: const ['cat', 'dog'],
        score: 0.95,
      );

      expect(session.duration, isNotNull);
      expect(session.duration!.inMinutes >= 4, true);

      final map = session.toMap();
      final reconstructed = LearningSessionModel.fromMap(map);
      expect(reconstructed.sessionId, 'sess_1');
      expect(reconstructed.itemsPresented.length, 2);
      expect(reconstructed.score, 0.95);
    });

    test('QuizResultModel serialization', () {
      final now = DateTime.now();
      final result = QuizResultModel(
        resultId: 'res_1',
        sessionId: 'sess_1',
        questionId: 'q_1',
        childResponse: 'cat',
        isCorrect: true,
        responseTimeMs: 2500,
        timestamp: now,
      );

      final map = result.toMap();
      expect(map['isCorrect'], true);
      expect(map['responseTimeMs'], 2500);

      final reconstructed = QuizResultModel.fromMap(map);
      expect(reconstructed.resultId, 'res_1');
      expect(reconstructed.isCorrect, true);
    });

    test('ProgressRecordModel serialization', () {
      final record = ProgressRecordModel(
        recordId: 'rec_1',
        childId: 'c_1',
        date: DateTime.now(),
        itemsMastered: const ['cat', 'dog', 'one'],
        quizScores: const [85.0, 90.0],
        overallAccuracy: 0.88,
      );

      final map = record.toMap();
      expect(map['overallAccuracy'], 0.88);
      expect(map['itemsMastered'], contains('cat'));

      final reconstructed = ProgressRecordModel.fromMap(map);
      expect(reconstructed.recordId, 'rec_1');
      expect(reconstructed.overallAccuracy, 0.88);
    });
  });

  group('Task 5: Repositories Tests', () {
    test('CategoryRepository loads all categories and single by ID', () async {
      final repo = BaseCategoryRepository();
      final categories = await repo.getCategories();
      expect(categories.length, 4);

      final animal = await repo.getCategoryById('animals');
      expect(animal, isNotNull);
      expect(animal!.nameEn, 'Animals');

      final unknown = await repo.getCategoryById('nonexistent');
      expect(unknown, isNull);
    });

    test('VocabularyRepository loads items by category and difficulty filter', () async {
      final repo = BaseVocabularyRepository();
      final animals = await repo.getVocabularyForCategory('animals');
      expect(animals.isNotEmpty, true);

      final filtered = await repo.getVocabularyForCategory('animals', maxDifficulty: 1);
      expect(filtered.isNotEmpty, true);

      final item = await repo.getVocabularyItemById('cat');
      expect(item, isNotNull);
      expect(item!.wordEn, 'Cat');
    });

    test('QuizRepository loads question and records result', () async {
      final repo = BaseQuizRepository();
      final question = await repo.getQuizQuestionForCategory('animals');
      expect(question.id, isNotEmpty);
      expect(question.choices.length, 3);

      final result = QuizResultModel(
        resultId: 'test_res',
        sessionId: 'test_sess',
        questionId: question.id,
        childResponse: 'dog',
        isCorrect: true,
        timestamp: DateTime.now(),
      );

      await repo.recordQuizResult(result);
      final sessionResults = await repo.getQuizResultsForSession('test_sess');
      expect(sessionResults.length, 1);
      expect(sessionResults.first.isCorrect, true);
    });

    test('SessionRepository records and retrieves session', () async {
      final repo = BaseSessionRepository();
      final session = LearningSessionModel(
        sessionId: 'sess_test_1',
        childId: 'child_adam',
        categoryId: 'numbers',
        startTime: DateTime.now(),
        itemsPresented: const ['one', 'two'],
      );

      await repo.recordSession(session);
      final list = await repo.getRecentSessions('child_adam');
      expect(list.any((s) => s.sessionId == 'sess_test_1'), true);
    });

    test('ProgressRepository returns structured progress', () async {
      final repo = BaseProgressRepository();
      final progress = await repo.getProgressForChild('child_adam');
      expect(progress.studentName, 'Adam');
      expect(progress.totalSessions, greaterThan(0));
      expect(progress.categoryAccuracies.length, 4);
    });

    test('UserRepository returns linked child profiles and user by ID', () async {
      final repo = BaseUserRepository();
      final user = await repo.getUserById('u_mock');
      expect(user, isNotNull);
      expect(user!.email, 'educator@example.com');

      final children = await repo.getLinkedChildren('u_mock');
      expect(children.isNotEmpty, true);
      expect(children.first.name, 'Adam');
    });
  });

  group('Task 7 & 8: Providers and Error Handling Tests', () {
    test('UiState transitions between loading, success, empty, and error', () {
      const initial = UiState<String>.initial();
      expect(initial.isInitial, true);

      const loading = UiState<String>.loading();
      expect(loading.isLoading, true);

      const success = UiState<String>.success('data');
      expect(success.isSuccess, true);
      expect(success.data, 'data');

      const empty = UiState<String>.empty();
      expect(empty.isEmpty, true);

      final error = UiState<String>.error(const NotFoundException());
      expect(error.isError, true);
      expect(error.getDisplayError(false, isChildMode: true), contains('explore another one'));
    });

    test('ProgressProvider loads child progress and updates category filter', () async {
      final provider = ProgressProvider();
      expect(provider.uiState.isInitial, true);

      await provider.loadProgress('child_adam');
      expect(provider.uiState.isSuccess, true);
      expect(provider.progress?.studentName, 'Adam');

      provider.setCategoryFilter('animals');
      expect(provider.selectedCategoryFilter, 'animals');
    });

    test('CategoryProvider loads categories and manages selection', () async {
      final provider = CategoryProvider();
      expect(provider.uiState.isInitial, true);

      await provider.loadCategories();
      expect(provider.uiState.isSuccess, true);

      expect(provider.categories.length, 4);

      provider.selectCategory('numbers');
      expect(provider.selectedCategory?.id, 'numbers');
    });

    test('VocabularyProvider cycles items and manages audio status', () async {
      final provider = VocabularyProvider();
      await provider.loadVocabulary('animals');

      expect(provider.uiState.isSuccess, true);
      expect(provider.currentIndex, 0);
      expect(provider.currentItem?.wordEn, 'Cat');

      provider.nextItem();
      expect(provider.currentIndex, 1);
      expect(provider.currentItem?.wordEn, 'Dog');

      provider.previousItem();
      expect(provider.currentIndex, 0);
    });

    test('LearningSessionProvider manages active session telemetry', () async {
      final provider = LearningSessionProvider();
      expect(provider.isSessionActive, false);

      provider.startSession('child_adam', 'animals');
      expect(provider.isSessionActive, true);

      provider.recordItemPresented('cat');
      provider.recordItemPresented('dog');
      expect(provider.itemsPresented, contains('cat'));
      expect(provider.itemsPresented, contains('dog'));

      await provider.endSession(score: 1.0);
      expect(provider.isSessionActive, false);
      expect(provider.itemsPresented.isEmpty, true);
    });

    test('QuizProvider loads question, evaluates choice, and awards stars', () async {
      final provider = QuizProvider();
      await provider.loadQuizQuestion('animals');

      expect(provider.uiState.isSuccess, true);
      expect(provider.isAnswered, false);

      final correctId = provider.question!.correctChoiceId;
      final initialStars = provider.starsCount;

      await provider.selectChoice(correctId);
      expect(provider.isAnswered, true);
      expect(provider.isCorrect, true);
      expect(provider.starsCount, initialStars + 1);

      provider.resetSelection();
      expect(provider.isAnswered, false);
    });

    test('SettingsProvider updates volume, duration, and bilingual locale', () {
      final provider = SettingsProvider();
      expect(provider.volume, AppConstants.defaultVolume);

      provider.setVolume(0.5);
      expect(provider.volume, 0.5);

      provider.setSessionDuration(8);
      expect(provider.sessionDurationMinutes, 8);

      expect(provider.isArabic, false);
      provider.toggleLocale();
      expect(provider.isArabic, true);
      provider.toggleLocale();
      expect(provider.isArabic, false);
    });

    test('AppException delivers gentle child messages and parent messages', () {
      const netEx = NetworkException();
      expect(netEx.toChildFriendlyMessage(false), contains("let’s try again"));
      expect(netEx.toChildFriendlyMessage(true), contains("سحابة"));

      const authEx = AuthException(message: 'Invalid credentials');
      expect(authEx.toParentMessage(false), 'Invalid credentials');
    });

    test('RouteGuard correctly classifies protected vs open routes', () {
      expect(RouteGuard.isProtected(AppRoutes.parentDashboard), true);
      expect(RouteGuard.isProtected(AppRoutes.parentChildSelection), true);
      expect(RouteGuard.isProtected(AppRoutes.parentSettings), true);

      expect(RouteGuard.isProtected(AppRoutes.childHome), false);
      expect(RouteGuard.isProtected(AppRoutes.childCategories), false);
      expect(RouteGuard.isProtected(AppRoutes.childLearning), false);
      expect(RouteGuard.isProtected(AppRoutes.childQuiz), false);
      expect(RouteGuard.isProtected(AppRoutes.parentLogin), false);

      expect(RouteGuard.canAccess(AppRoutes.parentDashboard, isAuthenticated: false), false);
      expect(RouteGuard.canAccess(AppRoutes.parentDashboard, isAuthenticated: true), true);
      expect(RouteGuard.canAccess(AppRoutes.childHome, isAuthenticated: false), true);
    });
  });

  group('Task 10: Reusable Widgets Tests', () {
    testWidgets('AppCard renders child and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWidget(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, true);
    });

    testWidgets('LoadingWidget renders gentle sensory indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWidget(
          const LoadingWidget(message: 'Loading calmly...'),
        ),
      );

      expect(find.text('Loading calmly...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppErrorWidget renders gentle child mode vs parent mode', (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrapWidget(
          AppErrorWidget(
            isChildMode: true,
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text("It's okay, let's try again together! 🌱"), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('EmptyStateWidget renders message and action button', (WidgetTester tester) async {
      bool actionClicked = false;
      await tester.pumpWidget(
        _wrapWidget(
          EmptyStateWidget(
            title: 'No vocabulary cards yet',
            subtitle: 'Choose a different category',
            actionLabel: 'Go Back',
            onAction: () => actionClicked = true,
          ),
        ),
      );

      expect(find.text('No vocabulary cards yet'), findsOneWidget);
      expect(find.text('Choose a different category'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);

      await tester.tap(find.text('Go Back'));
      expect(actionClicked, true);
    });

    testWidgets('AudioButton renders 64dp accessible speaker button', (WidgetTester tester) async {
      bool played = false;
      await tester.pumpWidget(
        _wrapWidget(
          AudioButton(
            onPressed: () => played = true,
          ),
        ),
      );

      expect(find.byType(AudioButton), findsOneWidget);
      await tester.tap(find.byType(AudioButton));
      expect(played, true);
    });

    testWidgets('AppProgressIndicator renders fractional progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWidget(
          const AppProgressIndicator(
            currentStep: 2,
            totalSteps: 5,
          ),
        ),
      );

      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
