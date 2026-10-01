import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/vocabulary_item_model.dart';
import 'app_button.dart';
import 'large_icon_button.dart';

/// Vocabulary flashcard matching Wireframe 4 & Week 4 requirements:
/// Uncluttered visual presentation, large bilingual typography, prominent audio button,
/// and explicit Next button.
class VocabularyCard extends StatelessWidget {
  final VocabularyItemModel item;
  final VoidCallback onPlayAudio;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool hasPrevious;
  final bool hasNext;
  final String nextButtonLabel;
  final String audioButtonLabel;

  const VocabularyCard({
    super.key,
    required this.item,
    required this.onPlayAudio,
    required this.onPrevious,
    required this.onNext,
    this.hasPrevious = true,
    this.hasNext = true,
    this.nextButtonLabel = 'Next',
    this.audioButtonLabel = 'Play Audio',
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
        const SizedBox(height: AppDimensions.spaceM),
        // Central Audio Action Button
        AppButton(
          label: '🔊  $audioButtonLabel',
          height: 52,
          backgroundColor: AppColors.primaryBlue,
          onPressed: onPlayAudio,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        // Pagination & Navigation Row
        Row(
          children: [
            if (hasPrevious)
              LargeIconButton(
                icon: Icons.arrow_back_rounded,
                size: 52,
                onPressed: onPrevious,
                iconColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
              ),
            if (hasPrevious) const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: AppButton(
                label: nextButtonLabel,
                icon: Icons.arrow_forward_rounded,
                height: 52,
                backgroundColor: const Color(0xFF10B981),
                onPressed: onNext,
              ),
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
      case 'red':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFFEF4444);
        label = '🔴 Red / أحمر';
        break;
      case 'blue':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFF3B82F6);
        label = '🔵 Blue / أزرق';
        break;
      case 'green':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFF10B981);
        label = '🟢 Green / أخضر';
        break;
      case 'one':
        icon = Icons.looks_one_rounded;
        iconColor = const Color(0xFF0288D1);
        label = '1️⃣ One / واحد';
        break;
      case 'two':
        icon = Icons.looks_two_rounded;
        iconColor = const Color(0xFFF59E0B);
        label = '2️⃣ Two / اثنان';
        break;
      case 'three':
        icon = Icons.looks_3_rounded;
        iconColor = const Color(0xFF10B981);
        label = '3️⃣ Three / ثلاثة';
        break;
      case 'alif':
      case 'baa':
      case 'taa':
        icon = Icons.text_fields_rounded;
        iconColor = const Color(0xFF8E24AA);
        label = '🔤 Letter / حرف';
        break;
      default:
        icon = Icons.auto_awesome_rounded;
        iconColor = AppColors.primaryBlue;
        label = 'Learning Card';
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
