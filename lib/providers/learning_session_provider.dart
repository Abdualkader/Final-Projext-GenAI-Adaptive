import 'package:flutter/foundation.dart';
import '../models/learning_session_model.dart';
import '../repositories/session_repository.dart';

/// State management controller for tracking child learning sessions and telemetry.
class LearningSessionProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  LearningSessionProvider({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? BaseSessionRepository();

  LearningSessionModel? _currentSession;
  final List<String> _itemsPresented = [];

  LearningSessionModel? get currentSession => _currentSession;
  bool get isSessionActive => _currentSession != null;
  List<String> get itemsPresented => List.unmodifiable(_itemsPresented);

  /// Starts a new learning session for a child and category.
  void startSession(String childId, String categoryId) {
    _itemsPresented.clear();
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _currentSession = LearningSessionModel(
      sessionId: sessionId,
      childId: childId,
      categoryId: categoryId,
      startTime: DateTime.now(),
      itemsPresented: _itemsPresented,
    );
    notifyListeners();
  }

  /// Records an item displayed to the child during this session.
  void recordItemPresented(String itemId) {
    if (!_itemsPresented.contains(itemId)) {
      _itemsPresented.add(itemId);
      notifyListeners();
    }
  }

  /// Ends the active session, calculates duration and score, and persists record.
  Future<void> endSession({double score = 1.0}) async {
    if (_currentSession == null) return;

    final completedSession = _currentSession!.copyWith(
      endTime: DateTime.now(),
      itemsPresented: List.from(_itemsPresented),
      score: score,
    );

    try {
      await _sessionRepository.recordSession(completedSession);
    } catch (e) {
      debugPrint('LearningSessionProvider endSession error: $e');
    }

    _currentSession = null;
    _itemsPresented.clear();
    notifyListeners();
  }
}
