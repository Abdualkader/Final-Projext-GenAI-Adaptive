import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../repositories/quiz_repository.dart';
import '../services/audio_service.dart';

/// State management controller for interactive quiz assessments and positive reinforcement.
class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepository;
  final AudioService _audioService;

  QuizProvider({
    QuizRepository? quizRepository,
    AudioService? audioService,
  })  : _quizRepository = quizRepository ?? BaseQuizRepository(),
        _audioService = audioService ?? AudioService();

  UiState<QuizQuestionModel> _uiState = const UiState.initial();
  QuizQuestionModel? _question;
  String? _selectedChoiceId;
  int _starsCount = 12;
  String _activeCategoryId = 'animals';
  DateTime? _questionStartTime;

  UiState<QuizQuestionModel> get uiState => _uiState;
  QuizQuestionModel? get question => _question;
  String? get selectedChoiceId => _selectedChoiceId;
  int get starsCount => _starsCount;
  String get activeCategoryId => _activeCategoryId;

  bool get isAnswered => _selectedChoiceId != null;
  bool get isCorrect =>
      _question != null && _selectedChoiceId == _question!.correctChoiceId;

  /// Loads quiz question for a given category.
  Future<void> loadQuizQuestion(String categoryId) async {
    _activeCategoryId = categoryId;
    _selectedChoiceId = null;
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final q = await _quizRepository.getQuizQuestionForCategory(categoryId);
      _question = q;
      _questionStartTime = DateTime.now();
      _uiState = UiState.success(q);
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load quiz question: $e'),
      );
    }
    notifyListeners();
  }

  /// Selects a choice, triggers gentle audio feedback, and records attempt.
  Future<void> selectChoice(String choiceId, {String sessionId = 'session_mock'}) async {
    if (_question == null) return;
    _selectedChoiceId = choiceId;
    final correct = choiceId == _question!.correctChoiceId;

    if (correct) {
      _starsCount++;
      await _audioService.playSuccessChime();
    } else {
      await _audioService.playGentleRetryChime();
    }

    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : null;

    final result = QuizResultModel(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      questionId: _question!.id,
      childResponse: choiceId,
      isCorrect: correct,
      responseTimeMs: responseTimeMs,
      timestamp: DateTime.now(),
    );

    try {
      await _quizRepository.recordQuizResult(result);
    } catch (e) {
      debugPrint('QuizProvider record attempt error: $e');
    }

    notifyListeners();
  }

  /// Resets the current question selection for another attempt.
  void resetSelection() {
    _selectedChoiceId = null;
    notifyListeners();
  }
}
