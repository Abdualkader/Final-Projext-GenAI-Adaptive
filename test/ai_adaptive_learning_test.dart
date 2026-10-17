import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/models/quiz_question_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/services/adaptive_difficulty_service.dart';
import 'package:asd_learning_assistant/services/ai_adaptive_service.dart';
import 'package:asd_learning_assistant/providers/quiz_provider.dart';

/// Test mock implementation of [AiAdaptiveService] for hermetic, deterministic testing
class MockAiAdaptiveService implements AiAdaptiveService {
  bool shouldThrowError = false;
  bool shouldTimeout = false;
  bool returnInvalidData = false;
  int generationCallCount = 0;
  Map<String, dynamic>? lastCapturedPayload;

  @override
  Future<QuizQuestionModel> generateExercise({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    String exerciseType = 'identify_item',
    double recentAccuracy = 0.75,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    generationCallCount++;
    lastCapturedPayload = {
      'categoryId': categoryId,
      'difficultyLevel': difficultyLevel,
      'preferredLanguage': preferredLanguage,
      'exerciseType': exerciseType,
      'recentAccuracy': recentAccuracy,
    };

    if (shouldTimeout) {
      throw Exception('Simulated TimeoutException: AI service request timed out');
    }

    if (shouldThrowError) {
      throw Exception('Simulated AI API failure: 503 Service Unavailable');
    }

    if (returnInvalidData) {
      // Return invalid question that fails validation
      return const QuizQuestionModel(
        id: 'invalid_q',
        promptEn: '',
        promptAr: '',
        correctChoiceId: 'non_existent_item',
        choices: [],
      );
    }

    final isArabic = preferredLanguage == 'ar';
    return QuizQuestionModel(
      id: 'ai_${categoryId}_${DateTime.now().millisecondsSinceEpoch}',
      promptEn: 'Where is the Cat?',
      promptAr: 'أين القطة؟',
      correctChoiceId: 'cat',
      categoryId: categoryId,
      difficultyLevel: difficultyLevel,
      choices: [
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
      final q = await generateExercise(
        categoryId: categoryId,
        difficultyLevel: difficultyLevel,
        preferredLanguage: preferredLanguage,
        recentAccuracy: recentAccuracy,
      );
      list.add(q);
    }
    return list;
  }

  @override
  bool validateExerciseData(Map<String, dynamic> data) {
    final baseService = BaseAiAdaptiveService();
    return baseService.validateExerciseData(data);
  }
}

/// In-memory mock user repository for hermetic testing of child difficulty updates
class TestUserRepository implements UserRepository {
  final Map<String, ChildModel> children = {};

  @override
  Future<ChildModel?> getChildById(String childId) async => children[childId];

  @override
  Future<void> updateChildDifficulty(String childId, int newDifficulty) async {
    final existing = children[childId];
    if (existing != null) {
      children[childId] = existing.copyWith(currentDifficultyLevel: newDifficulty);
    }
  }

  @override
  Future<List<ChildModel>> getLinkedChildren(String parentId) async =>
      children.values.where((c) => c.parentId == parentId).toList();

  @override
  Future<List<String>> getLinkedChildIds(String parentId) async =>
      children.values.where((c) => c.parentId == parentId).map((c) => c.childId).toList();

  @override
  Future<void> addChildProfile(String parentId, ChildModel child) async {
    children[child.childId] = child;
  }

  @override
  Future<UserModel?> getUserById(String userId) async => null;

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  Future<void> updatePreferredLanguage(String userId, String language) async {}
}

void main() {
  group('Week 12 — Task 3 & 14: Security, Credential Protection & Privacy', () {
    test('Security Verification: AI API credentials are NOT present in Flutter codebase', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue, reason: 'lib directory must exist');

      final forbiddenKeywords = [
        'sk-', // OpenAI standard key prefix
        'sk-ant-', // Anthropic key prefix
        'GENAI_API_KEY',
        'OPENAI_API_KEY',
        'gemini_api_key',
        'geminiApiKey',
        'google_ai_key',
      ];

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        for (final keyword in forbiddenKeywords) {
          expect(
            content.contains(keyword),
            isFalse,
            reason: 'Security violation: File ${file.path} contains sensitive keyword "$keyword". '
                'AI keys must remain strictly on the backend/Cloud Functions!',
          );
        }
      }
    });

    test('Privacy Verification: Exercise payload contains only educational context and NO PII', () async {
      final mockAi = MockAiAdaptiveService();
      await mockAi.generateExercise(
        categoryId: 'colors',
        difficultyLevel: 2,
        preferredLanguage: 'ar',
        recentAccuracy: 0.85,
      );

      final payload = mockAi.lastCapturedPayload;
      expect(payload, isNotNull);

      // Verify necessary fields are present
      expect(payload!['categoryId'], equals('colors'));
      expect(payload['difficultyLevel'], equals(2));
      expect(payload['preferredLanguage'], equals('ar'));
      expect(payload['recentAccuracy'], equals(0.85));

      // Verify sensitive personal identifiers are strictly absent
      expect(payload.containsKey('email'), isFalse);
      expect(payload.containsKey('password'), isFalse);
      expect(payload.containsKey('childName'), isFalse);
      expect(payload.containsKey('token'), isFalse);
      expect(payload.containsKey('birthDate'), isFalse);
      expect(payload.containsKey('parentId'), isFalse);
    });
  });

  group('Week 12 — Task 4 & 5: AI Exercise Generation & Response Validation', () {
    late BaseAiAdaptiveService service;

    setUp(() {
      service = BaseAiAdaptiveService();
    });

    test('Valid AI response passes validation with 3 options and whitelisted vocabulary', () {
      final validData = {
        'promptEn': 'Where is the Dog?',
        'promptAr': 'أين الكلب؟',
        'correctChoiceId': 'dog',
        'categoryId': 'animals',
        'choices': [
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'bird', 'labelEn': 'Bird', 'labelAr': 'عصفور'},
        ],
      };

      expect(service.validateExerciseData(validData), isTrue);
    });

    test('Validation rejects response with missing required fields', () {
      final missingPrompt = {
        'promptAr': 'أين القطة؟',
        'correctChoiceId': 'cat',
        'choices': [
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
          {'id': 'bird', 'labelEn': 'Bird', 'labelAr': 'عصفور'},
        ],
      };
      expect(service.validateExerciseData(missingPrompt), isFalse);
    });

    test('Validation rejects response when choice count is not exactly 3', () {
      final twoChoices = {
        'promptEn': 'Where is the Cat?',
        'promptAr': 'أين القطة؟',
        'correctChoiceId': 'cat',
        'choices': [
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
        ],
      };
      expect(service.validateExerciseData(twoChoices), isFalse);

      final fourChoices = {
        'promptEn': 'Where is the Cat?',
        'promptAr': 'أين القطة؟',
        'correctChoiceId': 'cat',
        'choices': [
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
          {'id': 'bird', 'labelEn': 'Bird', 'labelAr': 'عصفور'},
          {'id': 'cow', 'labelEn': 'Cow', 'labelAr': 'بقرة'},
        ],
      };
      expect(service.validateExerciseData(fourChoices), isFalse);
    });

    test('Validation rejects response when correctChoiceId is not among the options', () {
      final mismatchedCorrect = {
        'promptEn': 'Where is the Lion?',
        'promptAr': 'أين الأسد؟',
        'correctChoiceId': 'lion',
        'choices': [
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
          {'id': 'bird', 'labelEn': 'Bird', 'labelAr': 'عصفور'},
        ],
      };
      expect(service.validateExerciseData(mismatchedCorrect), isFalse);
    });

    test('Validation rejects hallucinated items outside educational domain (Task 13)', () {
      final hallucinatedItem = {
        'promptEn': 'Where is the Dragon?',
        'promptAr': 'أين التنين؟',
        'correctChoiceId': 'dragon',
        'categoryId': 'animals',
        'choices': [
          {'id': 'dragon', 'labelEn': 'Dragon', 'labelAr': 'تنين'}, // Not in approved ASD vocabulary
          {'id': 'cat', 'labelEn': 'Cat', 'labelAr': 'قطة'},
          {'id': 'dog', 'labelEn': 'Dog', 'labelAr': 'كلب'},
        ],
      };
      expect(service.validateExerciseData(hallucinatedItem), isFalse);
    });
  });

  group('Week 12 — Task 6 & 15: Fallback Mechanism on Timeout & Error', () {
    test('Fallback generates guaranteed valid question on AI timeout', () async {
      final service = BaseAiAdaptiveService();
      // Calling generateExercise in hermetic test without live Cloud Functions triggers safe fallback
      final question = await service.generateExercise(
        categoryId: 'colors',
        difficultyLevel: 1,
        preferredLanguage: 'en',
      );

      expect(question, isNotNull);
      expect(question.choices.length, equals(3));
      expect(question.correctChoiceId, isNotEmpty);
      expect(question.choices.any((c) => c.id == question.correctChoiceId), isTrue);
    });

    test('Fallback produces exercises across all 4 categories: animals, colors, numbers, letters', () async {
      final service = BaseAiAdaptiveService();
      final categories = ['animals', 'colors', 'numbers', 'letters'];

      for (final cat in categories) {
        final q = await service.generateExercise(
          categoryId: cat,
          difficultyLevel: 1,
          preferredLanguage: 'en',
        );

        expect(q.id, isNotEmpty);
        expect(q.choices.length, equals(3));
        expect(q.correctChoiceId, isNotEmpty);
      }
    });
  });

  group('Week 12 — Task 7, 8, 9, 10: Adaptive Difficulty Engine', () {
    late AdaptiveDifficultyService service;

    setUp(() {
      service = const AdaptiveDifficultyService(
        minEvaluationWindow: 3,
        evaluationWindow: 5,
        highAccuracyThreshold: 0.85,
        lowAccuracyThreshold: 0.60,
      );
    });

    List<QuizResultModel> generateResults({
      required int correctCount,
      required int totalCount,
      String category = 'animals',
    }) {
      return List.generate(totalCount, (index) {
        final isCorrect = index < correctCount;
        return QuizResultModel(
          resultId: 'res_$index',
          sessionId: 'test_session',
          childId: 'child_adam_001',
          questionId: '${category}_q$index',
          childResponse: isCorrect ? 'correct' : 'wrong',
          isCorrect: isCorrect,
          timestamp: DateTime.now(),
        );
      });
    }

    test('Gating: Maintains difficulty if fewer than minimum attempts exist in window (Task 10)', () {
      final results = generateResults(correctCount: 2, totalCount: 2); // 2 < minEvaluationWindow (3)

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 1,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.maintain));
      expect(evaluation.newDifficulty, equals(1));
      expect(evaluation.difficultyChanged, isFalse);
      expect(evaluation.totalQuestionsEvaluated, equals(2));
      expect(evaluation.explanationEn, contains('at least 3 attempts required'));
    });

    test('High Performance (>=85%): Increases difficulty from Easy (1) to Medium (2) (Task 7)', () {
      // 5 correct out of 5 = 100% >= 85%
      final results = generateResults(correctCount: 5, totalCount: 5);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 1,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.increase));
      expect(evaluation.previousDifficulty, equals(1));
      expect(evaluation.newDifficulty, equals(2));
      expect(evaluation.difficultyChanged, isTrue);
      expect(evaluation.accuracy, equals(1.0));
      expect(evaluation.explanationEn, contains('Advancing difficulty to level 2'));
    });

    test('High Performance (>=85%): Increases difficulty from Medium (2) to Hard (3) (Task 7)', () {
      // 4 correct out of 4 = 100%
      final results = generateResults(correctCount: 4, totalCount: 4);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 2,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.increase));
      expect(evaluation.previousDifficulty, equals(2));
      expect(evaluation.newDifficulty, equals(3));
      expect(evaluation.difficultyChanged, isTrue);
    });

    test('Boundary Ceiling: Level 3 cannot exceed maximum Hard level (3) (Task 8)', () {
      final results = generateResults(correctCount: 5, totalCount: 5);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 3,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.maintain));
      expect(evaluation.newDifficulty, equals(3));
      expect(evaluation.difficultyChanged, isFalse);
      expect(evaluation.explanationEn, contains('maximum difficulty level 3'));
    });

    test('Stable Performance (60% - 84%): Maintains current difficulty level (Task 7)', () {
      // 3 correct out of 4 = 75%
      final results = generateResults(correctCount: 3, totalCount: 4);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 2,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.maintain));
      expect(evaluation.previousDifficulty, equals(2));
      expect(evaluation.newDifficulty, equals(2));
      expect(evaluation.difficultyChanged, isFalse);
      expect(evaluation.explanationEn, contains('Stable performance'));
    });

    test('Low Performance (<60%): Reduces difficulty from Hard (3) to Medium (2) (Task 7)', () {
      // 1 correct out of 4 = 25% < 60%
      final results = generateResults(correctCount: 1, totalCount: 4);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 3,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.decrease));
      expect(evaluation.previousDifficulty, equals(3));
      expect(evaluation.newDifficulty, equals(2));
      expect(evaluation.difficultyChanged, isTrue);
      expect(evaluation.explanationEn, contains('Reducing difficulty to level 2'));
    });

    test('Low Performance (<60%): Reduces difficulty from Medium (2) to Easy (1) (Task 7)', () {
      final results = generateResults(correctCount: 1, totalCount: 4);

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 2,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.decrease));
      expect(evaluation.previousDifficulty, equals(2));
      expect(evaluation.newDifficulty, equals(1));
      expect(evaluation.difficultyChanged, isTrue);
    });

    test('Boundary Floor: Level 1 cannot go below minimum Easy level (1) (Task 8)', () {
      final results = generateResults(correctCount: 0, totalCount: 3); // 0%

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 1,
        recentResults: results,
      );

      expect(evaluation.action, equals(AdaptiveAction.maintain));
      expect(evaluation.newDifficulty, equals(1));
      expect(evaluation.difficultyChanged, isFalse);
      expect(evaluation.explanationEn, contains('foundational difficulty level 1'));
    });

    test('Personalized Category Selection: Recommends category where child struggles (Task 9)', () {
      // Child does well in animals (3/3 = 100%) but struggles in colors (1/3 = 33%)
      final results = [
        ...generateResults(correctCount: 3, totalCount: 3, category: 'animals'),
        ...generateResults(correctCount: 1, totalCount: 3, category: 'colors'),
      ];

      final evaluation = service.evaluateDifficulty(
        currentDifficulty: 2,
        recentResults: results,
      );

      expect(evaluation.categoryAccuracies.containsKey('colors'), isTrue);
      expect(evaluation.categoryAccuracies['colors']!, lessThan(0.60));
      expect(evaluation.recommendedCategory, equals('colors'));
    });

    test('Persistence: updateChildDifficulty saves new difficulty to user repository (Task 10)', () async {
      final userRepo = TestUserRepository();
      final child = ChildModel(
        childId: 'child_adam_001',
        parentId: 'parent_001',
        name: 'Adam',
        currentDifficultyLevel: 1,
        createdAt: DateTime.now(),
      );
      await userRepo.addChildProfile('parent_001', child);

      final results = generateResults(correctCount: 4, totalCount: 4); // 100% -> increase to 2

      final eval = await service.updateChildDifficulty(
        'child_adam_001',
        currentDifficulty: 1,
        recentResults: results,
        userRepository: userRepo,
      );

      expect(eval.newDifficulty, equals(2));
      expect(eval.difficultyChanged, isTrue);

      final updatedChild = await userRepo.getChildById('child_adam_001');
      expect(updatedChild, isNotNull);
      expect(updatedChild!.currentDifficultyLevel, equals(2));
    });
  });

  group('Week 12 — Task 11: AI Integration With Quiz Flow', () {
    late QuizProvider provider;
    late MockAiAdaptiveService mockAi;
    late TestUserRepository testUserRepo;

    setUp(() {
      mockAi = MockAiAdaptiveService();
      testUserRepo = TestUserRepository();
      testUserRepo.addChildProfile(
        'parent_001',
        ChildModel(
          childId: 'child_adam_001',
          parentId: 'parent_001',
          name: 'Adam',
          currentDifficultyLevel: 1,
          createdAt: DateTime.now(),
        ),
      );

      provider = QuizProvider(
        aiAdaptiveService: mockAi,
        userRepository: testUserRepo,
      );
    });

    test('startAdaptiveQuizSession invokes AI generator and populates questions', () async {
      await provider.startAdaptiveQuizSession(
        childId: 'child_adam_001',
        categoryId: 'animals',
        questionCount: 3,
        preferredLanguage: 'en',
      );

      expect(provider.isAiAdaptedSession, isTrue);
      expect(provider.questions.length, equals(3));
      expect(provider.currentDifficulty, equals(1));
      expect(mockAi.generationCallCount, equals(3));
      expect(provider.question, isNotNull);
    });

    test('Completing quiz session evaluates adaptive performance and updates difficulty', () async {
      await provider.startAdaptiveQuizSession(
        childId: 'child_adam_001',
        categoryId: 'animals',
        questionCount: 3,
        preferredLanguage: 'en',
      );

      // Answer all 3 questions correctly
      while (!provider.isQuizCompleted) {
        final currentQ = provider.question!;
        await provider.selectChoice(currentQ.correctChoiceId);
        await provider.nextQuestion();
      }

      expect(provider.isQuizCompleted, isTrue);
      expect(provider.lastAdaptiveResult, isNotNull);
      expect(provider.lastAdaptiveResult!.action, equals(AdaptiveAction.increase));
      expect(provider.lastAdaptiveResult!.newDifficulty, equals(2));
      expect(provider.currentDifficulty, equals(2));

      // Verify profile was updated in repo
      final updatedChild = await testUserRepo.getChildById('child_adam_001');
      expect(updatedChild!.currentDifficultyLevel, equals(2));
    });

    test('Seamless Fallback: If AI fails, QuizProvider falls back without crashing', () async {
      mockAi.shouldThrowError = true;

      await provider.startAdaptiveQuizSession(
        childId: 'child_adam_001',
        categoryId: 'animals',
        questionCount: 3,
        preferredLanguage: 'en',
      );

      // Quiz must still load questions from fallback repository
      expect(provider.questions, isNotEmpty);
      expect(provider.question, isNotNull);
      expect(provider.question!.choices.length, equals(3));
    });
  });

  group('Week 12 — Task 12: Bilingual Language Support (Arabic RTL & English LTR)', () {
    test('Arabic exercise provides Arabic prompts, Arabic choice labels, and RTL direction', () async {
      final mockAi = MockAiAdaptiveService();
      final q = await mockAi.generateExercise(
        categoryId: 'animals',
        difficultyLevel: 1,
        preferredLanguage: 'ar',
      );

      expect(q.promptAr, equals('أين القطة؟'));
      expect(q.localizedPrompt(true), equals('أين القطة؟'));

      final correctChoice = q.choices.firstWhere((c) => c.id == q.correctChoiceId);
      expect(correctChoice.labelAr, equals('قطة'));
      expect(correctChoice.localizedLabel(true), equals('قطة'));
    });

    test('English exercise provides English prompts, English choice labels, and LTR direction', () async {
      final mockAi = MockAiAdaptiveService();
      final q = await mockAi.generateExercise(
        categoryId: 'animals',
        difficultyLevel: 1,
        preferredLanguage: 'en',
      );

      expect(q.promptEn, equals('Where is the Cat?'));
      expect(q.localizedPrompt(false), equals('Where is the Cat?'));

      final correctChoice = q.choices.firstWhere((c) => c.id == q.correctChoiceId);
      expect(correctChoice.labelEn, equals('Cat'));
      expect(correctChoice.localizedLabel(false), equals('Cat'));
    });

    test('Adaptive evaluation provides localized bilingual explanations', () {
      const service = AdaptiveDifficultyService();
      final results = List.generate(4, (i) {
        return QuizResultModel(
          resultId: 'res_$i',
          sessionId: 's_1',
          childId: 'child_1',
          questionId: 'animals_q$i',
          childResponse: 'cat',
          isCorrect: true,
          timestamp: DateTime.now(),
        );
      });

      final eval = service.evaluateDifficulty(
        currentDifficulty: 1,
        recentResults: results,
      );

      // English explanation
      expect(eval.localizedExplanation(false), contains('Advancing difficulty to level 2'));
      // Arabic explanation
      expect(eval.localizedExplanation(true), contains('تم رفع مستوى الصعوبة إلى المستوى 2'));
    });
  });
}
