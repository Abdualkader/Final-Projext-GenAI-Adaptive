import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/vocabulary_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/learning_session_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../services/audio_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/vocabulary_card.dart';

/// Complete Vocabulary Learning Screen conforming to Week 9 requirements:
/// - Category vocabulary loading and session creation in Cloud Firestore (Task 2 & 8)
/// - Prominent sensory-friendly image presentation with fallbacks (Task 4)
/// - Dynamic bilingual RTL/LTR labels with Harakat & active language emphasis (Task 5)
/// - Audio interaction with debouncing and safe error handling (Task 6)
/// - Clear item navigation and "Complete Session" action (Task 7)
/// - Inactivity audio reminder after 30 seconds of inactivity (Task 9)
/// - Session completion with positive reinforcement and quiz readiness (Task 10 & 11)
/// - Child-friendly Loading, Success, Empty, Error, and Completed states (Task 12)
class VocabularyLearningScreen extends StatefulWidget {
  final String categoryId;
  final Duration inactivityDuration;

  const VocabularyLearningScreen({
    super.key,
    this.categoryId = 'animals',
    this.inactivityDuration = const Duration(seconds: 30),
  });

  @override
  State<VocabularyLearningScreen> createState() =>
      _VocabularyLearningScreenState();
}

class _VocabularyLearningScreenState extends State<VocabularyLearningScreen> {
  int _currentIndex = 0;
  late String _activeCategoryId;
  late List<VocabularyItemModel> _items;

  // Week 9 State Management & Inactivity Tracker
  Timer? _inactivityTimer;
  bool _showInactivityReminder = false;
  bool _isCompleted = false;
  DateTime? _lastAudioTapTime;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _activeCategoryId = widget.categoryId;
    _items = MockDataRepository.getVocabularyForCategory(_activeCategoryId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVocabularyAndStartSession();
    });

    _resetInactivityTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args != _activeCategoryId) {
      setState(() {
        _activeCategoryId = args;
        _items = MockDataRepository.getVocabularyForCategory(_activeCategoryId);
        _currentIndex = 0;
        _isCompleted = false;
        _sessionStarted = false;
      });
      _loadVocabularyAndStartSession();
      _resetInactivityTimer();
    }
  }

  @override
  void didUpdateWidget(VocabularyLearningScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      setState(() {
        _activeCategoryId = widget.categoryId;
        _items = MockDataRepository.getVocabularyForCategory(_activeCategoryId);
        _currentIndex = 0;
        _isCompleted = false;
        _sessionStarted = false;
      });
      _loadVocabularyAndStartSession();
      _resetInactivityTimer();
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  /// Initializes vocabulary loading and Firestore learning session (Tasks 2 & 8).
  void _loadVocabularyAndStartSession() {
    final vocabProvider =
        Provider.of<VocabularyProvider?>(context, listen: false);
    if (vocabProvider != null) {
      vocabProvider.loadVocabulary(_activeCategoryId).then((_) {
        if (!mounted) return;
        final sessionProvider =
            Provider.of<LearningSessionProvider?>(context, listen: false);
        final items = _getActiveItems(vocabProvider);
        if (sessionProvider != null && items.isNotEmpty && _currentIndex < items.length) {
          sessionProvider.recordItemPresented(items[_currentIndex].id);
        }
      });
    }

    if (!_sessionStarted) {
      _sessionStarted = true;
      final sessionProvider =
          Provider.of<LearningSessionProvider?>(context, listen: false);
      final authProvider =
          Provider.of<AuthProvider?>(context, listen: false);

      final childId = authProvider?.selectedChild?.childId ??
          authProvider?.currentUser?.linkedChildIds.firstOrNull ??
          'child_adam_001';

      if (sessionProvider != null) {
        sessionProvider.startSession(childId, _activeCategoryId);
        final items = _getActiveItems(vocabProvider);
        if (items.isNotEmpty && _currentIndex < items.length) {
          sessionProvider.recordItemPresented(items[_currentIndex].id);
        }
      }
    }
  }

  /// Resets the 30-second inactivity reminder timer on any child interaction (Task 9).
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_showInactivityReminder) {
      setState(() {
        _showInactivityReminder = false;
      });
    }

    if (!_isCompleted) {
      _inactivityTimer = Timer(widget.inactivityDuration, _onInactivityTimerFired);
    }
  }

  /// Handles 30-second inactivity by gently suggesting audio replay (Task 9).
  void _onInactivityTimerFired() {
    if (!mounted || _isCompleted) return;

    setState(() {
      _showInactivityReminder = true;
    });

    // Gentle non-alarming audio replay prompt
    final vocabProvider =
        Provider.of<VocabularyProvider?>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final activeItems = _getActiveItems(vocabProvider);
    if (activeItems.isNotEmpty && _currentIndex < activeItems.length) {
      final currentItem = activeItems[_currentIndex];
      vocabProvider?.playAudioFor(currentItem, isArabic: l10n.isArabic);
    }
  }

  List<VocabularyItemModel> _getActiveItems(VocabularyProvider? vocabProvider) {
    final bool hasProvider = vocabProvider != null;
    final bool isProviderForActiveCategory = hasProvider &&
        (vocabProvider.currentCategoryId == _activeCategoryId ||
            (vocabProvider.currentCategoryId == 'colours' &&
                _activeCategoryId == 'colors') ||
            (vocabProvider.currentCategoryId == 'colors' &&
                _activeCategoryId == 'colours'));

    if (isProviderForActiveCategory) {
      if (vocabProvider.uiState.isEmpty) return [];
      if (vocabProvider.items.isNotEmpty) return vocabProvider.items;
    }

    return _items;
  }

  /// Plays audio with debounce to avoid rapid double-tap instability (Task 6).
  Future<void> _playAudioSafe(
    VocabularyItemModel item, {
    required bool isArabic,
    required VocabularyProvider? vocabProvider,
  }) async {
    final now = DateTime.now();
    if (_lastAudioTapTime != null &&
        now.difference(_lastAudioTapTime!).inMilliseconds < 450) {
      return; // Ignore rapid repeated taps
    }
    _lastAudioTapTime = now;
    _resetInactivityTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white),
              const SizedBox(width: AppDimensions.spaceM),
              Text(
                '🔊 ${item.wordEn} • ${item.wordAr}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vocabProvider != null) {
      await vocabProvider.playAudioFor(item, isArabic: isArabic);
    }
  }

  /// Completes session, records telemetry to Firestore, and presents celebration view (Task 10 & 11).
  Future<void> _completeSession(List<VocabularyItemModel> items) async {
    _inactivityTimer?.cancel();

    final sessionProvider =
        Provider.of<LearningSessionProvider?>(context, listen: false);
    if (sessionProvider != null) {
      for (final item in items) {
        sessionProvider.recordItemPresented(item.id);
      }
      await sessionProvider.endSession(score: 1.0);
    }

    try {
      await AudioService().playSuccessChime();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  String _getCategoryTitle(AppLocalizations l10n, CategoryProvider? catProvider) {
    if (catProvider != null && catProvider.categories.isNotEmpty) {
      try {
        final searchIds =
            (_activeCategoryId == 'colors' || _activeCategoryId == 'colours')
                ? ['colours', 'colors']
                : [_activeCategoryId];
        final cat = catProvider.categories.firstWhere(
          (c) => searchIds.contains(c.id),
        );
        return cat.localizedName(l10n.isArabic);
      } catch (_) {}
    }

    switch (_activeCategoryId) {
      case 'letters':
        return l10n.text('category_letters');
      case 'numbers':
        return l10n.text('category_numbers');
      case 'colours':
      case 'colors':
        return l10n.text('category_colours');
      case 'animals':
      default:
        return l10n.text('category_animals');
    }
  }

  IconData _getCategoryIcon() {
    switch (_activeCategoryId) {
      case 'letters':
        return Icons.spellcheck_rounded;
      case 'numbers':
        return Icons.looks_one_rounded;
      case 'colours':
      case 'colors':
        return Icons.palette_rounded;
      case 'animals':
      default:
        return Icons.pets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vocabProvider =
        Provider.of<VocabularyProvider?>(context, listen: true);
    final catProvider =
        Provider.of<CategoryProvider?>(context, listen: false);
    final sessionProvider =
        Provider.of<LearningSessionProvider?>(context, listen: false);

    final activeItems = _getActiveItems(vocabProvider);

    // 1. COMPLETED STATE (Task 10 & 11)
    if (_isCompleted) {
      return _buildCompletedView(context, l10n, catProvider, activeItems);
    }

    // Determine async UI state from provider
    final bool hasProvider = vocabProvider != null;
    final bool isProviderForActiveCategory = hasProvider &&
        (vocabProvider.currentCategoryId == _activeCategoryId ||
            (vocabProvider.currentCategoryId == 'colours' &&
                _activeCategoryId == 'colors') ||
            (vocabProvider.currentCategoryId == 'colors' &&
                _activeCategoryId == 'colours'));

    // 2. LOADING STATE (Task 12)
    if (hasProvider && isProviderForActiveCategory && vocabProvider.uiState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(
          child: LoadingWidget(),
        ),
      );
    }

    // 3. ERROR STATE (Task 12)
    if (hasProvider && isProviderForActiveCategory && vocabProvider.uiState.isError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AppErrorWidget(
            message: vocabProvider.uiState
                .getDisplayError(l10n.isArabic, isChildMode: true),
            onRetry: () => vocabProvider.loadVocabulary(_activeCategoryId),
            isChildMode: true,
          ),
        ),
      );
    }

    // 4. EMPTY STATE (Task 12)
    if (activeItems.isEmpty && (!hasProvider || !vocabProvider.uiState.isLoading)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: EmptyStateWidget(
            title: l10n.isArabic ? 'لا توجد كلمات حالياً' : 'No vocabulary yet',
            subtitle: l10n.isArabic
                ? 'سيتم إضافة كلمات جديدة في هذا القسم قريباً 🌱'
                : 'New vocabulary items will be added soon 🌱',
            icon: Icons.school_rounded,
            actionLabel: l10n.isArabic ? 'العودة' : 'Go Back',
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    // 5. SUCCESS STATE: Interactive flashcard session (Tasks 3-7)
    final totalCount = activeItems.isEmpty ? 1 : activeItems.length;
    final int safeIndex = _currentIndex.clamp(0, activeItems.isEmpty ? 0 : activeItems.length - 1).toInt();
    final currentItem = activeItems.isNotEmpty
        ? activeItems[safeIndex]
        : VocabularyItemModel(
            id: 'placeholder',
            categoryId: _activeCategoryId,
            labelEn: 'Loading',
            labelAr: 'جار التحميل',
            imageUrl: '',
          );
    final progressFraction = (safeIndex + 1) / totalCount;
    final isFinalItem = safeIndex == totalCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceS),
              // Top Bar matching Wireframe 4
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Category Pill (Task 2: Retrieved from Firestore / CategoryModel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border:
                          Border.all(color: AppColors.borderLight, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 22,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Text(
                          _getCategoryTitle(l10n, catProvider),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress Counter & Bar (Task 7)
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                      vertical: AppDimensions.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${safeIndex + 1} / $totalCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                          child: LinearProgressIndicator(
                            value: progressFraction,
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
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Main Vocabulary Card (Tasks 3, 4, 5, 6, 7, 9)
              Expanded(
                child: VocabularyCard(
                  item: currentItem,
                  isArabic: l10n.isArabic,
                  hasPrevious: safeIndex > 0,
                  hasNext: true,
                  nextButtonLabel: isFinalItem
                      ? l10n.text('btn_complete_session')
                      : l10n.text('btn_next'),
                  nextButtonIcon: isFinalItem
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  audioButtonLabel: l10n.text('btn_listen'),
                  onCardTap: _resetInactivityTimer,
                  reminderWidget: _showInactivityReminder
                      ? _buildInactivityReminderBanner(l10n)
                      : null,
                  onPlayAudio: () => _playAudioSafe(
                    currentItem,
                    isArabic: l10n.isArabic,
                    vocabProvider: vocabProvider,
                  ),
                  onPlayAudioAr: () => _playAudioSafe(
                    currentItem,
                    isArabic: true,
                    vocabProvider: vocabProvider,
                  ),
                  onPlayAudioEn: () => _playAudioSafe(
                    currentItem,
                    isArabic: false,
                    vocabProvider: vocabProvider,
                  ),
                  onPrevious: () {
                    _resetInactivityTimer();
                    if (safeIndex > 0) {
                      final prevIndex = safeIndex - 1;
                      setState(() => _currentIndex = prevIndex);
                      if (vocabProvider != null) {
                        vocabProvider.previousItem();
                      }
                      final sessionProvider =
                          Provider.of<LearningSessionProvider?>(context, listen: false);
                      if (sessionProvider != null && prevIndex < activeItems.length) {
                        sessionProvider.recordItemPresented(activeItems[prevIndex].id);
                      }
                    }
                  },
                  onNext: () {
                    _resetInactivityTimer();
                    if (isFinalItem) {
                      _completeSession(activeItems);
                    } else {
                      final nextIndex = safeIndex + 1;
                      setState(() => _currentIndex = nextIndex);
                      if (vocabProvider != null) {
                        vocabProvider.nextItem();
                      }
                      final sessionProvider =
                          Provider.of<LearningSessionProvider?>(context, listen: false);
                      if (sessionProvider != null && nextIndex < activeItems.length) {
                        sessionProvider.recordItemPresented(activeItems[nextIndex].id);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
            ],
          ),
        ),
      ),
    );
  }

  /// Gentle, non-alarming inactivity reminder banner (Task 9).
  Widget _buildInactivityReminderBanner(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
      decoration: BoxDecoration(
        color: AppColors.starBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.starGold, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.volume_up_rounded, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: AppDimensions.spaceS),
          Flexible(
            child: Text(
              l10n.text('inactivity_reminder'),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Celebratory, sensory-friendly Session Completion Screen (Tasks 10, 11, & 12).
  Widget _buildCompletedView(
    BuildContext context,
    AppLocalizations l10n,
    CategoryProvider? catProvider,
    List<VocabularyItemModel> items,
  ) {
    final categoryName = _getCategoryTitle(l10n, catProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.largeCardBorderRadius,
                  border: Border.all(color: AppColors.borderLight, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Golden celebratory stars badge (Task 11)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star_rounded, size: 48, color: AppColors.starGold),
                        SizedBox(width: 8),
                        Icon(Icons.star_rounded, size: 64, color: AppColors.starGold),
                        SizedBox(width: 8),
                        Icon(Icons.star_rounded, size: 48, color: AppColors.starGold),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),

                    // Encouraging title
                    Text(
                      l10n.text('session_completed_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceS),

                    // Gentle supportive subtitle
                    Text(
                      l10n.text('session_completed_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Summary details chips
                    Wrap(
                      spacing: AppDimensions.spaceM,
                      runSpacing: AppDimensions.spaceS,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceM,
                            vertical: AppDimensions.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(), size: 20, color: AppColors.primaryBlue),
                              const SizedBox(width: AppDimensions.spaceS),
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceM,
                            vertical: AppDimensions.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.starBackground.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: AppColors.starGold.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.textPrimary),
                              const SizedBox(width: AppDimensions.spaceS),
                              Text(
                                l10n.textWithArgs('words_learned', [items.length.toString()]),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),

                    // Primary Quiz Action Button (Task 10: Prepares for quiz stage)
                    AppButton(
                      label: l10n.text('btn_start_quiz'),
                      icon: Icons.quiz_rounded,
                      height: 54,
                      backgroundColor: const Color(0xFF10B981),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.childQuiz,
                          arguments: _activeCategoryId,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spaceM),

                    // Secondary Home Button
                    AppButton(
                      label: l10n.text('btn_return_home'),
                      icon: Icons.home_rounded,
                      height: 48,
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primaryBlue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
