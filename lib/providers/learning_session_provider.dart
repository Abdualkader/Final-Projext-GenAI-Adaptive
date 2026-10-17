import 'package:flutter/foundation.dart';
import '../models/learning_session_model.dart';
import '../repositories/session_repository.dart';

/// State management controller for tracking child learning sessions and telemetry.
/// Implements Week 9 Tasks 2, 8, & 10: Session creation, item tracking, and completion.
class LearningSessionProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  LearningSessionProvider({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? BaseSessionRepository();

  LearningSessionModel? _currentSession;
  LearningSessionModel? _lastCompletedSession;
  final List<String> _itemsPresented = [];
  bool _isSessionCompleted = false;

  LearningSessionModel? get currentSession => _currentSession;
  LearningSessionModel? get lastCompletedSession => _lastCompletedSession;
  bool get isSessionActive => _currentSession != null;
  bool get isSessionCompleted => _isSessionCompleted;
  List<String> get itemsPresented => List.unmodifiable(_itemsPresented);

  /// Starts a new learning session for a child and category (Task 2).
  /// Immediately stores initial session record via [SessionRepository].
  Future<LearningSessionModel> startSession(String childId, String categoryId) async {
    _itemsPresented.clear();
    _isSessionCompleted = false;
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = LearningSessionModel(
      sessionId: sessionId,
      childId: childId,
      categoryId: categoryId,
      startTime: DateTime.now(),
      itemsPresented: _itemsPresented,
    );

    _currentSession = session;
    notifyListeners();

    try {
      await _sessionRepository.createSession(session);
    } catch (e) {
      debugPrint('LearningSessionProvider: Session initialized locally ($sessionId): $e');
    }

    return session;
  }

  /// Records an item displayed to the child during this session (Task 8).
  void recordItemPresented(String itemId) {
    if (itemId.isNotEmpty && !_itemsPresented.contains(itemId)) {
      _itemsPresented.add(itemId);
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(
          itemsPresented: List.from(_itemsPresented),
        );
        _sessionRepository.updateSession(_currentSession!);
      }
      notifyListeners();
    }
  }

  /// Ends the active session, calculates duration and score, and persists record (Task 10).
  Future<LearningSessionModel?> endSession({double score = 1.0}) async {
    if (_currentSession == null) return null;

    final endTime = DateTime.now();
    final completedSession = _currentSession!.copyWith(
      endTime: endTime,
      itemsPresented: List.from(_itemsPresented),
      score: score,
    );

    _lastCompletedSession = completedSession;
    _isSessionCompleted = true;
    _currentSession = null;
    _itemsPresented.clear();
    notifyListeners();

    try {
      await _sessionRepository.completeSession(
        completedSession.sessionId,
        endTime: endTime,
        score: score,
      );
      await _sessionRepository.recordSession(completedSession);
    } catch (e) {
      debugPrint('LearningSessionProvider endSession error: $e');
    }

    return completedSession;
  }

  /// Resets active and completed session state for subsequent learning loops.
  void resetSession() {
    _currentSession = null;
    _lastCompletedSession = null;
    _itemsPresented.clear();
    _isSessionCompleted = false;
    notifyListeners();
  }
}
