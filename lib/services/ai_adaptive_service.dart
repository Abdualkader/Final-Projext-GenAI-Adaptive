import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../models/quiz_question_model.dart';
import '../models/vocabulary_item_model.dart';
import '../repositories/mock_data_repository.dart';
import '../repositories/vocabulary_repository.dart';

/// Contract for AI-powered adaptive exercise generation.
/// Guarantees that AI API credentials remain strictly on the backend (Task 3).
abstract class AiAdaptiveService {
  /// Generates a single validated educational exercise adapted to child difficulty and performance.
  Future<QuizQuestionModel> generateExercise({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    String exerciseType = 'identify_item',
    double recentAccuracy = 0.75,
    Duration timeout = const Duration(seconds: 7),
  });

  /// Generates a sequence of exercises for an interactive quiz session.
  Future<List<QuizQuestionModel>> generateAdaptiveQuizSession({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    int count = 5,
    double recentAccuracy = 0.75,
  });

  /// Validates AI response schema and educational domain constraints before presenting to child (Task 5 & 13).
  bool validateExerciseData(Map<String, dynamic> data);
}

/// Base implementation of [AiAdaptiveService] communicating with Firebase Cloud Functions v2.
/// Includes comprehensive timeout handling, client-side validation, and instant fallback (Task 5, 6, 15).
class BaseAiAdaptiveService implements AiAdaptiveService {
  final FirebaseFunctions? _functions;
  final VocabularyRepository _vocabularyRepository;

  BaseAiAdaptiveService({
    FirebaseFunctions? functions,
    VocabularyRepository? vocabularyRepository,
  })  : _functions = functions,
        _vocabularyRepository = vocabularyRepository ?? BaseVocabularyRepository();

  FirebaseFunctions get _functionsInstance {
    return _functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');
  }

  // Canonical Whitelisted Educational Vocabulary Domain for Children with ASD (Task 13)
  static const Map<String, List<String>> allowedCategoryVocabulary = {
    'animals': ['cat', 'dog', 'bird', 'cow', 'lion', 'elephant'],
    'colors': ['red', 'blue', 'green', 'yellow', 'orange', 'purple'],
    'numbers': ['one', 'two', 'three', 'four', 'five'],
    'letters': ['alef', 'baa', 'taa', 'thaa', 'jeem'],
  };

  @override
  Future<QuizQuestionModel> generateExercise({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    String exerciseType = 'identify_item',
    double recentAccuracy = 0.75,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    // Task 8: Clamped difficulty boundaries
    final clampedDifficulty = difficultyLevel.clamp(1, 3);
    final normalizedLang = preferredLanguage == 'ar' ? 'ar' : 'en';

    try {
      // Task 14: Privacy - Transmit only non-identifying educational context
      final payload = <String, dynamic>{
        'categoryId': categoryId,
        'difficultyLevel': clampedDifficulty,
        'preferredLanguage': normalizedLang,
        'exerciseType': exerciseType,
        'recentAccuracy': recentAccuracy,
      };

      final callable = _functionsInstance.httpsCallable('generateAdaptiveExercise');
      final response = await callable.call(payload).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('AI exercise generation timed out (${timeout.inSeconds}s)');
        },
      );

      final rawData = response.data;
      if (rawData is Map) {
        final dataMap = Map<String, dynamic>.from(rawData);

        // Task 5: Validate response format, choices count, and curriculum domain
        if (validateExerciseData(dataMap)) {
          return _mapToQuizQuestionModel(dataMap, categoryId, clampedDifficulty);
        } else {
          debugPrint(
            'BaseAiAdaptiveService: Server returned invalid exercise schema. Activating fallback.',
          );
        }
      }
    } catch (e) {
      // Task 15 & 16: Safe error handling and fallback activation (no sensitive data logged)
      debugPrint('BaseAiAdaptiveService: AI unavailable or encountered error ($e). Activating fallback.');
    }

    // Task 6: Predefined verified fallback mechanism
    return _generateFallbackExercise(
      categoryId: categoryId,
      difficultyLevel: clampedDifficulty,
      preferredLanguage: normalizedLang,
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
    final List<QuizQuestionModel> questions = [];
    final exerciseTypes = [
      'identify_item',
      'select_correct_image',
      'match_word_image',
      'choose_between_items',
    ];

    for (int i = 0; i < count; i++) {
      final type = exerciseTypes[i % exerciseTypes.length];
      final q = await generateExercise(
        categoryId: categoryId,
        difficultyLevel: difficultyLevel,
        preferredLanguage: preferredLanguage,
        exerciseType: type,
        recentAccuracy: recentAccuracy,
      );
      questions.add(q);
    }

    return questions;
  }

  /// Validates AI response according to strict autism-friendly educational criteria (Task 5 & 13):
  /// - Required fields (promptEn, promptAr, correctChoiceId, choices)
  /// - Exactly 3 answer choices
  /// - Correct answer is present in choices
  /// - Choice IDs belong to whitelisted educational vocabulary domain
  @override
  bool validateExerciseData(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    final promptEn = data['promptEn'] as String?;
    final promptAr = data['promptAr'] as String?;
    final correctChoiceId = data['correctChoiceId'] as String?;
    final rawChoices = data['choices'];

    if (promptEn == null || promptEn.trim().isEmpty) return false;
    if (promptAr == null || promptAr.trim().isEmpty) return false;
    if (correctChoiceId == null || correctChoiceId.trim().isEmpty) return false;
    if (rawChoices is! List || rawChoices.length != 3) return false;

    final choiceIds = <String>[];
    for (final item in rawChoices) {
      if (item is! Map) return false;
      final id = item['id']?.toString();
      final labelEn = item['labelEn']?.toString();
      final labelAr = item['labelAr']?.toString();

      if (id == null || id.isEmpty) return false;
      if (labelEn == null || labelEn.isEmpty) return false;
      if (labelAr == null || labelAr.isEmpty) return false;

      choiceIds.add(id);
    }

    // Verify correct choice is present
    if (!choiceIds.contains(correctChoiceId)) return false;

    // Verify all choice IDs belong to known educational vocabulary
    final categoryId = data['categoryId']?.toString() ?? 'animals';
    final allowedList = allowedCategoryVocabulary[categoryId];
    if (allowedList != null && allowedList.isNotEmpty) {
      for (final id in choiceIds) {
        if (!allowedList.contains(id.toLowerCase())) {
          return false; // Reject unknown/hallucinated items
        }
      }
    }

    return true;
  }

  /// Transforms validated JSON data into [QuizQuestionModel].
  QuizQuestionModel _mapToQuizQuestionModel(
    Map<String, dynamic> data,
    String categoryId,
    int difficultyLevel,
  ) {
    final rawChoices = data['choices'] as List<dynamic>;
    final choices = rawChoices.map((c) {
      final map = Map<String, dynamic>.from(c as Map);
      final id = map['id'].toString();
      final labelEn = map['labelEn'].toString();
      final labelAr = map['labelAr'].toString();
      final itemIcon = _resolveIcon(id);
      final itemColor = _resolveColor(id);

      return QuizChoice(
        id: id,
        labelEn: labelEn,
        labelAr: labelAr,
        imageUrl: 'assets/images/vocabulary/$id.png',
        icon: itemIcon,
        accentColor: itemColor,
      );
    }).toList();

    final correctChoiceId = data['correctChoiceId'].toString();

    return QuizQuestionModel(
      id: data['id']?.toString() ?? 'ai_q_${DateTime.now().millisecondsSinceEpoch}',
      promptEn: data['promptEn']?.toString() ?? 'Where is the item?',
      promptAr: data['promptAr']?.toString() ?? 'أين العنصر؟',
      correctChoiceId: correctChoiceId,
      choices: choices,
      categoryId: categoryId,
      difficultyLevel: difficultyLevel,
    );
  }

  /// Instant, deterministic fallback to local verified educational vocabulary (Task 6).
  Future<QuizQuestionModel> _generateFallbackExercise({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
  }) async {
    try {
      final pool = await _vocabularyRepository.getVocabularyForCategory(categoryId);
      if (pool.isNotEmpty) {
        final matched = pool.where((item) => item.difficultyLevel <= difficultyLevel).toList();
        final target = matched.isNotEmpty ? matched.first : pool.first;

        final selected = <VocabularyItemModel>[target];
        for (final item in pool) {
          if (selected.length < 3 && item.id != target.id) {
            selected.add(item);
          }
        }

        if (selected.length == 3) {
          final choices = selected.map((item) {
            return QuizChoice(
              id: item.id,
              labelEn: item.wordEn,
              labelAr: item.wordAr,
              imageUrl: item.imageUrl,
              icon: _resolveIcon(item.id),
              accentColor: _resolveColor(item.id),
              vocabularyItem: item,
            );
          }).toList();

          return QuizQuestionModel(
            id: 'fallback_${categoryId}_${target.id}',
            promptEn: 'Where is the ${target.wordEn}?',
            promptAr: 'أين ${target.wordAr}؟',
            correctChoiceId: target.id,
            choices: choices,
            categoryId: categoryId,
            difficultyLevel: difficultyLevel,
            targetItem: target,
          );
        }
      }
    } catch (_) {
      // In-memory mock fallback
    }

    return MockDataRepository.getQuizQuestionForCategory(categoryId);
  }

  static IconData _resolveIcon(String id) {
    switch (id.toLowerCase()) {
      case 'cat':
        return Icons.pets_rounded;
      case 'dog':
        return Icons.cruelty_free_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'cow':
        return Icons.agriculture_rounded;
      case 'lion':
        return Icons.shield_rounded;
      case 'elephant':
        return Icons.landscape_rounded;
      case 'red':
      case 'blue':
      case 'green':
      case 'yellow':
      case 'orange':
      case 'purple':
        return Icons.palette_rounded;
      case 'one':
      case 'two':
      case 'three':
      case 'four':
      case 'five':
        return Icons.pin_rounded;
      case 'alef':
      case 'baa':
      case 'taa':
      case 'thaa':
      case 'jeem':
        return Icons.menu_book_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  static Color _resolveColor(String id) {
    switch (id.toLowerCase()) {
      case 'red':
        return const Color(0xFFEF4444);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'green':
        return const Color(0xFF10B981);
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'orange':
        return const Color(0xFFF97316);
      case 'purple':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
