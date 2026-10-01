import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/vocabulary_card.dart';

/// Vocabulary Learning Screen faithfully matching Wireframe 4:
/// Uncluttered flashcard presentation, clear bilingual text, category pill, and 3-step navigation.
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
  final _items = MockDataRepository.getAnimalVocabulary();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentItem = _items[_currentIndex];
    final totalCount = _items.length;
    final progressFraction = (_currentIndex + 1) / totalCount;

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
                  // Category Pill (e.g. "Animals")
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
                        const Icon(
                          Icons.pets_rounded,
                          size: 22,
                          color: AppColors.textAnimals,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Text(
                          l10n.text('category_animals'),
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
              const SizedBox(height: AppDimensions.spaceL),
              // Main Vocabulary Card
              Expanded(
                child: VocabularyCard(
                  item: currentItem,
                  hasPrevious: _currentIndex > 0,
                  hasNext: _currentIndex < totalCount - 1,
                  onPlayAudio: () {
                    // Audio pronunciation trigger (simulated in Week 3)
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
                      // Prompt to take Quiz
                      Navigator.pushNamed(context, AppRoutes.childQuiz);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
            ],
          ),
        ),
      ),
    );
  }
}
