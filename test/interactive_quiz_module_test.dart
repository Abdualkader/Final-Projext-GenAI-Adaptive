import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:asd_learning_assistant/models/quiz_question_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/providers/quiz_provider.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/screens/child/quiz_screen.dart';
import 'package:asd_learning_assistant/widgets/quiz_choice_card.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  QuizProvider? quizProvider,
}) {
  return MultiProvider(
    providers: [
      if (quizProvider != null)
        ChangeNotifierProvider<QuizProvider>.value(value: quizProvider)
      else
        ChangeNotifierProvider<QuizProvider>(create: (_) => QuizProvider()),
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
      home: child,
    ),
  );
}

void main() {
  group('Week 10 - Task 3: Quiz Question Model & Serialization', () {
    test('QuizQuestionModel contains all required schema fields and helpers', () {
      const choiceA = QuizChoice(
        id: 'opt_dog',
        labelEn: 'Dog',
        labelAr: 'كَلْب',
        imageUrl: 'vocabulary/images/animals/dog.png',
        icon: Icons.pets_rounded,
        accentColor: Color(0xFF22C55E),
      );
      const choiceB = QuizChoice(
        id: 'opt_cat',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'vocabulary/images/animals/cat.png',
        icon: Icons.cruelty_free_rounded,
        accentColor: Color(0xFF3B82F6),
      );
      const choiceC = QuizChoice(
        id: 'opt_fish',
        labelEn: 'Fish',
        labelAr: 'سَمَكَة',
        imageUrl: 'vocabulary/images/animals/fish.png',
        icon: Icons.set_meal_rounded,
        accentColor: Color(0xFFA855F7),
      );

      final question = QuizQuestionModel(
        id: 'q_animals_001',
        promptEn: 'Where is the dog?',
        promptAr: 'أين الكلب؟',
        correctChoiceId: 'opt_dog',
        choices: [choiceA, choiceB, choiceC],
        categoryId: 'animals',
        difficultyLevel: 1,
      );

      expect(question.questionId, 'q_animals_001');
      expect(question.correctItemId, 'opt_dog');
      expect(question.options.length, 3);
      expect(question.categoryId, 'animals');
      expect(question.difficultyLevel, 1);
      expect(question.localizedPrompt(false), 'Where is the dog?');
      expect(question.localizedPrompt(true), 'أين الكلب؟');

      final map = question.toMap();
      expect(map['questionId'], 'q_animals_001');
      expect(map['correctChoiceId'], 'opt_dog');
      expect(map['choices'].length, 3);
      expect(map['categoryId'], 'animals');
      expect(map['difficultyLevel'], 1);

      final reconstructed = QuizQuestionModel.fromMap(map, id: 'q_animals_001');
      expect(reconstructed.id, 'q_animals_001');
      expect(reconstructed.correctChoiceId, 'opt_dog');
      expect(reconstructed.choices.length, 3);
      expect(reconstructed.choices[0].labelEn, 'Dog');
      expect(reconstructed.choices[0].labelAr, 'كَلْب');
      expect(reconstructed.choices[0].imageUrl, 'vocabulary/images/animals/dog.png');
    });

    test('QuizResultModel serializes attempt telemetry accurately', () {
      final now = DateTime.now();
      final result = QuizResultModel(
        resultId: 'res_001',
        sessionId: 'sess_100',
        childId: 'child_adam',
        questionId: 'q_animals_001',
        childResponse: 'opt_dog',
        isCorrect: true,
        responseTimeMs: 2450,
        timestamp: now,
      );

      final map = result.toMap();
      expect(map['resultId'], 'res_001');
      expect(map['sessionId'], 'sess_100');
      expect(map['childId'], 'child_adam');
      expect(map['childResponse'], 'opt_dog');
      expect(map['isCorrect'], true);
      expect(map['responseTimeMs'], 2450);

      final fromMap = QuizResultModel.fromMap(map, id: 'res_001');
      expect(fromMap.resultId, 'res_001');
      expect(fromMap.isCorrect, true);
      expect(fromMap.responseTimeMs, 2450);
    });
  });

  group('Week 10 - Task 4, 11 & 12: Quiz Question Generation & Distractors', () {
    test('Generates questions with exactly 3 options across categories', () async {
      final repo = BaseQuizRepository();
      final questions = await repo.getQuizQuestionsForCategory('animals', count: 3, shuffle: false);

      expect(questions.isNotEmpty, true);
      for (final q in questions) {
        expect(q.choices.length, 3, reason: 'Every quiz question must present 3 options');
        expect(q.choices.any((c) => c.id == q.correctChoiceId), true,
            reason: 'Options must include the correct target item');
        final targetIds = q.choices.map((c) => c.id).toSet();
        expect(targetIds.length, 3, reason: 'All 3 choices must be unique items');
      }
    });

    test('Task 11: Correct choice position varies when choices are randomized', () async {
      final repo = BaseQuizRepository();
      final correctIndices = <int>{};

      // Generate questions multiple times with shuffle to observe position distribution
      for (int i = 0; i < 15; i++) {
        final qs = await repo.getQuizQuestionsForCategory('animals', count: 5, shuffle: true);
        for (final q in qs) {
          final idx = q.choices.indexWhere((c) => c.id == q.correctChoiceId);
          correctIndices.add(idx);
        }
      }

      // Over 15 generations of 5 questions, correct choice should appear in different positions (0, 1, 2)
      expect(correctIndices.length, greaterThanOrEqualTo(2),
          reason: 'Correct answer position must vary across questions');
    });

    test('Task 12: Filters quiz questions by difficulty level', () async {
      final repo = BaseQuizRepository();
      final easyQuestions = await repo.getQuizQuestionsForCategory(
        'animals',
        count: 5,
        maxDifficulty: 1,
        shuffle: false,
      );

      for (final q in easyQuestions) {
        expect(q.difficultyLevel, lessThanOrEqualTo(1));
      }
    });
  });

  group('Week 10 - Task 2, 5, 6, 7 & 8: QuizProvider Multi-Question Session State', () {
    test('Initializes session with childId, categoryId, and persists to SessionRepository', () async {
      final sessionRepo = BaseSessionRepository();
      final quizRepo = BaseQuizRepository();
      final provider = QuizProvider(
        quizRepository: quizRepo,
        sessionRepository: sessionRepo,
      );

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        questionCount: 3,
        enableTimer: false,
      );

      expect(provider.isSessionActive, true);
      expect(provider.activeChildId, 'child_adam');
      expect(provider.activeCategoryId, 'animals');
      expect(provider.questions.length, 3);
      expect(provider.currentQuestionIndex, 0);
      expect(provider.score, 0);
      expect(provider.isQuizCompleted, false);

      final session = await sessionRepo.getSessionById(provider.sessionId);
      expect(session, isNotNull);
      expect(session!.childId, 'child_adam');
      expect(session.categoryId, 'animals');
    });

    test('Evaluates correct choice: awards stars, plays positive chime, and logs result', () async {
      final quizRepo = BaseQuizRepository();
      final provider = QuizProvider(quizRepository: quizRepo);

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        questionCount: 2,
        enableTimer: false,
      );

      final initialStars = provider.starsCount;
      final correctId = provider.question!.correctChoiceId;

      await provider.selectChoice(correctId, stars: 3);

      expect(provider.isAnswered, true);
      expect(provider.isCorrect, true);
      expect(provider.score, 1);
      expect(provider.starsCount, initialStars + 3);

      expect(provider.recordedResults.length, 1);
      final recorded = provider.recordedResults.first;
      expect(recorded.isCorrect, true);
      expect(recorded.childResponse, correctId);

      // Verify Firestore persistence via QuizRepository
      final repoResults = await quizRepo.getQuizResultsForSession(provider.sessionId);
      expect(repoResults.length, 1);
      expect(repoResults.first.isCorrect, true);
    });

    test('Evaluates incorrect choice: gentle correction, preserves stars (no penalty), logs result', () async {
      final quizRepo = BaseQuizRepository();
      final provider = QuizProvider(quizRepository: quizRepo);

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        questionCount: 2,
        enableTimer: false,
      );

      final initialStars = provider.starsCount;
      final incorrectId = provider.question!.choices
          .firstWhere((c) => c.id != provider.question!.correctChoiceId)
          .id;

      await provider.selectChoice(incorrectId);

      expect(provider.isAnswered, true);
      expect(provider.isCorrect, false);
      expect(provider.score, 0);
      // ASD calm guideline: No penalty or negative star subtraction
      expect(provider.starsCount, initialStars);

      expect(provider.recordedResults.length, 1);
      final recorded = provider.recordedResults.first;
      expect(recorded.isCorrect, false);
      expect(recorded.childResponse, incorrectId);
    });

    test('Advances across questions and finishes quiz with completion score', () async {
      final sessionRepo = BaseSessionRepository();
      final provider = QuizProvider(sessionRepository: sessionRepo);

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        questionCount: 2,
        enableTimer: false,
      );

      expect(provider.currentQuestionIndex, 0);

      // Answer question 1 correctly
      await provider.selectChoice(provider.question!.correctChoiceId);
      expect(provider.score, 1);

      // Advance to question 2
      await provider.nextQuestion(enableTimer: false);
      expect(provider.currentQuestionIndex, 1);
      expect(provider.isAnswered, false);

      // Answer question 2 incorrectly
      final wrong = provider.question!.choices
          .firstWhere((c) => c.id != provider.question!.correctChoiceId)
          .id;
      await provider.selectChoice(wrong);

      // Advance from last question -> finishes quiz
      await provider.nextQuestion(enableTimer: false);
      expect(provider.isQuizCompleted, true);
      expect(provider.isSessionActive, false);
      expect(provider.score, 1);
      expect(provider.accuracyFraction, 0.5);
      expect(provider.accuracyPercentage, 50);

      final completedSession = await sessionRepo.getSessionById(provider.sessionId);
      expect(completedSession, isNotNull);
      expect(completedSession!.score, 0.5);
      expect(completedSession.endTime, isNotNull);
    });
  });

  group('Week 10 - Task 9: 60-Second Peaceful Question Timer', () {
    test('Automatic timeout triggers gentle chime and logs timeout attempt', () async {
      final quizRepo = BaseQuizRepository();
      final provider = QuizProvider(quizRepository: quizRepo);

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        questionCount: 2,
        timeoutDuration: const Duration(milliseconds: 50),
        enableTimer: true,
      );

      expect(provider.isAnswered, false);
      expect(provider.isTimedOut, false);

      // Wait for timer and gentle audio chime to complete
      await Future.delayed(const Duration(milliseconds: 500));

      expect(provider.isTimedOut, true);
      expect(provider.isAnswered, true);
      expect(provider.isCorrect, false);

      // Timeout is recorded as an attempt without penalty
      expect(provider.recordedResults.length, 1);
      final result = provider.recordedResults.first;
      expect(result.childResponse, 'timeout');
      expect(result.isCorrect, false);

      provider.cancelTimer();
    });

    test('Selecting choice cancels active timer to prevent late trigger', () async {
      final provider = QuizProvider();

      await provider.startQuizSession(
        childId: 'child_adam',
        categoryId: 'animals',
        timeoutDuration: const Duration(seconds: 60),
        enableTimer: true,
      );

      expect(provider.isAnswered, false);
      await provider.selectChoice(provider.question!.correctChoiceId);

      expect(provider.isAnswered, true);
      expect(provider.isTimedOut, false);

      // Timer should be cancelled
      provider.cancelTimer();
    });
  });

  group('Week 10 - Task 10: Quiz Screen UI & Completion Flow Tests', () {
    testWidgets('Renders 3 image choices with aspect-ratio containment and feedback banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const testChoices = [
        QuizChoice(
          id: 'dog',
          labelEn: 'Dog',
          labelAr: 'كلب',
          imageUrl: 'vocabulary/images/animals/dog.png',
          icon: Icons.pets_rounded,
          accentColor: Color(0xFF22C55E),
        ),
        QuizChoice(
          id: 'cat',
          labelEn: 'Cat',
          labelAr: 'قطة',
          imageUrl: 'vocabulary/images/animals/cat.png',
          icon: Icons.cruelty_free_rounded,
          accentColor: Color(0xFF3B82F6),
        ),
        QuizChoice(
          id: 'fish',
          labelEn: 'Fish',
          labelAr: 'سمكة',
          imageUrl: 'vocabulary/images/animals/fish.png',
          icon: Icons.set_meal_rounded,
          accentColor: Color(0xFFA855F7),
        ),
      ];

      final testQuestion = QuizQuestionModel(
        id: 'q_test_1',
        promptEn: 'Where is the dog?',
        promptAr: 'أين الكلب؟',
        correctChoiceId: 'dog',
        choices: testChoices,
        categoryId: 'animals',
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: QuizScreen(
            categoryId: 'animals',
            questions: [testQuestion],
            enableTimer: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify prompt and choices
      expect(find.text('Where is the dog?'), findsOneWidget);
      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('Fish'), findsOneWidget);
      expect(find.byType(QuizChoiceCard), findsNWidgets(3));

      // Tap speaker button shows snackbar
      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pump();
      expect(find.text('🔊 Where is the dog?'), findsOneWidget);
    });

    testWidgets('Multi-question quiz navigation advances to completion screen with score summary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const q1 = QuizQuestionModel(
        id: 'q_1',
        promptEn: 'Where is the dog?',
        promptAr: 'أين الكلب؟',
        correctChoiceId: 'dog',
        choices: [
          QuizChoice(id: 'dog', labelEn: 'Dog', labelAr: 'كلب', icon: Icons.pets_rounded),
          QuizChoice(id: 'cat', labelEn: 'Cat', labelAr: 'قطة', icon: Icons.cruelty_free_rounded),
          QuizChoice(id: 'fish', labelEn: 'Fish', labelAr: 'سمكة', icon: Icons.set_meal_rounded),
        ],
        categoryId: 'animals',
      );

      const q2 = QuizQuestionModel(
        id: 'q_2',
        promptEn: 'Where is the cat?',
        promptAr: 'أين القطة؟',
        correctChoiceId: 'cat',
        choices: [
          QuizChoice(id: 'dog', labelEn: 'Dog', labelAr: 'كلب', icon: Icons.pets_rounded),
          QuizChoice(id: 'cat', labelEn: 'Cat', labelAr: 'قطة', icon: Icons.cruelty_free_rounded),
          QuizChoice(id: 'fish', labelEn: 'Fish', labelAr: 'سمكة', icon: Icons.set_meal_rounded),
        ],
        categoryId: 'animals',
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: QuizScreen(
            categoryId: 'animals',
            questions: [q1, q2],
            enableTimer: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Where is the dog?'), findsOneWidget);

      // Answer Q1 correctly
      await tester.tap(find.text('Dog'));
      await tester.pumpAndSettle();

      expect(find.text('Great job! 🌟'), findsOneWidget);
      expect(find.text('15'), findsOneWidget); // 12 + 3

      // Tap Next Question button (forward arrow)
      final forwardBtn = find.byTooltip('Next Question');
      expect(forwardBtn, findsOneWidget);
      await tester.tap(forwardBtn);
      await tester.pumpAndSettle();

      // Q2 renders
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Where is the cat?'), findsOneWidget);

      // Answer Q2 correctly
      await tester.tap(find.text('Cat'));
      await tester.pumpAndSettle();
      expect(find.text('18'), findsOneWidget); // 15 + 3

      // Tap forward to complete
      await tester.tap(forwardBtn);
      await tester.pumpAndSettle();

      // Task 10: Celebratory Completion Screen
      expect(find.text('Quiz Complete! 🌟'), findsOneWidget);
      expect(find.text('Amazing effort! You finished the quiz!'), findsOneWidget);
      expect(find.text('You got 2 out of 2 right!'), findsOneWidget);
      expect(find.text('100% Accuracy'), findsOneWidget);
      expect(find.text('Play Again 🔄'), findsOneWidget);
      expect(find.text('Return Home 🏠'), findsOneWidget);

      // Tap Play Again resets quiz
      await tester.tap(find.text('Play Again 🔄'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Where is the dog?'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Bilingual Arabic RTL renders Harakat and localized completion messages',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const q = QuizQuestionModel(
        id: 'q_ar_1',
        promptEn: 'Where is the dog?',
        promptAr: 'أَيْنَ الكَلْبُ؟',
        correctChoiceId: 'dog',
        choices: [
          QuizChoice(id: 'dog', labelEn: 'Dog', labelAr: 'كَلْبٌ', icon: Icons.pets_rounded),
          QuizChoice(id: 'cat', labelEn: 'Cat', labelAr: 'قِطَّةٌ', icon: Icons.cruelty_free_rounded),
          QuizChoice(id: 'fish', labelEn: 'Fish', labelAr: 'سَمَكَةٌ', icon: Icons.set_meal_rounded),
        ],
        categoryId: 'animals',
      );

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          child: QuizScreen(
            categoryId: 'animals',
            questions: [q],
            enableTimer: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Arabic prompt and labels
      expect(find.text('أَيْنَ الكَلْبُ؟'), findsOneWidget);
      expect(find.text('كَلْبٌ'), findsOneWidget);

      // Select correct
      await tester.tap(find.text('كَلْبٌ'));
      await tester.pumpAndSettle();

      expect(find.text('ممتاز جداً! 🌟'), findsOneWidget);

      // Complete quiz
      await tester.tap(find.byTooltip('Next Question'));
      await tester.pumpAndSettle();

      expect(find.text('اكتمل الاختبار بنجاح! 🌟'), findsOneWidget);
      expect(find.text('عمل رائع جداً! لقد أكملت الاختبار يا بطل!'), findsOneWidget);
      expect(find.text('إعادة اللعب 🔄'), findsOneWidget);
      expect(find.text('العودة للرئيسية 🏠'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
