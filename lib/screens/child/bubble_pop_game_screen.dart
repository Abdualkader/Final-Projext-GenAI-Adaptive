import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/learning_session_model.dart';
import '../../models/quiz_result_model.dart';
import '../../models/vocabulary_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/session_repository.dart';
import '../../services/audio_service.dart';
import '../../widgets/large_icon_button.dart';
import '../../core/utils/responsive_layout.dart';

/// Interactive sensory-calm "Bubble Pop Learning" game designed for children with ASD.
/// Features gentle floating bubble animations, bilingual audio cues, Arabic calligraphy badges,
/// numbers 1..10, and non-punitive positive reinforcement.
class BubblePopGameScreen extends StatefulWidget {
  final String categoryId;
  final String? childId;
  final int totalRounds;
  final AudioService? audioService;
  final SessionRepository? sessionRepository;
  final QuizRepository? quizRepository;

  const BubblePopGameScreen({
    super.key,
    this.categoryId = 'letters',
    this.childId,
    this.totalRounds = 5,
    this.audioService,
    this.sessionRepository,
    this.quizRepository,
  });

  @override
  State<BubblePopGameScreen> createState() => _BubblePopGameScreenState();
}

class _BubblePopGameScreenState extends State<BubblePopGameScreen>
    with TickerProviderStateMixin {
  late final AudioService _audioService;
  late final SessionRepository _sessionRepository;
  late final QuizRepository _quizRepository;
  late final String _sessionId;
  late List<VocabularyItemModel> _pool;
  late AnimationController _floatAnimationController;

  int _currentRound = 0;
  int _starsCount = 0;
  bool _isCompleted = false;
  bool _sessionCreated = false;
  final List<String> _itemsPresented = [];

  VocabularyItemModel? _currentTarget;
  List<_BubbleItem> _currentBubbles = [];
  bool _isProcessingPop = false;

  String _getEffectiveChildId() {
    if (widget.childId != null && widget.childId!.isNotEmpty) {
      return widget.childId!;
    }
    try {
      final auth = Provider.of<AuthProvider?>(context, listen: false);
      if (auth?.selectedChild != null) {
        return auth!.selectedChild!.childId;
      }
    } catch (_) {}
    return 'child_adam';
  }

  @override
  void initState() {
    super.initState();
    _audioService = widget.audioService ?? AudioService();
    _sessionRepository = widget.sessionRepository ?? BaseSessionRepository();
    _quizRepository = widget.quizRepository ?? BaseQuizRepository();
    _sessionId = 'bubble_${DateTime.now().millisecondsSinceEpoch}';

    // Floating animation for bubbles (gentle, peaceful sine motion)
    _floatAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _initGame();
  }

  void _initGame() {
    if (widget.categoryId == 'all') {
      _pool = [
        ...MockDataRepository.getVocabularyForCategory('letters'),
        ...MockDataRepository.getVocabularyForCategory('numbers'),
        ...MockDataRepository.getVocabularyForCategory('animals'),
        ...MockDataRepository.getVocabularyForCategory('colours'),
      ];
    } else {
      _pool = MockDataRepository.getVocabularyForCategory(widget.categoryId);
      if (_pool.isEmpty) {
        _pool = MockDataRepository.getVocabularyForCategory('letters');
      }
    }
    _currentRound = 0;
    _starsCount = 0;
    _isCompleted = false;
    _setupRound();
  }

  void _setupRound() {
    if (_currentRound >= widget.totalRounds) {
      _finishGame();
      return;
    }

    final random = Random();
    final shuffled = List<VocabularyItemModel>.from(_pool)..shuffle(random);
    final target = shuffled.first;
    _currentTarget = target;
    _itemsPresented.add(target.id);

    if (!_sessionCreated) {
      _sessionCreated = true;
      _sessionRepository.createSession(
        LearningSessionModel(
          sessionId: _sessionId,
          childId: _getEffectiveChildId(),
          categoryId: widget.categoryId,
          startTime: DateTime.now(),
          itemsPresented: _itemsPresented,
          score: 0.0,
        ),
      );
    }

    // Pick 3 to 4 distractors
    final distractors = shuffled.skip(1).take(4).toList();
    final roundItems = [target, ...distractors]..shuffle(random);

    // Create bubble states with gentle floating offsets
    _currentBubbles = roundItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return _BubbleItem(
        id: '${item.id}_$index',
        item: item,
        isTarget: item.id == target.id,
        color: _getBubbleColor(item.id, index),
        floatOffset: (index % 2 == 0 ? 1.0 : -1.0) * (8 + (index * 4)),
      );
    }).toList();

    _isProcessingPop = false;

    // Play target speech automatically after brief pause
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakTargetPrompt();
      }
    });
  }

  void _speakTargetPrompt() {
    if (_currentTarget == null) return;
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final prompt = isArabic
        ? 'فرقع ${_currentTarget!.wordAr}!'
        : 'Pop ${_currentTarget!.wordEn}!';

    _audioService.speakText(
      prompt,
      language: isArabic ? 'ar' : 'en',
    );
  }

  void _onBubbleTapped(_BubbleItem bubble) {
    if (_isProcessingPop || _isCompleted) return;

    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    if (bubble.isTarget) {
      // Correct bubble popped!
      setState(() {
        _isProcessingPop = true;
        bubble.isPopped = true;
        _starsCount += 3;
      });

      _audioService.playSuccessChime();

      // Record quiz result so child progress reflects bubble pop achievements
      try {
        _quizRepository.recordQuizResult(
          QuizResultModel(
            resultId: 'bubble_res_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: _sessionId,
            childId: _getEffectiveChildId(),
            questionId: bubble.item.id,
            childResponse: bubble.item.id,
            isCorrect: true,
            timestamp: DateTime.now(),
            responseTimeMs: 3000,
          ),
        );
      } catch (_) {}

      final praise = isArabic ? 'رائع! أحسنت!' : 'Awesome! Great job!';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
          backgroundColor: const Color(0xFF10B981),
          content: Text(
            '🌟 $praise',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );

      // Transition to next round after pop effect
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentRound++;
            _setupRound();
          });
        }
      });
    } else {
      // Wrong bubble tapped: sensory-calm non-punitive gentle chime
      _audioService.playGentleRetryChime();

      setState(() {
        bubble.wobble = true;
      });

      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            bubble.wobble = false;
          });
        }
      });

      // Gently re-speak target
      final retryPrompt = isArabic
          ? 'حاول مرة أخرى! أين ${_currentTarget?.wordAr}؟'
          : 'Try again! Find ${_currentTarget?.wordEn}';
      _audioService.speakText(retryPrompt, language: isArabic ? 'ar' : 'en');
    }
  }

  void _finishGame() {
    setState(() {
      _isCompleted = true;
    });
    _audioService.playSuccessChime();

    final score = widget.totalRounds > 0
        ? (_starsCount / (widget.totalRounds * 3)).clamp(0.0, 1.0)
        : 1.0;

    _sessionRepository.completeSession(
      _sessionId,
      endTime: DateTime.now(),
      score: score,
    );
  }

  Color _getBubbleColor(String id, int index) {
    const palette = [
      Color(0xFF3B82F6), // Sky Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Warm Amber
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFF06B6D4), // Cyan
    ];
    return palette[(id.hashCode.abs() + index) % palette.length];
  }

  @override
  void dispose() {
    if (!_isCompleted && _sessionCreated) {
      final score = widget.totalRounds > 0
          ? (_starsCount / (widget.totalRounds * 3)).clamp(0.0, 1.0)
          : 0.5;
      _sessionRepository.completeSession(
        _sessionId,
        endTime: DateTime.now(),
        score: score,
      );
    }
    _floatAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: ResponsiveLayout(
          child: _isCompleted
              ? _buildCompletionView(l10n, isArabic)
              : _buildGameplayView(l10n, isArabic),
        ),
      ),
    );
  }

  Widget _buildGameplayView(AppLocalizations l10n, bool isArabic) {
    final targetLabel = isArabic
        ? (_currentTarget?.wordAr ?? '')
        : (_currentTarget?.wordEn ?? '');

    return Column(
      children: [
        const SizedBox(height: AppDimensions.spaceS),
        // Top Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LargeIconButton(
              icon: Icons.arrow_back_rounded,
              size: 48,
              onPressed: () => Navigator.pop(context),
            ),
            // Banner / Round Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Text(
                '🫧 ${isArabic ? "الجولة" : "Round"} ${_currentRound + 1} / ${widget.totalRounds}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Star counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 22, color: AppColors.starGold),
                  const SizedBox(width: 4),
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

        const SizedBox(height: AppDimensions.spaceS),

        // Hero Image Banner (generated with Nano Banana)
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: SizedBox(
            height: 90,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/bubble_banner.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF93C5FD), Color(0xFF6EE7B7)],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.18),
                ),
                Center(
                  child: Text(
                    isArabic ? '🫧 لعبة فرقعة الفقاعات الممتعة 🫧' : '🫧 Bubble Pop Learning 🫧',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spaceM),

        // Target Prompt Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              LargeIconButton(
                icon: Icons.volume_up_rounded,
                size: 46,
                backgroundColor: AppColors.primaryBlue,
                iconColor: Colors.white,
                onPressed: _speakTargetPrompt,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'المطلوب فرقعته:' : 'Target to pop:',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                      Row(
                        children: [
                          if (_currentTarget != null) ...[
                            _buildTargetThumbnail(_currentTarget!),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              '🫧 $targetLabel',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppDimensions.spaceM),

        // Floating Bubbles Area
        Expanded(
          child: AnimatedBuilder(
            animation: _floatAnimationController,
            builder: (context, child) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _currentBubbles.length,
                itemBuilder: (context, index) {
                  final bubble = _currentBubbles[index];
                  final floatVal = sin(_floatAnimationController.value * 2 * pi) *
                      bubble.floatOffset;

                  return Transform.translate(
                    offset: Offset(0, floatVal),
                    child: _buildBubbleWidget(bubble, isArabic),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: AppDimensions.spaceS),
      ],
    );
  }

  Widget _buildBubbleWidget(_BubbleItem bubble, bool isArabic) {
    if (bubble.isPopped) {
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.4),
          duration: const Duration(milliseconds: 400),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
            );
          },
        ),
      );
    }

    final item = bubble.item;
    final isLetter = widget.categoryId == 'letters' || _isLetterId(item.id);
    final isNumber = widget.categoryId == 'numbers' || _isNumberId(item.id);

    return AnimatedScale(
      scale: bubble.wobble ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBubbleTapped(bubble),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 0.9,
                colors: [
                  Colors.white.withOpacity(0.95),
                  bubble.color.withOpacity(0.25),
                  bubble.color.withOpacity(0.65),
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
              border: Border.all(
                color: bubble.color.withOpacity(0.8),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: bubble.color.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: isLetter
                  ? Text(
                      _getArabicLetterGlyph(item.id, item.wordAr),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: bubble.color,
                      ),
                    )
                  : isNumber
                      ? Text(
                          _getNumberDigit(item.id),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: bubble.color,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: _buildBubbleImageOrIcon(item, bubble.color),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isArabic ? item.wordAr : item.wordEn,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleImageOrIcon(VocabularyItemModel item, Color color) {
    String rawUrl = MockDataRepository.getImagePathForId(item.id);
    if (rawUrl.isEmpty) {
      rawUrl = item.imageUrl.trim();
    }
    if (rawUrl.isNotEmpty) {
      if (rawUrl.startsWith('assets/')) {
        return Image.asset(
          rawUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(_resolveItemIcon(item.id), size: 40, color: color),
        );
      } else if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        return Image.network(
          rawUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(_resolveItemIcon(item.id), size: 40, color: color),
        );
      }
    }
    return Icon(_resolveItemIcon(item.id), size: 40, color: color);
  }

  Widget _buildTargetThumbnail(VocabularyItemModel item) {
    String rawUrl = MockDataRepository.getImagePathForId(item.id);
    if (rawUrl.isEmpty) {
      rawUrl = item.imageUrl.trim();
    }
    if (rawUrl.isNotEmpty && rawUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          rawUrl,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCompletionView(AppLocalizations l10n, bool isArabic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Mascot star badge (Nano Banana generated)
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF59E0B), width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/quiz_star.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.star_rounded,
                size: 80,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spaceL),

        Text(
          isArabic ? '🎉 أحسنت صنعاً يا بطل! 🎉' : '🎉 Fantastic Job, Champion! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),
        Text(
          isArabic
              ? 'لقد فرقعت جميع الفقاعات التعليمية بنجاح!'
              : 'You popped all the educational bubbles successfully!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppDimensions.spaceL),

        // Stars score pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                '$_starsCount ${isArabic ? "نجمة ذهبية" : "Gold Stars"}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Replay & Home Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _initGame();
                    });
                  },
                  child: Text(
                    isArabic ? 'العب مجدداً 🔄' : 'Play Again 🔄',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isArabic ? 'العودة للرئيسية 🏠' : 'Home 🏠',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
    );
  }

  static bool _isLetterId(String id) {
    const letters = {
      'alif', 'alef', 'baa', 'taa', 'thaa', 'jeem', 'haa', 'khaa',
      'daal', 'thaal', 'raa', 'zaay', 'seen', 'sheen', 'saad', 'daad',
      'ttaa', 'zhaa', 'ayn', 'ghayn', 'faa', 'qaaf', 'kaaf', 'laam',
      'meem', 'noon', 'hhaa', 'waaw', 'yaa',
    };
    return letters.contains(id.toLowerCase());
  }

  static bool _isNumberId(String id) {
    const numbers = {
      'one', 'two', 'three', 'four', 'five',
      'six', 'seven', 'eight', 'nine', 'ten',
    };
    return numbers.contains(id.toLowerCase());
  }

  static String _getArabicLetterGlyph(String id, String wordAr) {
    const glyphMap = {
      'alif': 'أ', 'alef': 'أ', 'baa': 'ب', 'taa': 'ت', 'thaa': 'ث',
      'jeem': 'ج', 'haa': 'ح', 'khaa': 'خ', 'daal': 'د', 'thaal': 'ذ',
      'raa': 'ر', 'zaay': 'ز', 'seen': 'س', 'sheen': 'ش', 'saad': 'ص',
      'daad': 'ض', 'ttaa': 'ط', 'zhaa': 'ظ', 'ayn': 'ع', 'ghayn': 'غ',
      'faa': 'ف', 'qaaf': 'ق', 'kaaf': 'ك', 'laam': 'ل', 'meem': 'م',
      'noon': 'ن', 'hhaa': 'هـ', 'waaw': 'و', 'yaa': 'ي',
    };
    return glyphMap[id.toLowerCase()] ??
        (wordAr.isNotEmpty ? wordAr.substring(0, 1) : '🔤');
  }

  static String _getNumberDigit(String id) {
    const map = {
      'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
      'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    };
    return map[id.toLowerCase()] ?? '1';
  }

  static IconData _resolveItemIcon(String id) {
    switch (id.toLowerCase()) {
      case 'cat':
        return Icons.pets_rounded;
      case 'dog':
        return Icons.cruelty_free_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'cow':
        return Icons.agriculture_rounded;
      case 'lion':
        return Icons.shield_rounded;
      case 'elephant':
        return Icons.landscape_rounded;
      default:
        return Icons.palette_rounded;
    }
  }
}

class _BubbleItem {
  final String id;
  final VocabularyItemModel item;
  final bool isTarget;
  final Color color;
  final double floatOffset;
  bool isPopped;
  bool wobble;

  _BubbleItem({
    required this.id,
    required this.item,
    required this.isTarget,
    required this.color,
    required this.floatOffset,
    this.isPopped = false,
    this.wobble = false,
  });
}
