import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Positive reinforcement banner matching Wireframe 2:
/// Gentle character star, calm encouraging copy, and 3-star reward indicators.
class FeedbackBanner extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String subtitle;
  final int earnedStars; // 0 to 3

  const FeedbackBanner({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.subtitle,
    this.earnedStars = 3,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSuccess ? AppColors.successLight : AppColors.primaryContainer;
    final borderColor = isSuccess ? AppColors.success.withOpacity(0.3) : AppColors.borderLight;
    final textColor = isSuccess ? const Color(0xFF15803D) : AppColors.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceL,
        vertical: AppDimensions.spaceM,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          // Smiling Mascot Star
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.starBackground,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.star_rounded,
                size: 34,
                color: AppColors.starGold,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          // Encouraging Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          // 3 Star Indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final isFilled = index < earnedStars;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 28,
                color: isFilled ? AppColors.starGold : AppColors.borderMedium,
              );
            }),
          ),
        ],
      ),
    );
  }
}
