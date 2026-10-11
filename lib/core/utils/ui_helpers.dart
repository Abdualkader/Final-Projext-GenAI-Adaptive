import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// UI formatting and helper utilities.
class UiHelpers {
  /// Resolves the category pastel color based on its category ID.
  static Color getCategoryBackgroundColor(String categoryId) {
    switch (categoryId) {
      case 'letters':
        return AppColors.cardLetters;
      case 'numbers':
        return AppColors.cardNumbers;
      case 'colours':
        return AppColors.cardColours;
      case 'animals':
      default:
        return AppColors.cardAnimals;
    }
  }

  /// Resolves the category text/accent color.
  static Color getCategoryTextColor(String categoryId) {
    switch (categoryId) {
      case 'letters':
        return AppColors.textLetters;
      case 'numbers':
        return AppColors.textNumbers;
      case 'colours':
        return AppColors.textColours;
      case 'animals':
      default:
        return AppColors.textAnimals;
    }
  }

  /// Formats percentage number to string.
  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
}
