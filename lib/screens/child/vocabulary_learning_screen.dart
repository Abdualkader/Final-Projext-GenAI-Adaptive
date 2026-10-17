import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/vocabulary_item_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/vocabulary_card.dart';

/// Vocabulary Learning Screen faithfully matching Wireframe 4 & Week 8 requirements:
/// - Category filtering via repository/provider layer (Task 8)
/// - Robust loading, empty, and gentle error states (Task 9)
/// - Preview with image, bilingual labels, and audio buttons (Task 10 & 11)
/// - Clean progress indicator and difficulty level display (Task 4)
class VocabularyLearningScreen extends StatefulWidget {
  final String categoryId;

  const VocabularyLearningScreen({
    super.key,
    this.categoryId = 'animals',
  });

  @override
  State<VocabularyLearningScreen> createState() =>
      _VocabularyLearningScreenState();
}

class _VocabularyLearningScreenState extends State<VocabularyLearningScreen> {
  int _currentIndex = 0;
  late String _activeCategoryId;
  late List<VocabularyItemModel> _items;

  @override
  void initState() {
    super.initState();
    _activeCategoryId = widget.categoryId;
    _items = MockDataRepository.getVocabularyForCategory(_activeCategoryId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabProvider =
          Provider.of<VocabularyProvider?>(context, listen: false);
      if (vocabProvider != null) {
        vocabProvider.loadVocabulary(_activeCategoryId);
      }
    });
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
      });
      final vocabProvider =
          Provider.of<VocabularyProvider?>(context, listen: false);
      if (vocabProvider != null) {
        vocabProvider.loadVocabulary(_activeCategoryId);
      }
    }
  }

  String _getCategoryTitle(AppLocalizations l10n, CategoryProvider? catProvider) {
    if (catProvider != null && catProvider.categories.isNotEmpty) {
      try {
        final searchIds = (_activeCategoryId == 'colors' || _activeCategoryId == 'colours')
            ? ['colours', 'colors']
            : [_activeCategoryId];
        final cat = catProvider.categories.firstWhere(
          (c) => searchIds.contains(c.id),
        );
        return cat.localizedName(l10n.isArabic);
      } catch (_) {
        // Fall back to localized key
      }
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

    // Determine state and active items
    final bool hasProvider = vocabProvider != null;
    final bool isProviderForActiveCategory = hasProvider &&
        (vocabProvider.currentCategoryId == _activeCategoryId ||
            (vocabProvider.currentCategoryId == 'colours' && _activeCategoryId == 'colors') ||
            (vocabProvider.currentCategoryId == 'colors' && _activeCategoryId == 'colours'));

    final activeItems = (isProviderForActiveCategory && vocabProvider.items.isNotEmpty)
        ? vocabProvider.items
        : _items;

    // Handle asynchronous loading states (Task 9)
    if (hasProvider && isProviderForActiveCategory) {
      final uiState = vocabProvider.uiState;

      if (uiState.isLoading) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: const SafeArea(
            child: LoadingWidget(),
          ),
        );
      }

      if (uiState.isError) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: AppErrorWidget(
              message: uiState.getDisplayError(l10n.isArabic, isChildMode: true),
              onRetry: () => vocabProvider.loadVocabulary(_activeCategoryId),
              isChildMode: true,
            ),
          ),
        );
      }

      if (uiState.isEmpty && activeItems.isEmpty) {
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
    }

    final totalCount = activeItems.isEmpty ? 1 : activeItems.length;
    final safeIndex = _currentIndex.clamp(0, activeItems.isEmpty ? 0 : activeItems.length - 1);
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.borderLight, width: 1.5),
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
                  // Progress Counter & Bar
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
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
                          '${safeIndex + 1} / $totalCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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

              // Main Vocabulary Card (Tasks 4, 5, 7, 10, 11)
              Expanded(
                child: VocabularyCard(
                  item: currentItem,
                  isArabic: l10n.isArabic,
                  hasPrevious: safeIndex > 0,
                  hasNext: true,
                  nextButtonLabel: l10n.text('btn_next'),
                  audioButtonLabel: l10n.text('btn_listen'),
                  onPlayAudio: () {
                    // Task 11: Connect audio playback to Firebase data / AudioService
                    if (vocabProvider != null) {
                      vocabProvider.playAudioFor(currentItem, isArabic: l10n.isArabic);
                    }

                    // Sensory audio banner
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
                              '🔊 ${currentItem.wordEn} • ${currentItem.wordAr}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onPlayAudioAr: () {
                    if (vocabProvider != null) {
                      vocabProvider.playAudioFor(currentItem, isArabic: true);
                    }
                  },
                  onPlayAudioEn: () {
                    if (vocabProvider != null) {
                      vocabProvider.playAudioFor(currentItem, isArabic: false);
                    }
                  },
                  onPrevious: () {
                    if (safeIndex > 0) {
                      setState(() => _currentIndex = safeIndex - 1);
                      if (vocabProvider != null) {
                        vocabProvider.previousItem();
                      }
                    }
                  },
                  onNext: () {
                    if (safeIndex < totalCount - 1) {
                      setState(() => _currentIndex = safeIndex + 1);
                      if (vocabProvider != null) {
                        vocabProvider.nextItem();
                      }
                    } else {
                      // Navigate to Quiz with category argument
                      Navigator.pushNamed(
                        context,
                        AppRoutes.childQuiz,
                        arguments: _activeCategoryId,
                      );
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
}
