import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/firebase_collections.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/vocabulary_item_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data_service.dart';
import 'mock_data_repository.dart';
import 'vocabulary_repository.dart';

/// Repository interface for interactive quiz assessments and result logging (Week 10).
abstract class QuizRepository {
  /// Stores a granular quiz attempt log in Cloud Firestore.
  Future<void> recordQuizResult(QuizResultModel result);

  /// Retrieves all quiz results associated with a specific session.
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId);

  /// Retrieves quiz results for a specific child profile.
  Future<List<QuizResultModel>> getQuizResultsForChild(String childId);

  /// Retrieves or generates a 3-option quiz question for a learning category.
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId);

  /// Generates a series of 3-option multiple-choice questions from vocabulary data (Task 3, 4, 11, 12).
  Future<List<QuizQuestionModel>> getQuizQuestionsForCategory(
    String categoryId, {
    int count = 5,
    int? maxDifficulty,
    bool shuffle = true,
  });
}

/// Base implementation of [QuizRepository] communicating with Cloud Firestore.
class BaseQuizRepository implements QuizRepository {
  final FirestoreService _firestoreService;
  final VocabularyRepository _vocabularyRepository;
  static final List<QuizResultModel> _inMemoryResults = [];

  BaseQuizRepository({
    FirestoreService? firestoreService,
    VocabularyRepository? vocabularyRepository,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _vocabularyRepository = vocabularyRepository ?? BaseVocabularyRepository();

  @override
  Future<void> recordQuizResult(QuizResultModel result) async {
    _inMemoryResults.add(result);
    await LocalStorageService.saveQuizResult(result);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.quizResults,
        result.resultId,
        result.toMap(),
      );
    } catch (e) {
      debugPrint('QuizRepository: Saved quiz result locally (${result.resultId}): $e');
    }
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.quizResults,
        whereEquals: {'sessionId': sessionId},
      );
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
            .toList();
        for (final r in list) {
          await LocalStorageService.saveQuizResult(r);
        }
        return list;
      }
    } catch (_) {
      // Fallback
    }

    final allLocal = await LocalStorageService.getAllQuizResults();
    final map = <String, QuizResultModel>{};
    for (final r in _inMemoryResults.where((r) => r.sessionId == sessionId)) {
      map[r.resultId] = r;
    }
    for (final r in allLocal.where((r) => r.sessionId == sessionId)) {
      map[r.resultId] = r;
    }
    return map.values.toList();
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForChild(String childId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.quizResults,
        whereEquals: {'childId': childId},
      );
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
            .toList();
        for (final r in list) {
          await LocalStorageService.saveQuizResult(r);
        }
        return list;
      }
    } catch (_) {
      // Fallback
    }

    final localResults = await LocalStorageService.getQuizResultsForChild(childId);
    final map = <String, QuizResultModel>{};
    for (final r in _inMemoryResults.where((r) => r.childId == childId)) {
      map[r.resultId] = r;
    }
    for (final r in localResults) {
      map[r.resultId] = r;
    }
    return map.values.toList();
  }


  @override
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId) async {
    return MockDataRepository.getQuizQuestionForCategory(categoryId);
  }

  @override
  Future<List<QuizQuestionModel>> getQuizQuestionsForCategory(
    String categoryId, {
    int count = 5,
    int? maxDifficulty,
    bool shuffle = true,
  }) async {
    List<VocabularyItemModel> items = [];
    try {
      items = await _vocabularyRepository.getVocabularyForCategory(
        categoryId,
        maxDifficulty: maxDifficulty,
      );
    } catch (_) {}

    if (items.isEmpty) {
      final normalizedCat = (categoryId == 'colors' || categoryId == 'colours')
          ? 'colours'
          : categoryId;
      items = SampleDataService.sampleVocabulary
          .where((v) => v.categoryId == normalizedCat)
          .toList();
    }

    if (items.isEmpty) {
      return MockDataRepository.getQuizQuestionsForCategory(categoryId, count: count);
    }

    // Filter by maxDifficulty if provided (Task 12)
    if (maxDifficulty != null) {
      final filtered = items.where((i) => i.difficultyLevel <= maxDifficulty).toList();
      if (filtered.isNotEmpty) {
        items = filtered;
      }
    }

    final questions = <QuizQuestionModel>[];
    final random = Random();

    // Preserve the wireframe default question for animals as question 1
    if ((categoryId == 'animals' || categoryId == 'all') && items.any((i) => i.id == 'dog')) {
      final defaultAnimalQ = MockDataRepository.getQuizQuestionForCategory('animals');
      final choices = List<QuizChoice>.from(defaultAnimalQ.choices);
      if (shuffle) choices.shuffle(random);
      questions.add(
        defaultAnimalQ.copyWith(
          choices: choices,
          categoryId: 'animals',
          difficultyLevel: 1,
        ),
      );
    }

    // Generate questions for remaining items
    for (final target in items) {
      if (questions.any((q) => q.correctChoiceId == target.id)) continue;
      if (questions.length >= count) break;

      // Select 2 distractors from items in same category or fallback items
      final availableDistractors = items.where((i) => i.id != target.id).toList();
      final distractors = <VocabularyItemModel>[];

      if (availableDistractors.length >= 2) {
        final pool = List<VocabularyItemModel>.from(availableDistractors)..shuffle(random);
        distractors.addAll(pool.take(2));
      } else {
        // Pool from sampleVocabulary across other categories if needed
        final otherPool = SampleDataService.sampleVocabulary
            .where((i) => i.id != target.id)
            .toList()
          ..shuffle(random);
        distractors.addAll(otherPool.take(2));
      }

      // Build 3 answer choices (Task 4)
      final allChoices = <QuizChoice>[
        _buildChoiceFromItem(target),
        _buildChoiceFromItem(distractors[0]),
        _buildChoiceFromItem(distractors[1]),
      ];

      // Randomize choice order so correct answer is not always in the same position (Task 4 & 11)
      if (shuffle) {
        allChoices.shuffle(random);
      }

      final promptEn = _buildPromptEn(target);
      final promptAr = _buildPromptAr(target);

      questions.add(
        QuizQuestionModel(
          id: 'quiz_${categoryId}_${target.id}',
          promptEn: promptEn,
          promptAr: promptAr,
          correctChoiceId: target.id,
          choices: allChoices,
          categoryId: categoryId,
          difficultyLevel: target.difficultyLevel,
          targetItem: target,
        ),
      );
    }

    return questions.take(count).toList();
  }

  QuizChoice _buildChoiceFromItem(VocabularyItemModel item) {
    return QuizChoice(
      id: item.id,
      labelEn: item.wordEn,
      labelAr: item.wordAr,
      imageUrl: item.imageUrl,
      icon: _getIconForId(item.id),
      accentColor: _getColorForId(item.id),
      vocabularyItem: item,
    );
  }

  String _buildPromptEn(VocabularyItemModel item) {
    final lower = item.wordEn.toLowerCase();
    if (lower.startsWith('letter ') || lower.startsWith('number ')) {
      return 'Where is ${item.wordEn}?';
    }
    if (item.categoryId == 'colours' || item.categoryId == 'colors') {
      return 'Which one is ${item.wordEn}?';
    }
    return 'Where is the ${item.wordEn.toLowerCase()}?';
  }

  String _buildPromptAr(VocabularyItemModel item) {
    if (item.categoryId == 'colours' || item.categoryId == 'colors') {
      return 'أين اللون ال${item.wordAr}؟';
    }
    return 'أين ${item.wordAr}؟';
  }

  IconData _getIconForId(String id) {
    switch (id.toLowerCase()) {
      case 'cat':
        return Icons.cruelty_free_rounded;
      case 'dog':
      case 'lion':
        return Icons.pets_rounded;
      case 'rabbit':
        return Icons.cruelty_free_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'fish':
        return Icons.set_meal_rounded;
      case 'red':
      case 'blue':
      case 'green':
      case 'yellow':
      case 'orange':
        return Icons.circle;
      case 'one':
        return Icons.looks_one_rounded;
      case 'two':
        return Icons.looks_two_rounded;
      case 'three':
        return Icons.looks_3_rounded;
      case 'alif':
      case 'baa':
      case 'taa':
      default:
        return Icons.text_fields_rounded;
    }
  }

  Color _getColorForId(String id) {
    switch (id.toLowerCase()) {
      case 'dog':
        return const Color(0xFF22C55E);
      case 'cat':
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'fish':
        return const Color(0xFFA855F7);
      case 'rabbit':
      case 'orange':
        return const Color(0xFFF97316);
      case 'lion':
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'bird':
      case 'one':
        return const Color(0xFF0288D1);
      case 'red':
        return const Color(0xFFEF4444);
      case 'green':
      case 'three':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF8E24AA);
    }
  }
}
