import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/firestore_service.dart';
import 'mock_data_repository.dart';

/// Repository interface for interactive quiz assessments and result logging.
abstract class QuizRepository {
  /// Stores a granular quiz attempt log in Cloud Firestore.
  Future<void> recordQuizResult(QuizResultModel result);

  /// Retrieves all quiz results associated with a specific session.
  Future<List<QuizResultModel>> getQuizResultsForSession(String sessionId);

  /// Retrieves quiz results for a specific child profile.
  Future<List<QuizResultModel>> getQuizResultsForChild(String childId);

  /// Retrieves or generates a 3-option quiz question for a learning category.
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId);
}

/// Base implementation of [QuizRepository] communicating with Cloud Firestore.
class BaseQuizRepository implements QuizRepository {
  final FirestoreService _firestoreService;
  final List<QuizResultModel> _inMemoryResults = [];

  BaseQuizRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

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
        return snapshot.docs
            .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _inMemoryResults.where((r) => r.sessionId == sessionId).toList();
  }

  @override
  Future<List<QuizResultModel>> getQuizResultsForChild(String childId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.quizResults,
        whereEquals: {'childId': childId},
      );
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _inMemoryResults.where((r) => r.childId == childId).toList();
  }

  @override
  Future<QuizQuestionModel> getQuizQuestionForCategory(String categoryId) async {
    return MockDataRepository.getQuizQuestionForCategory(categoryId);
  }
}
