import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

enum FeedbackState { neutral, correct, gentleCorrection }

/// Positive reinforcement and gentle corrective feedback banner matching Task 10 & Wireframe 2:
/// Gentle character mascot, calm copy, zero red warning screens or harsh alarms.
class FeedbackBanner extends StatelessWidget {
  final FeedbackState state;
  final String title;
  final String subtitle;
  final int earnedStars; // 0 to 3

  const FeedbackBanner({
    super.key,
    required this.state,
    required this.title,
    required this.subtitle,
    this.earnedStars = 3,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData mascotIcon;
    Color mascotColor;

    switch (state) {
      case FeedbackState.correct:
        bgColor = AppColors.successLight;
        borderColor = AppColors.success.withOpacity(0.3);
        textColor = const Color(0xFF15803D);
        mascotIcon = Icons.star_rounded;
        mascotColor = AppColors.starGold;
        break;
      case FeedbackState.gentleCorrection:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFF92400E);
        mascotIcon = Icons.spa_rounded; // Gentle seedling/sprout instead of an error 'X'
        mascotColor = const Color(0xFFF59E0B);
        break;
      case FeedbackState.neutral:
        bgColor = AppColors.primaryContainer;
        borderColor = AppColors.borderLight;
        textColor = AppColors.primaryDark;
        mascotIcon = Icons.star_rounded;
        mascotColor = AppColors.starGold;
        break;
    }

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
          // Friendly Mascot
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(
                mascotIcon,
                size: 32,
                color: mascotColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          // Copy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          // Star indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final isFilled = index < earnedStars;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 26,
                color: isFilled ? AppColors.starGold : AppColors.borderMedium,
              );
            }),
          ),
        ],
      ),
    );
  }
}
