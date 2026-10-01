import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/vocabulary_item_model.dart';
import 'large_icon_button.dart';

/// Vocabulary flashcard matching Wireframe 4:
/// Uncluttered visual presentation, large bilingual typography, and prominent audio button.
class VocabularyCard extends StatelessWidget {
  final VocabularyItemModel item;
  final VoidCallback onPlayAudio;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool hasPrevious;
  final bool hasNext;

  const VocabularyCard({
    super.key,
    required this.item,
    required this.onPlayAudio,
    required this.onPrevious,
    required this.onNext,
    this.hasPrevious = true,
    this.hasNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Flashcard Frame
        Expanded(
          child: Container(
            width: double.infinity,
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
            child: ClipRRect(
              borderRadius: AppDimensions.largeCardBorderRadius,
              child: Column(
                children: [
                  // Image Area
                  Expanded(
                    flex: 7,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.background,
                      child: Center(
                        child: _buildVocabularyIllustration(item.id),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  // Bilingual Labels Area
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceXL,
                        vertical: AppDimensions.spaceM,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // English Label
                          Text(
                            item.wordEn,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                              letterSpacing: -0.5,
                            ),
                          ),
                          // Arabic Label
                          Text(
                            item.wordAr,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        // Bottom Action Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous Word
            LargeIconButton(
              icon: Icons.arrow_back_rounded,
              size: 58,
              onPressed: hasPrevious ? onPrevious : () {},
              iconColor: hasPrevious
                  ? AppColors.primaryBlue
                  : AppColors.textMuted.withOpacity(0.4),
              backgroundColor: Colors.white,
            ),
            // Prominent Audio Speaker (76dp)
            LargeIconButton(
              icon: Icons.volume_up_rounded,
              size: 76,
              iconSize: 42,
              hasOuterGlow: true,
              onPressed: onPlayAudio,
              backgroundColor: AppColors.primaryBlue,
              iconColor: Colors.white,
              tooltip: 'Listen to pronunciation',
            ),
            // Next Word
            LargeIconButton(
              icon: Icons.arrow_forward_rounded,
              size: 58,
              onPressed: hasNext ? onNext : () {},
              iconColor: hasNext
                  ? AppColors.primaryBlue
                  : AppColors.textMuted.withOpacity(0.4),
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVocabularyIllustration(String id) {
    IconData icon;
    Color iconColor;
    String label;

    switch (id) {
      case 'cat':
        icon = Icons.cruelty_free_rounded;
        iconColor = const Color(0xFFF59E0B);
        label = '🐱 Cat / قطة';
        break;
      case 'dog':
        icon = Icons.pets_rounded;
        iconColor = const Color(0xFF10B981);
        label = '🐶 Dog / كلب';
        break;
      case 'fish':
        icon = Icons.set_meal_rounded;
        iconColor = const Color(0xFF3B82F6);
        label = '🐟 Fish / سمكة';
        break;
      default:
        icon = Icons.image_rounded;
        iconColor = AppColors.primaryBlue;
        label = 'Vocabulary Item';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.3), width: 3),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 72,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
