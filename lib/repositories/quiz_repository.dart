import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/firestore_service.dart';
import 'mock_data_repository.dart';

/// Repository interface for interactive quiz assessments and result logging.
abstract class QuizRepository {
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId);
  Future<void> recordQuizResult(QuizResultModel result);
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId);
}

/// Base implementation of [QuizRepository].
class BaseQuizRepository implements QuizRepository {
  final FirestoreService _firestoreService;
  final List<QuizResultModel> _inMemoryResults = [];

  BaseQuizRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId) async {
    return MockDataRepository.getQuizQuestionForCategory(categoryId);
  }

  @override
  Future<void> recordQuizResult(QuizResultModel result) async {
    _inMemoryResults.add(result);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.quizResults,
        result.resultId,
        result.toMap(),
      );
    } catch (e) {
      debugPrint('QuizRepository: Logged quiz result locally (${result.resultId}): $e');
    }
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId) async {
    try {
      final snapshot = await _firestoreService.getCollection(
        FirebaseCollections.quizResults,
      );
      final results = snapshot.docs
          .where((doc) => doc.data()['sessionId'] == sessionId)
          .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
          .toList();
      if (results.isNotEmpty) return results;
    } catch (_) {
      // Fallback
    }

    return _inMemoryResults.where((r) => r.sessionId == sessionId).toList();
  }
}
