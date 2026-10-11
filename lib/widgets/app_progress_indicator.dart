import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Reusable progress bar indicator with calm pastel styling and step counter.
class AppProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final Color activeColor;
  final Color backgroundColor;
  final bool showLabel;

  const AppProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 10.0,
    this.activeColor = AppColors.primaryBlue,
    this.backgroundColor = AppColors.primaryLight,
    this.showLabel = true,
  });

  double get progressFraction {
    if (totalSteps <= 0) return 0.0;
    return (currentStep / totalSteps).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  '$currentStep / $totalSteps',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: progressFraction,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
        ),
      ],
    );
  }
}
