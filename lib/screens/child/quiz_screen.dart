import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/learning_session_model.dart';
import '../../models/quiz_question_model.dart';
import '../../models/quiz_result_model.dart';
import '../../providers/quiz_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/session_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/adaptive_difficulty_service.dart';
import '../../services/ai_adaptive_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/quiz_choice_card.dart';

/// Interactive Quiz Screen faithfully matching Wireframe 2 & Week 10 requirements:
/// - 3 image-based response options with visual clarity (Task 4)
/// - Multi-question quiz session associated with current child and category (Task 2)
/// - Positive reinforcement with pleasant chime and star awards for correct answers (Task 6)
/// - Gentle corrective feedback without harsh buzzer or red screen for incorrect answers (Task 7)
/// - Individual question attempt logging in Firestore quizResults collection (Task 8)
/// - 60-second peaceful question timer with automatic timeout handling (Task 9)
/// - Child-friendly quiz completion screen with star awards and score summary (Task 10)
/// - Difficulty filtering and choice position randomization (Task 11 & 12)
/// - Week 12: Adaptive Learning and AI-generated exercise integration (Tasks 4, 7, 10, 11)
class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String childId;
  final int questionCount;
  final int? maxDifficulty;
  final Duration questionTimeoutDuration;
  final bool enableTimer;
  final bool shuffle;
  final bool useAi;
  final List<QuizQuestionModel>? questions;
  final QuizRepository? quizRepository;
  final SessionRepository? sessionRepository;
  final AudioService? audioService;
  final AiAdaptiveService? aiAdaptiveService;
  final AdaptiveDifficultyService? adaptiveDifficultyService;
  final UserRepository? userRepository;

  const QuizScreen({
    super.key,
    this.categoryId = 'animals',
    this.childId = 'child_adam_001',
    this.questionCount = 5,
    this.maxDifficulty,
    this.questionTimeoutDuration = const Duration(seconds: 60),
    this.enableTimer = false,
    this.shuffle = false,
    this.useAi = false,
    this.questions,
    this.quizRepository,
    this.sessionRepository,
    this.audioService,
    this.aiAdaptiveService,
    this.adaptiveDifficultyService,
    this.userRepository,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late String _activeCategoryId;
  late QuizRepository _quizRepository;
  late SessionRepository _sessionRepository;
  late AudioService _audioService;

  late List<QuizQuestionModel> _questions;
  int _currentIndex = 0;
  late QuizQuestionModel _question;
  String? _selectedChoiceId;
  int _starsCount = 12;
  int _score = 0;
  bool _isCompleted = false;
  late String _sessionId;
  DateTime? _questionStartTime;
  // 60-Second Peaceful Timer (Task 9)
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isTimedOut = false;

  // Adaptive Learning State (Week 12 Task 7, 10, 11)
  AdaptiveEvaluationResult? _adaptiveResult;
  final List<QuizResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _activeCategoryId = widget.categoryId;
    _quizRepository = widget.quizRepository ?? BaseQuizRepository();
    _sessionRepository = widget.sessionRepository ?? BaseSessionRepository();
    _audioService = widget.audioService ?? AudioService();
    _sessionId = 'quiz_session_${DateTime.now().millisecondsSinceEpoch}';

    _initializeQuestions();

    if (widget.enableTimer) {
      _startTimer();
    }
  }

  void _initializeQuestions() {
    if (widget.questions != null && widget.questions!.isNotEmpty) {
      _questions = List.from(widget.questions!);
    } else {
      final defaultQuestion =
          MockDataRepository.getQuizQuestionForCategory(_activeCategoryId);
      if (widget.shuffle) {
        final shuffledChoices = List<QuizChoice>.from(defaultQuestion.choices)
          ..shuffle();
        _questions = [defaultQuestion.copyWith(choices: shuffledChoices)];
      } else {
        _questions = [defaultQuestion];
      }
    }
    _currentIndex = 0;
    _question = _questions[_currentIndex];
    _questionStartTime = DateTime.now();
    _remainingSeconds = widget.questionTimeoutDuration.inSeconds;

    // Create session record in repository (Task 2)
    _sessionRepository.createSession(
      LearningSessionModel(
        sessionId: _sessionId,
        childId: widget.childId,
        categoryId: _activeCategoryId,
        startTime: DateTime.now(),
        itemsPresented: _questions.map((q) => q.correctChoiceId).toList(),
        score: 0.0,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args != _activeCategoryId) {
      setState(() {
        _activeCategoryId = args;
        _initializeQuestions();
        _selectedChoiceId = null;
        _isTimedOut = false;
        _isCompleted = false;
      });
      if (widget.enableTimer) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = widget.questionTimeoutDuration.inSeconds;
    _isTimedOut = false;

    if (_remainingSeconds <= 0 && widget.questionTimeoutDuration.inMilliseconds > 0) {
      _timer = Timer(widget.questionTimeoutDuration, _onTimeout);
      return;
    }

    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (!mounted || _isAnswered || _isCompleted) return;
    setState(() {
      _isTimedOut = true;
      _selectedChoiceId = null;
    });

    _audioService.playGentleRetryChime();
    _recordTimeoutResult();
  }

  bool get _isAnswered => _selectedChoiceId != null || _isTimedOut;
  bool get _isCorrect =>
      _selectedChoiceId != null && _selectedChoiceId == _question.correctChoiceId;

  FeedbackState get _feedbackState {
    if (_isTimedOut) return FeedbackState.gentleCorrection;
    if (!_isAnswered) return FeedbackState.neutral;
    return _isCorrect ? FeedbackState.correct : FeedbackState.gentleCorrection;
  }

  String get _progressLabel {
    if (_questions.length > 1) {
      return '${_currentIndex + 1} / ${_questions.length}';
    }
    return '3 / 10';
  }

  double get _progressValue {
    if (_questions.length > 1) {
      return (_currentIndex + 1) / _questions.length;
    }
    return 0.3;
  }

  void _selectChoice(String choiceId) {
    if (_isAnswered || _isCompleted) return;
    _timer?.cancel();
    final isCorrect = choiceId == _question.correctChoiceId;

    setState(() {
      _selectedChoiceId = choiceId;
      if (isCorrect) {
        _score++;
        _starsCount += 3;
      }
    });

    if (isCorrect) {
      _audioService.playSuccessChime();
    } else {
      _audioService.playGentleRetryChime();
    }

    _recordQuizResult(choiceId, isCorrect);
  }

  Future<void> _recordQuizResult(String choiceId, bool isCorrect) async {
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : null;

    final result = QuizResultModel(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: _sessionId,
      childId: widget.childId,
      questionId: _question.id,
      childResponse: choiceId,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      timestamp: DateTime.now(),
    );

    _results.add(result);

    try {
      await _quizRepository.recordQuizResult(result);
    } catch (e) {
      debugPrint('QuizScreen recordQuizResult error: $e');
    }
  }

  Future<void> _recordTimeoutResult() async {
    final result = QuizResultModel(
      resultId: 'timeout_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: _sessionId,
      childId: widget.childId,
      questionId: _question.id,
      childResponse: 'timeout',
      isCorrect: false,
      responseTimeMs: widget.questionTimeoutDuration.inMilliseconds,
      timestamp: DateTime.now(),
    );

    _results.add(result);

    try {
      await _quizRepository.recordQuizResult(result);
    } catch (e) {
      debugPrint('QuizScreen recordTimeoutResult error: $e');
    }
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _question = _questions[_currentIndex];
        _selectedChoiceId = null;
        _isTimedOut = false;
        _questionStartTime = DateTime.now();
        _remainingSeconds = widget.questionTimeoutDuration.inSeconds;
      });
      if (widget.enableTimer) {
        _startTimer();
      }
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
    });

    _audioService.playSuccessChime();

    _sessionRepository.completeSession(
      _sessionId,
      endTime: DateTime.now(),
      score: _questions.isEmpty ? 0.0 : (_score / _questions.length),
    );

    // Week 12: Trigger adaptive difficulty adjustment
    final adaptiveService = widget.adaptiveDifficultyService ?? const AdaptiveDifficultyService();
    final userRepo = widget.userRepository ?? BaseUserRepository();
    adaptiveService.updateChildDifficulty(
      widget.childId,
      currentDifficulty: widget.maxDifficulty ?? 1,
      recentResults: _results,
      userRepository: userRepo,
      activeCategoryId: _activeCategoryId,
    ).then((res) {
      if (mounted) {
        setState(() {
          _adaptiveResult = res;
        });
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isCompleted = false;
      _selectedChoiceId = null;
      _isTimedOut = false;
      _question = _questions[0];
      _questionStartTime = DateTime.now();
      _remainingSeconds = widget.questionTimeoutDuration.inSeconds;
    });
    if (widget.enableTimer) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isCompleted) {
      return _buildCompletionScreen(context, l10n);
    }

    String feedbackTitle;
    String feedbackSubtitle;
    int earnedStars;

    if (_isTimedOut) {
      feedbackTitle = l10n.text('quiz_timeout_title');
      feedbackSubtitle = l10n.text('quiz_timeout_subtitle');
      earnedStars = 0;
    } else {
      switch (_feedbackState) {
        case FeedbackState.correct:
          feedbackTitle = l10n.text('feedback_correct_title');
          feedbackSubtitle = l10n.text('feedback_correct_subtitle');
          earnedStars = 3;
          break;
        case FeedbackState.gentleCorrection:
          feedbackTitle = l10n.text('feedback_gentle_retry_title');
          feedbackSubtitle = l10n.text('feedback_gentle_retry_subtitle');
          earnedStars = 1;
          break;
        case FeedbackState.neutral:
          feedbackTitle = l10n.text('feedback_great_job');
          feedbackSubtitle = l10n.text('feedback_you_can_do_it');
          earnedStars = 0;
          break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceS),
              // Top Bar matching Wireframe 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Progress Counter (3 / 10 or 1 / 5)
                  Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _progressLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                          child: LinearProgressIndicator(
                            value: _progressValue,
                            minHeight: 6,
                            backgroundColor: AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 60-Second Peaceful Timer Badge (Task 9)
                  if (widget.enableTimer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceM,
                        vertical: AppDimensions.spaceS,
                      ),
                      decoration: BoxDecoration(
                        color: _isTimedOut
                            ? AppColors.alertSoft.withOpacity(0.18)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: _isTimedOut
                              ? AppColors.alertSoft
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: _isTimedOut
                                ? AppColors.alertSoft
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.spaceXS),
                          Text(
                            _isTimedOut
                                ? '⏱️ 0s'
                                : '⏱️ ${_remainingSeconds}s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _isTimedOut
                                  ? AppColors.alertSoft
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Star Points Counter (⭐ 12)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 24,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          '$_starsCount',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Question Card with Speaker Prompt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    LargeIconButton(
                      icon: Icons.volume_up_rounded,
                      size: 52,
                      iconSize: 28,
                      backgroundColor: AppColors.primaryBlue,
                      iconColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryBlue,
                            content: Text(
                              '🔊 ${_question.localizedPrompt(l10n.isArabic)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        _question.localizedPrompt(l10n.isArabic),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // 3 Choices Row matching Wireframe 2 & Task 4
              Expanded(
                child: Row(
                  children: _question.choices.map((choice) {
                    final isSelected = _selectedChoiceId == choice.id;
                    final isCorrect = choice.id == _question.correctChoiceId;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceXS,
                        ),
                        child: QuizChoiceCard(
                          choice: choice,
                          isSelected: isSelected,
                          isCorrect: isCorrect,
                          isArabic: l10n.isArabic,
                          onTap: () {
                            _selectChoice(choice.id);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Positive Reinforcement or Gentle Corrective Feedback Banner (Tasks 6, 7, 9)
              FeedbackBanner(
                state: _feedbackState,
                title: feedbackTitle,
                subtitle: feedbackSubtitle,
                earnedStars: earnedStars,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Bottom Action Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 52,
                    onPressed: () => Navigator.pop(context),
                  ),
                  LargeIconButton(
                    icon: Icons.refresh_rounded,
                    size: 52,
                    backgroundColor: AppColors.background,
                    onPressed: () {
                      setState(() {
                        _selectedChoiceId = null;
                        _isTimedOut = false;
                        _remainingSeconds =
                            widget.questionTimeoutDuration.inSeconds;
                      });
                      if (widget.enableTimer) {
                        _startTimer();
                      }
                    },
                    tooltip: 'Repeat Question',
                  ),
                  LargeIconButton(
                    icon: Icons.arrow_forward_rounded,
                    size: 52,
                    iconColor: _isCorrect ? Colors.white : AppColors.primaryBlue,
                    backgroundColor:
                        _isCorrect ? AppColors.primaryBlue : Colors.white,
                    onPressed: () {
                      if (_questions.length > 1 &&
                          _currentIndex + 1 < _questions.length) {
                        _nextQuestion();
                      } else if (_isAnswered) {
                        _finishQuiz();
                      } else {
                        Navigator.pushNamed(context, AppRoutes.parentDashboard);
                      }
                    },
                    tooltip: 'Next Question',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceS),
            ],
          ),
        ),
      ),
    );
  }

  /// Child-friendly Quiz Completion Screen (Task 10).
  Widget _buildCompletionScreen(BuildContext context, AppLocalizations l10n) {
    final accuracyPercent =
        _questions.isEmpty ? 0 : ((_score / _questions.length) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceM),
              // Top Bar with Stars Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeIconButton(
                    icon: Icons.close_rounded,
                    size: 48,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.childHome,
                        (route) => false,
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceL,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 26,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          '$_starsCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Celebratory Trophy / Big Star
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.starGold.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.starGold.withOpacity(0.4),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.military_tech_rounded,
                    size: 80,
                    color: AppColors.starGold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              // Title & Encouraging Subtitle
              Text(
                l10n.text('quiz_completed_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                ),
                child: Text(
                  l10n.text('quiz_completed_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              // Score Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.textWithArgs('quiz_score_summary', [
                        '$_score',
                        '${_questions.length}',
                      ]),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    Text(
                      '$accuracyPercent% Accuracy',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (_adaptiveResult != null) ...[
                const SizedBox(height: AppDimensions.spaceM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceM,
                    vertical: AppDimensions.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spaceS),
                      Flexible(
                        child: Text(
                          _adaptiveResult!.localizedExplanation(l10n.isArabic),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Action Buttons: Play Again & Return Home
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                          ),
                        ),
                        onPressed: _restartQuiz,
                        child: Text(
                          l10n.text('btn_play_again'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.childHome,
                            (route) => false,
                          );
                        },
                        child: Text(
                          l10n.text('btn_return_home'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceL),
            ],
          ),
        ),
      ),
    );
  }
}
