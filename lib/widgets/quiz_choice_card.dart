import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/quiz_question_model.dart';

/// Single interactive option card matching Wireframe 2:
/// Rounded frame with colored border and bottom selection ring or checkmark badge.
class QuizChoiceCard extends StatelessWidget {
  final QuizChoice choice;
  final bool isSelected;
  final bool isCorrect;
  final bool isArabic;
  final VoidCallback onTap;

  const QuizChoiceCard({
    super.key,
    required this.choice,
    required this.isSelected,
    this.isCorrect = false,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? (isCorrect ? AppColors.success : AppColors.primaryBlue)
        : choice.accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.cardBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimensions.cardBorderRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(isSelected ? 0.18 : 0.06),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Illustration area
              Expanded(
                child: Center(
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: choice.accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        choice.icon,
                        size: 44,
                        color: choice.accentColor,
                      ),
                    ),
                  ),
                ),
              ),
              // Option Label
              Text(
                choice.localizedLabel(isArabic),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              // Bottom status indicator (Checkmark or selection ring)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected && isCorrect
                        ? AppColors.success
                        : Colors.white,
                    border: Border.all(
                      color: isSelected && isCorrect
                          ? AppColors.success
                          : borderColor,
                      width: 3,
                    ),
                  ),
                  child: isSelected && isCorrect
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
