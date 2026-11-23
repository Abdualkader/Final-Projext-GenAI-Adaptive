import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/learning_session_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data_service.dart';

/// Repository interface for learning session telemetry and analytics recording.
abstract class SessionRepository {
  /// Creates a new learning session in Cloud Firestore.
  Future<void> createSession(LearningSessionModel session);

  /// Updates an active learning session with current telemetry.
  Future<void> updateSession(LearningSessionModel session);

  /// Marks a learning session as completed with final timestamp and score.
  Future<void> completeSession(
    String sessionId, {
    required DateTime endTime,
    required double score,
  });

  /// Retrieves an individual session by ID.
  Future<LearningSessionModel?> getSessionById(String sessionId);

  /// Retrieves the most recent sessions for a given child profile.
  Future<List<LearningSessionModel>> getRecentSessions(
    String childId, {
    int limit = 10,
  });

  /// Backwards-compatible alias for [createSession].
  Future<void> recordSession(LearningSessionModel session);
}

/// Base implementation of [SessionRepository] communicating with Cloud Firestore.
class BaseSessionRepository implements SessionRepository {
  final FirestoreService _firestoreService;
  static final List<LearningSessionModel> _inMemorySessions = [
    SampleDataService.sampleSession,
  ];

  BaseSessionRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<void> createSession(LearningSessionModel session) async {
    _inMemorySessions.add(session);
    await LocalStorageService.saveSession(session);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.sessions,
        session.sessionId,
        session.toMap(),
      );
    } catch (e) {
      debugPrint('SessionRepository: Saved session locally (${session.sessionId}): $e');
    }
  }

  @override
  Future<void> recordSession(LearningSessionModel session) => createSession(session);

  @override
  Future<void> updateSession(LearningSessionModel session) async {
    final index = _inMemorySessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (index != -1) {
      _inMemorySessions[index] = session;
    } else {
      _inMemorySessions.add(session);
    }
    await LocalStorageService.saveSession(session);

    try {
      await _firestoreService.updateDocument(
        FirebaseCollections.sessions,
        session.sessionId,
        session.toMap(),
      );
    } catch (e) {
      debugPrint('SessionRepository: Updated session locally (${session.sessionId}): $e');
    }
  }

  @override
  Future<void> completeSession(
    String sessionId, {
    required DateTime endTime,
    required double score,
  }) async {
    final index = _inMemorySessions.indexWhere((s) => s.sessionId == sessionId);
    if (index != -1) {
      final updated = _inMemorySessions[index].copyWith(
        endTime: endTime,
        score: score,
      );
      _inMemorySessions[index] = updated;
      await LocalStorageService.saveSession(updated);
    }

    try {
      await _firestoreService.updateDocument(
        FirebaseCollections.sessions,
        sessionId,
        {
          'endTime': endTime.toIso8601String(),
          'score': score,
        },
      );
    } catch (e) {
      debugPrint('SessionRepository: Completed session locally ($sessionId): $e');
    }
  }

  @override
  Future<LearningSessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _firestoreService.getDocument(
        FirebaseCollections.sessions,
        sessionId,
      );
      if (doc != null && doc.exists && doc.data() != null) {
        final session = LearningSessionModel.fromMap(doc.data()!, id: doc.id);
        await LocalStorageService.saveSession(session);
        return session;
      }
    } catch (_) {
      // Fallback
    }

    final mem = _inMemorySessions.where((s) => s.sessionId == sessionId).firstOrNull;
    if (mem != null) return mem;

    final all = await LocalStorageService.getAllSessions();
    return all.where((s) => s.sessionId == sessionId).firstOrNull;
  }

  @override
  Future<List<LearningSessionModel>> getRecentSessions(
    String childId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.sessions,
        whereEquals: {'childId': childId},
        orderByField: 'startTime',
        descending: true,
        limit: limit,
      );
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => LearningSessionModel.fromMap(doc.data(), id: doc.id))
            .toList();
        for (final s in list) {
          await LocalStorageService.saveSession(s);
        }
        return list;
      }
    } catch (_) {
      // Fallback
    }

    final localSessions = await LocalStorageService.getSessionsForChild(childId);
    final map = <String, LearningSessionModel>{};
    for (final s in _inMemorySessions.where((s) => s.childId == childId)) {
      map[s.sessionId] = s;
    }
    for (final s in localSessions) {
      map[s.sessionId] = s;
    }

    final merged = map.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
    return merged.take(limit).toList();
  }
}

