import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/learning_session_model.dart';
import '../../models/matching_game_model.dart';
import '../../models/quiz_result_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/session_repository.dart';
import '../../services/ai_adaptive_service.dart';
import '../../services/audio_service.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/large_icon_button.dart';

/// Interactive AI-Generated Matching Game Screen for children with Autism Spectrum Disorder (ASD).
/// Sensory-safe design with calm pastel tones, soft chime audio feedback, and step-by-step pairing.
class MatchingGameScreen extends StatefulWidget {
  final String categoryId;
  final String childId;
  final int? difficultyLevel;
  final AiAdaptiveService? aiAdaptiveService;
  final SessionRepository? sessionRepository;
  final QuizRepository? quizRepository;
  final AudioService? audioService;

  const MatchingGameScreen({
    super.key,
    this.categoryId = 'animals',
    this.childId = 'child_adam_001',
    this.difficultyLevel,
    this.aiAdaptiveService,
    this.sessionRepository,
    this.quizRepository,
    this.audioService,
  });

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late AiAdaptiveService _aiAdaptiveService;
  late SessionRepository _sessionRepository;
  late QuizRepository _quizRepository;
  late AudioService _audioService;

  MatchingGameRound? _round;
  bool _isLoading = true;
  String? _firstSelectedCardId;
  int _starsCount = 12;
  int _movesCount = 0;
  bool _isLockingInput = false;
  late String _sessionId;
  DateTime? _gameStartTime;

  @override
  void initState() {
    super.initState();
    _aiAdaptiveService = widget.aiAdaptiveService ?? BaseAiAdaptiveService();
    _sessionRepository = widget.sessionRepository ?? BaseSessionRepository();
    _quizRepository = widget.quizRepository ?? BaseQuizRepository();
    _audioService = widget.audioService ?? AudioService();
    _sessionId = 'match_game_${DateTime.now().millisecondsSinceEpoch}';

    _startNewGameRound();
  }

  @override
  void dispose() {
    if (_round != null && !_round!.isCompleted && _round!.matchedPairsCount > 0) {
      final score = (_round!.matchedPairsCount / _round!.totalPairs).clamp(0.1, 1.0);
      _sessionRepository.completeSession(
        _sessionId,
        endTime: DateTime.now(),
        score: score,
      );
    }
    super.dispose();
  }

  Future<void> _startNewGameRound() async {
    setState(() {
      _isLoading = true;
      _firstSelectedCardId = null;
      _isLockingInput = false;
      _movesCount = 0;
    });

    final auth = Provider.of<AuthProvider?>(context, listen: false);
    final effectiveDiff = widget.difficultyLevel ??
        auth?.selectedChild?.currentDifficultyLevel ??
        1;
    final effectiveChildId = (widget.childId == 'child_adam_001' && auth?.selectedChild != null)
        ? auth!.selectedChild!.childId
        : widget.childId;

    try {
      final round = await _aiAdaptiveService.generateMatchingGameRound(
        categoryId: widget.categoryId,
        difficultyLevel: effectiveDiff,
        preferredLanguage: 'ar',
      );

      if (mounted) {
        setState(() {
          _round = round;
          _isLoading = false;
          _gameStartTime = DateTime.now();
        });

        // Record session start for active child
        _sessionRepository.createSession(
          LearningSessionModel(
            sessionId: _sessionId,
            childId: effectiveChildId,
            categoryId: widget.categoryId,
            startTime: _gameStartTime!,
            itemsPresented: round.cards.map((c) => c.pairId).toSet().toList(),
            score: 0.0,
          ),
        );
      }
    } catch (e) {
      debugPrint('MatchingGameScreen error generating round: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCardTapped(MatchingCard card) {
    if (_isLockingInput || card.isMatched || card.isFaceUp || _round == null) {
      return;
    }

    // Step 1: Flip this card face up
    final updatedCards = _round!.cards.map((c) {
      if (c.id == card.id) {
        return c.copyWith(isFaceUp: true);
      }
      return c;
    }).toList();

    setState(() {
      _round = _round!.copyWith(cards: updatedCards);
    });

    // Speak word on card tap for gentle multi-sensory reinforcement
    final isAr = AppLocalizations.of(context).isArabic;
    _audioService.speakText(card.localizedLabel(isAr), language: isAr ? 'ar' : 'en');

    if (_firstSelectedCardId == null) {
      // First card of pair selected
      _firstSelectedCardId = card.id;
    } else {
      // Second card selected -> evaluate match!
      final firstCard = _round!.cards.firstWhere((c) => c.id == _firstSelectedCardId);
      final isMatch = firstCard.pairId == card.pairId && firstCard.id != card.id;
      _movesCount++;

      if (isMatch) {
        // Successful Match!
        _audioService.playSuccessChime();

        // Record quiz result for progress tracking
        final auth = Provider.of<AuthProvider?>(context, listen: false);
        final effectiveChildId = (widget.childId == 'child_adam_001' && auth?.selectedChild != null)
            ? auth!.selectedChild!.childId
            : widget.childId;
        _quizRepository.recordQuizResult(
          QuizResultModel(
            resultId: 'match_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: _sessionId,
            childId: effectiveChildId,
            questionId: card.pairId,
            childResponse: card.pairId,
            isCorrect: true,
            responseTimeMs: 1500,
            timestamp: DateTime.now(),
          ),
        );

        setState(() {
          _starsCount += 2;
          final matchedCards = _round!.cards.map((c) {
            if (c.id == firstCard.id || c.id == card.id) {
              return c.copyWith(isMatched: true, isFaceUp: true);
            }
            return c;
          }).toList();
          _round = _round!.copyWith(cards: matchedCards);
          _firstSelectedCardId = null;
        });

        // Check if all matched
        if (_round!.isCompleted) {
          _onGameCompleted();
        }
      } else {
        // Non-punitive Mismatch: Gentle retry chime and flip back smoothly
        _audioService.playGentleRetryChime();
        _isLockingInput = true;

        Timer(const Duration(milliseconds: 900), () {
          if (!mounted || _round == null) return;
          setState(() {
            final resetCards = _round!.cards.map((c) {
              if (c.id == firstCard.id || c.id == card.id) {
                return c.copyWith(isFaceUp: false);
              }
              return c;
            }).toList();
            _round = _round!.copyWith(cards: resetCards);
            _firstSelectedCardId = null;
            _isLockingInput = false;
          });
        });
      }
    }
  }

  void _onGameCompleted() {
    _audioService.playSuccessChime();

    final durationSeconds = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 30;

    _sessionRepository.completeSession(
      _sessionId,
      endTime: DateTime.now(),
      score: 1.0,
    );

    // Show peaceful completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildCompletionDialog(ctx),
    );
  }

  Widget _buildCompletionDialog(BuildContext dialogContext) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gentle Star Celebration Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.starBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.starGold, width: 2),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 44,
                color: AppColors.starGold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              isArabic ? 'ممتاز يا بطل! 🌟' : 'Super Match! 🌟',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              isArabic
                  ? 'لقد نجحت في مطابقة جميع البطاقات بذكاء!'
                  : 'You matched all the pairs wonderfully!',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.starGold, size: 28),
                const SizedBox(width: 8),
                Text(
                  '${_round?.totalPairs ?? 0} ${isArabic ? 'أزواج متطابقة' : 'Pairs Matched'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: isArabic ? 'الرئيسية' : 'Home',
                    icon: Icons.home_rounded,
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: AppButton(
                    label: isArabic ? 'العب ثانية' : 'Play Again',
                    icon: Icons.replay_rounded,
                    backgroundColor: const Color(0xFF10B981),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _startNewGameRound();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceS),
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 48,
                    tooltip: l10n.text('back'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isArabic ? 'لعبة المطابقة الذكية 🎮' : 'AI Match Game 🎮',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildStarDisplay(_starsCount),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Peaceful Instruction Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        color: AppColors.primaryBlue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        isArabic
                            ? (_round?.promptAr ?? 'المس البطاقات لتطابق كل صورة بكلمتها!')
                            : (_round?.promptEn ?? 'Tap cards to match each picture with its word!'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // Game Grid or Loading State
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: AppDimensions.spaceL),
                            Text(
                              isArabic
                                  ? 'الذكاء الاصطناعي يجهز بطاقات اللعبة... 🌟'
                                  : 'AI is preparing your matching cards... 🌟',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_round == null || _round!.cards.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.sentiment_neutral_rounded,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: AppDimensions.spaceM),
                                Text(
                                  isArabic ? 'لم نتمكن من تجهيز اللعبة' : 'Could not prepare game',
                                  style: const TextStyle(color: AppColors.textMuted),
                                ),
                                const SizedBox(height: AppDimensions.spaceM),
                                AppButton(
                                  label: isArabic ? 'إعادة المحاولة' : 'Retry',
                                  onPressed: _startNewGameRound,
                                ),
                              ],
                            ),
                          )
                        : _buildCardGrid(isArabic),
              ),
              const SizedBox(height: AppDimensions.spaceM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrid(bool isArabic) {
    final cards = _round!.cards;
    final int crossAxisCount = cards.length <= 4 ? 2 : (cards.length <= 6 ? 3 : 4);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.spaceM,
        mainAxisSpacing: AppDimensions.spaceM,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = _firstSelectedCardId == card.id;

        return _buildMatchingCardWidget(card, isSelected, isArabic);
      },
    );
  }

  Widget _buildMatchingCardWidget(
    MatchingCard card,
    bool isSelected,
    bool isArabic,
  ) {
    final showFront = card.isFaceUp || card.isMatched;

    Color borderColor = Colors.transparent;
    if (card.isMatched) {
      borderColor = const Color(0xFF10B981); // Calming green for matched
    } else if (isSelected) {
      borderColor = AppColors.primaryBlue; // Soft blue for currently selected
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: showFront
            ? (card.isMatched
                ? const Color(0xFF10B981).withOpacity(0.12)
                : Colors.white)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: borderColor,
          width: card.isMatched || isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          onTap: () => _onCardTapped(card),
          child: Padding(
            padding: (showFront && card.isImage)
                ? EdgeInsets.zero
                : const EdgeInsets.all(AppDimensions.spaceM),
            child: showFront
                ? _buildCardFront(card, isArabic)
                : _buildCardBack(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(MatchingCard card, bool isArabic) {
    if (card.isImage) {
      // 1. Prioritize real photo asset from MockDataRepository using pairId
      String rawUrl = MockDataRepository.getImagePathForId(card.pairId);
      if (rawUrl.isEmpty) {
        rawUrl = card.imageUrl.trim();
      }

      Widget imageVisual;
      if (rawUrl.isNotEmpty) {
        if (rawUrl.startsWith('assets/')) {
          imageVisual = Image.asset(
            rawUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(card),
          );
        } else if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
          imageVisual = Image.network(
            rawUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(card),
          );
        } else {
          imageVisual = _buildFallbackIcon(card);
        }
      } else {
        imageVisual = _buildFallbackIcon(card);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL - 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageVisual,
            if (card.isMatched)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 26,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      // Bilingual Word Card
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.wordAr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          Text(
            card.wordEn,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          if (card.isMatched) ...[
            const SizedBox(height: 6),
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
          ],
        ],
      );
    }
  }

  Widget _buildFallbackIcon(MatchingCard card) {
    return Container(
      color: card.accentColor.withOpacity(0.08),
      child: Center(
        child: Icon(
          card.icon,
          size: 56,
          color: card.accentColor,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.star_rounded,
          size: 28,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStarDisplay(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.starBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.starGold.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.starGold, size: 22),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
