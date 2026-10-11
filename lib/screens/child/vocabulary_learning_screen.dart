import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/vocabulary_item_model.dart';
import '../../providers/vocabulary_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/vocabulary_card.dart';

/// Vocabulary Learning Screen faithfully matching Wireframe 4 & Week 4 requirements:
/// Supports dynamic category loading, clean progress indicator, bilingual typography,
/// audio feedback, and explicit Next button.
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

  String _getCategoryTitle(AppLocalizations l10n) {
    switch (_activeCategoryId) {
      case 'letters':
        return l10n.text('category_letters');
      case 'numbers':
        return l10n.text('category_numbers');
      case 'colours':
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
    final activeItems = (vocabProvider != null &&
            vocabProvider.items.isNotEmpty &&
            vocabProvider.currentCategoryId == _activeCategoryId)
        ? vocabProvider.items
        : _items;
    final safeIndex = _currentIndex.clamp(0, activeItems.length - 1);
    final currentItem = activeItems[safeIndex];
    final totalCount = activeItems.length;
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
                  // Category Pill
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
                          _getCategoryTitle(l10n),
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
                          '${_currentIndex + 1} / $totalCount',
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
              // Main Vocabulary Card
              Expanded(
                child: VocabularyCard(
                  item: currentItem,
                  hasPrevious: _currentIndex > 0,
                  hasNext: true,
                  nextButtonLabel: l10n.text('btn_next'),
                  audioButtonLabel: l10n.text('btn_listen'),
                  onPlayAudio: () {
                    // Audio pronunciation trigger (simulated with calm sensory banner)
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
                  onPrevious: () {
                    if (_currentIndex > 0) {
                      setState(() => _currentIndex--);
                    }
                  },
                  onNext: () {
                    if (_currentIndex < totalCount - 1) {
                      setState(() => _currentIndex++);
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
