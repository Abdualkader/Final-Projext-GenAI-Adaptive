import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/learning_session_model.dart';
import '../services/firestore_service.dart';

/// Repository interface for learning session telemetry and analytics recording.
abstract class SessionRepository {
  Future<void> recordSession(LearningSessionModel session);
  Future<List<LearningSessionModel>> getRecentSessions(
    String childId, {
    int limit = 10,
  });
}

/// Base implementation of [SessionRepository].
class BaseSessionRepository implements SessionRepository {
  final FirestoreService _firestoreService;
  final List<LearningSessionModel> _inMemorySessions = [];

  BaseSessionRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<void> recordSession(LearningSessionModel session) async {
    _inMemorySessions.add(session);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.sessions,
        session.sessionId,
        session.toMap(),
      );
    } catch (e) {
      debugPrint('SessionRepository: Logged session locally (${session.sessionId}): $e');
    }
  }

  @override
  Future<List<LearningSessionModel>> getRecentSessions(
    String childId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestoreService.getCollection(
        FirebaseCollections.sessions,
        orderByField: 'startTime',
        descending: true,
        limit: limit,
      );
      final sessions = snapshot.docs
          .where((doc) => doc.data()['childId'] == childId)
          .map((doc) => LearningSessionModel.fromMap(doc.data(), id: doc.id))
          .toList();
      if (sessions.isNotEmpty) return sessions;
    } catch (_) {
      // Fallback to in-memory sessions
    }

    return _inMemorySessions.where((s) => s.childId == childId).toList();
  }
}
