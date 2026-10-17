import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:asd_learning_assistant/core/constants/app_routes.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:asd_learning_assistant/models/category_model.dart';
import 'package:asd_learning_assistant/models/learning_session_model.dart';
import 'package:asd_learning_assistant/models/vocabulary_item_model.dart';
import 'package:asd_learning_assistant/providers/category_provider.dart';
import 'package:asd_learning_assistant/providers/learning_session_provider.dart';
import 'package:asd_learning_assistant/providers/vocabulary_provider.dart';
import 'package:asd_learning_assistant/repositories/category_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/vocabulary_repository.dart';
import 'package:asd_learning_assistant/screens/child/vocabulary_learning_screen.dart';
import 'package:asd_learning_assistant/services/audio_service.dart';
import 'package:asd_learning_assistant/services/sample_data_service.dart';
import 'package:asd_learning_assistant/widgets/vocabulary_card.dart';

/// Test mock implementation of [SessionRepository] capturing session telemetry.
class MockSessionRepository implements SessionRepository {
  final List<LearningSessionModel> storedSessions = [];
  bool completeSessionCalled = false;
  String? lastCompletedSessionId;
  DateTime? lastEndTime;
  double? lastScore;

  @override
  Future<void> createSession(LearningSessionModel session) async {
    storedSessions.add(session);
  }

  @override
  Future<void> recordSession(LearningSessionModel session) async {
    final idx = storedSessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (idx != -1) {
      storedSessions[idx] = session;
    } else {
      storedSessions.add(session);
    }
  }

  @override
  Future<void> updateSession(LearningSessionModel session) async {
    final idx = storedSessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (idx != -1) {
      storedSessions[idx] = session;
    } else {
      storedSessions.add(session);
    }
  }

  @override
  Future<void> completeSession(
    String sessionId, {
    required DateTime endTime,
    required double score,
  }) async {
    completeSessionCalled = true;
    lastCompletedSessionId = sessionId;
    lastEndTime = endTime;
    lastScore = score;
    final idx = storedSessions.indexWhere((s) => s.sessionId == sessionId);
    if (idx != -1) {
      storedSessions[idx] = storedSessions[idx].copyWith(
        endTime: endTime,
        score: score,
      );
    }
  }

  @override
  Future<LearningSessionModel?> getSessionById(String sessionId) async {
    try {
      return storedSessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LearningSessionModel>> getRecentSessions(String childId, {int limit = 10}) async {
    return storedSessions.where((s) => s.childId == childId).toList();
  }
}

/// Helper to wrap widgets with localization and providers for test environment.
Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  CategoryProvider? categoryProvider,
  VocabularyProvider? vocabularyProvider,
  LearningSessionProvider? sessionProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CategoryProvider?>.value(
        value: categoryProvider ?? CategoryProvider(categoryRepository: BaseCategoryRepository()),
      ),
      ChangeNotifierProvider<VocabularyProvider?>.value(
        value: vocabularyProvider ??
            VocabularyProvider(
              vocabularyRepository: BaseVocabularyRepository(),
              audioService: AudioService(),
            ),
      ),
      ChangeNotifierProvider<LearningSessionProvider?>.value(
        value: sessionProvider ?? LearningSessionProvider(),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        AppRoutes.childQuiz: (context) {
          final arg = ModalRoute.of(context)?.settings.arguments as String? ?? 'animals';
          return Scaffold(
            body: Center(
              child: Text('Mock Quiz Screen for $arg'),
            ),
          );
        },
      },
      home: child,
    ),
  );
}

void main() {
  group('Week 9 - Task 2 & Task 8: Learning Session Initialization & Telemetry', () {
    test('Starting session records childId, categoryId, startTime, and persists to repository', () async {
      final mockRepo = MockSessionRepository();
      final sessionProvider = LearningSessionProvider(sessionRepository: mockRepo);

      expect(sessionProvider.isSessionActive, false);
      expect(sessionProvider.isSessionCompleted, false);

      final session = await sessionProvider.startSession('child_adam_001', 'letters');

      expect(sessionProvider.isSessionActive, true);
      expect(session.childId, 'child_adam_001');
      expect(session.categoryId, 'letters');
      expect(session.startTime, isNotNull);
      expect(mockRepo.storedSessions.length, 1);
      expect(mockRepo.storedSessions.first.sessionId, session.sessionId);
    });

    test('Recording items presented updates active session telemetry without duplicating', () async {
      final mockRepo = MockSessionRepository();
      final sessionProvider = LearningSessionProvider(sessionRepository: mockRepo);

      await sessionProvider.startSession('child_adam_001', 'animals');
      sessionProvider.recordItemPresented('cat');
      sessionProvider.recordItemPresented('dog');
      sessionProvider.recordItemPresented('cat'); // duplicate ignored

      expect(sessionProvider.itemsPresented, ['cat', 'dog']);
      expect(mockRepo.storedSessions.first.itemsPresented, ['cat', 'dog']);
    });

    test('Ending session calculates duration, records endTime, and finalizes record in Firestore', () async {
      final mockRepo = MockSessionRepository();
      final sessionProvider = LearningSessionProvider(sessionRepository: mockRepo);

      await sessionProvider.startSession('child_adam_001', 'numbers');
      sessionProvider.recordItemPresented('num_1');
      sessionProvider.recordItemPresented('num_2');

      final completed = await sessionProvider.endSession(score: 1.0);

      expect(completed, isNotNull);
      expect(completed!.endTime, isNotNull);
      expect(completed.score, 1.0);
      expect(completed.duration, isNotNull);
      expect(sessionProvider.isSessionActive, false);
      expect(sessionProvider.isSessionCompleted, true);
      expect(sessionProvider.lastCompletedSession?.sessionId, completed.sessionId);
      expect(mockRepo.completeSessionCalled, true);
    });
  });

  group('Week 9 - Task 3, 4, 5, & 6: Learning Item Interface, Media & Bilingual Audio', () {
    testWidgets('Renders all four learning categories with bilingual typography and aspect-ratio image',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final categories = ['letters', 'numbers', 'colors', 'animals'];

      for (final catId in categories) {
        final vocabProvider = VocabularyProvider();
        await vocabProvider.loadVocabulary(catId);

        await tester.pumpWidget(
          _buildTestApp(
            vocabularyProvider: vocabProvider,
            child: VocabularyLearningScreen(
              key: ValueKey(catId),
              categoryId: catId,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify active items and bilingual display
        expect(vocabProvider.items.isNotEmpty, true);
        final firstItem = vocabProvider.items.first;

        expect(find.text(firstItem.wordEn), findsOneWidget);
        expect(find.text(firstItem.wordAr), findsOneWidget);
        expect(find.text('🔊  Play Audio'), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Audio playback handles debouncing to prevent rapid double-tap instability',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('animals');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'animals'),
        ),
      );
      await tester.pumpAndSettle();

      final audioBtn = find.text('🔊  Play Audio');
      expect(audioBtn, findsOneWidget);

      // Rapid consecutive taps (debounced)
      await tester.tap(audioBtn);
      await tester.tap(audioBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Visual feedback posted safely
      expect(find.text('🔊 Cat • قِطَّة'), findsOneWidget);

      // Allow audio playback simulation (600ms) and snackbar (2s) to finish, then unmount
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Bilingual Arabic RTL view renders Arabic with Harakat prominently',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('letters');

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'letters'),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic labels
      expect(find.text('أَلِف'), findsOneWidget);
      expect(find.text('Letter A'), findsOneWidget);
      expect(find.text('🔊  استمع للنطق'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Week 9 - Task 7, 10, & 11: Navigation, Completion & Gentle Positive Reinforcement', () {
    testWidgets('Navigating through items advances progress counter and reaches Complete Session',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = MockSessionRepository();
      final sessionProvider = LearningSessionProvider(sessionRepository: mockRepo);
      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('numbers');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          sessionProvider: sessionProvider,
          child: const VocabularyLearningScreen(categoryId: 'numbers'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Advance through all items
      for (int i = 1; i <= 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Final item reached (5 / 5)
      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.text('Complete Session 🌟'), findsOneWidget);

      // Tap Complete Session
      await tester.tap(find.text('Complete Session 🌟'));
      await tester.pumpAndSettle();

      // Verify celebratory completion view with 3 stars and positive reinforcement (Task 10 & 11)
      expect(find.text('Session Complete! 🌟'), findsOneWidget);
      expect(find.text('You learned all words in this category!'), findsOneWidget);
      expect(find.text('5 words learned!'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));

      // Verify session was persisted in repository
      expect(mockRepo.completeSessionCalled, true);
      expect(sessionProvider.isSessionCompleted, true);

      // Verify Quiz readiness button
      expect(find.text('Start Quiz 🎯'), findsOneWidget);
      await tester.tap(find.text('Start Quiz 🎯'));
      await tester.pumpAndSettle();

      expect(find.text('Mock Quiz Screen for numbers'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Week 9 - Task 9: Inactivity Audio Reminder', () {
    testWidgets('Inactivity trigger shows non-alarming audio replay prompt and gentle pronunciation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('animals');

      // Use a fast 200ms inactivity duration for testing
      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(
            categoryId: 'animals',
            inactivityDuration: Duration(milliseconds: 200),
          ),
        ),
      );
      // Pump frame without advancing past 200ms timer
      await tester.pump();

      // Initially no reminder banner
      expect(find.text("Let's listen again! 🔊"), findsNothing);

      // Let the 200ms inactivity timer fire
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      // Verify gentle non-alarming prompt appears
      expect(find.text("Let's listen again! 🔊"), findsOneWidget);

      // Interacting with the screen resets the reminder
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Reminder banner hides
      expect(find.text("Let's listen again! 🔊"), findsNothing);

      // Clean up pending audio and timers
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Week 9 - Task 12: Loading, Empty, and Gentle Error States', () {
    testWidgets('Empty category displays gentle EmptyStateWidget with return action',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('unknown_empty_category');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'unknown_empty_category'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No vocabulary yet'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Missing image falls back to sensory-calm placeholder UI without throwing',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const brokenItem = VocabularyItemModel(
        id: 'dog',
        categoryId: 'animals',
        labelEn: 'Dog',
        labelAr: 'كَلْب',
        imageUrl: 'invalid://broken/path.png',
        difficultyLevel: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VocabularyCard(
              item: brokenItem,
              isArabic: false,
              hasPrevious: false,
              hasNext: true,
              onPlayAudio: () {},
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('كَلْب'), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
    });
  });
}
