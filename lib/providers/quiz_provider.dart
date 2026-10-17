import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/learning_session_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/session_repository.dart';
import '../services/audio_service.dart';

/// State management controller for interactive quiz assessments and positive reinforcement (Week 10).
class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepository;
  final SessionRepository _sessionRepository;
  final AudioService _audioService;

  QuizProvider({
    QuizRepository? quizRepository,
    SessionRepository? sessionRepository,
    AudioService? audioService,
  })  : _quizRepository = quizRepository ?? BaseQuizRepository(),
        _sessionRepository = sessionRepository ?? BaseSessionRepository(),
        _audioService = audioService ?? AudioService();

  UiState<QuizQuestionModel> _uiState = const UiState.initial();
  QuizQuestionModel? _question;
  List<QuizQuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedChoiceId;
  int _starsCount = 12;
  String _activeCategoryId = 'animals';
  String _activeChildId = 'child_adam';
  String _sessionId = 'session_mock';
  int _score = 0;
  bool _isQuizCompleted = false;
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;
  DateTime? _questionStartTime;
  final List<QuizResultModel> _recordedResults = [];

  // 60-Second Peaceful Timer State (Task 9)
  Timer? _timer;
  int _remainingSeconds = 60;
  Duration _questionTimeoutDuration = const Duration(seconds: 60);
  bool _isTimedOut = false;

  // Getters
  UiState<QuizQuestionModel> get uiState => _uiState;
  QuizQuestionModel? get question => _question;
  List<QuizQuestionModel> get questions => List.unmodifiable(_questions);
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.isNotEmpty ? _questions.length : 1;
  String? get selectedChoiceId => _selectedChoiceId;
  int get starsCount => _starsCount;
  String get activeCategoryId => _activeCategoryId;
  String get activeChildId => _activeChildId;
  String get sessionId => _sessionId;
  int get score => _score;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isSessionActive => _isSessionActive;
  int get remainingSeconds => _remainingSeconds;
  Duration get questionTimeoutDuration => _questionTimeoutDuration;
  bool get isTimedOut => _isTimedOut;
  List<QuizResultModel> get recordedResults => List.unmodifiable(_recordedResults);

  double get accuracyFraction =>
      _questions.isEmpty ? 0.0 : (_score / _questions.length);
  int get accuracyPercentage => (accuracyFraction * 100).round();

  bool get isAnswered => _selectedChoiceId != null || _isTimedOut;
  bool get isCorrect =>
      _question != null &&
      _selectedChoiceId != null &&
      _selectedChoiceId == _question!.correctChoiceId;

  /// Starts a full multi-question quiz session with associated child and category (Task 2, 8, 9, 11, 12).
  Future<void> startQuizSession({
    required String childId,
    required String categoryId,
    int questionCount = 5,
    int? maxDifficulty,
    bool shuffle = true,
    Duration timeoutDuration = const Duration(seconds: 60),
    bool enableTimer = true,
  }) async {
    cancelTimer();
    _activeChildId = childId;
    _activeCategoryId = categoryId;
    _sessionId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizCompleted = false;
    _isSessionActive = true;
    _isTimedOut = false;
    _selectedChoiceId = null;
    _recordedResults.clear();
    _sessionStartTime = DateTime.now();
    _questionTimeoutDuration = timeoutDuration;
    _remainingSeconds = timeoutDuration.inSeconds;
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final list = await _quizRepository.getQuizQuestionsForCategory(
        categoryId,
        count: questionCount,
        maxDifficulty: maxDifficulty,
        shuffle: shuffle,
      );

      if (list.isNotEmpty) {
        _questions = list;
        _question = _questions[0];
      } else {
        final fallback = await _quizRepository.getQuizQuestionForCategory(categoryId);
        _questions = [fallback];
        _question = fallback;
      }

      _questionStartTime = DateTime.now();
      _uiState = UiState.success(_question!);

      if (enableTimer) {
        _startTimer();
      }

      // Record session initiation (Task 2)
      final session = LearningSessionModel(
        sessionId: _sessionId,
        childId: _activeChildId,
        categoryId: _activeCategoryId,
        startTime: _sessionStartTime!,
        itemsPresented: _questions.map((q) => q.correctChoiceId).toList(),
        score: 0.0,
      );
      await _sessionRepository.createSession(session);
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to start quiz session: $e'),
      );
    }
    notifyListeners();
  }

  /// Loads a single quiz question for a given category (backwards-compatible with Week 4 & core test).
  Future<void> loadQuizQuestion(
    String categoryId, {
    bool enableTimer = false,
  }) async {
    cancelTimer();
    _activeCategoryId = categoryId;
    _selectedChoiceId = null;
    _isTimedOut = false;
    _isQuizCompleted = false;
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final q = await _quizRepository.getQuizQuestionForCategory(categoryId);
      _question = q;
      _questions = [q];
      _currentQuestionIndex = 0;
      _questionStartTime = DateTime.now();
      _uiState = UiState.success(q);
      if (enableTimer) {
        _startTimer();
      }
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load quiz question: $e'),
      );
    }
    notifyListeners();
  }

  /// Selects a choice, triggers gentle audio feedback, and records attempt in Firestore (Task 5, 6, 7, 8).
  Future<void> selectChoice(
    String choiceId, {
    String? sessionId,
    int stars = 1,
  }) async {
    if (_question == null || isAnswered) return;
    cancelTimer();

    _selectedChoiceId = choiceId;
    final correct = choiceId == _question!.correctChoiceId;

    if (correct) {
      _score++;
      _starsCount += stars;
      await _audioService.playSuccessChime();
    } else {
      await _audioService.playGentleRetryChime();
    }

    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : null;

    final targetSessionId = sessionId ?? _sessionId;
    final result = QuizResultModel(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: targetSessionId,
      childId: _activeChildId,
      questionId: _question!.id,
      childResponse: choiceId,
      isCorrect: correct,
      responseTimeMs: responseTimeMs,
      timestamp: DateTime.now(),
    );

    _recordedResults.add(result);

    try {
      await _quizRepository.recordQuizResult(result);
    } catch (e) {
      debugPrint('QuizProvider record attempt error: $e');
    }

    notifyListeners();
  }

  /// Automatically or peacefully handles question timeout (Task 9).
  Future<void> handleTimeout({String? sessionId}) async {
    if (_question == null || isAnswered) return;
    cancelTimer();

    _isTimedOut = true;
    _selectedChoiceId = null;

    // Peaceful audio indication (soft chime, no alarming buzzer)
    await _audioService.playGentleRetryChime();

    final targetSessionId = sessionId ?? _sessionId;
    final result = QuizResultModel(
      resultId: 'timeout_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: targetSessionId,
      childId: _activeChildId,
      questionId: _question!.id,
      childResponse: 'timeout',
      isCorrect: false,
      responseTimeMs: _questionTimeoutDuration.inMilliseconds,
      timestamp: DateTime.now(),
    );

    _recordedResults.add(result);

    try {
      await _quizRepository.recordQuizResult(result);
    } catch (e) {
      debugPrint('QuizProvider timeout record error: $e');
    }

    notifyListeners();
  }

  /// Advances to the next question in the quiz session, or completes the quiz if finished (Task 10).
  Future<void> nextQuestion({bool enableTimer = true}) async {
    cancelTimer();

    if (_currentQuestionIndex + 1 < _questions.length) {
      _currentQuestionIndex++;
      _question = _questions[_currentQuestionIndex];
      _selectedChoiceId = null;
      _isTimedOut = false;
      _questionStartTime = DateTime.now();
      _remainingSeconds = _questionTimeoutDuration.inSeconds;
      _uiState = UiState.success(_question!);

      if (enableTimer) {
        _startTimer();
      }
      notifyListeners();
    } else {
      await finishQuiz();
    }
  }

  /// Completes the quiz session, tallies final score, and persists to Firestore (Task 8 & 10).
  Future<void> finishQuiz() async {
    cancelTimer();
    _isQuizCompleted = true;
    _isSessionActive = false;

    await _audioService.playSuccessChime();

    try {
      await _sessionRepository.completeSession(
        _sessionId,
        endTime: DateTime.now(),
        score: accuracyFraction,
      );
    } catch (e) {
      debugPrint('QuizProvider finish session error: $e');
    }

    notifyListeners();
  }

  /// Restarts the quiz session with the same parameters (Task 10).
  Future<void> restartQuiz({
    bool shuffle = true,
    bool enableTimer = true,
  }) async {
    await startQuizSession(
      childId: _activeChildId,
      categoryId: _activeCategoryId,
      questionCount: _questions.isNotEmpty ? _questions.length : 5,
      shuffle: shuffle,
      timeoutDuration: _questionTimeoutDuration,
      enableTimer: enableTimer,
    );
  }

  /// Internal timer countdown driver (Task 9).
  void _startTimer() {
    cancelTimer();
    _isTimedOut = false;
    _remainingSeconds = _questionTimeoutDuration.inSeconds;

    if (_questionTimeoutDuration.inSeconds <= 0 &&
        _questionTimeoutDuration.inMilliseconds > 0) {
      _timer = Timer(_questionTimeoutDuration, () {
        handleTimeout();
      });
      return;
    }

    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        timer.cancel();
        handleTimeout();
      }
    });
  }

  /// Cancels active timer safely.
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resets the current question selection for another attempt without penalty.
  void resetSelection() {
    _selectedChoiceId = null;
    _isTimedOut = false;
    notifyListeners();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}
