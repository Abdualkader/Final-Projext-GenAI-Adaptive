import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// UI formatting and helper utilities.
class UiHelpers {
  /// Resolves the category pastel color based on its category ID.
  static Color getCategoryBackgroundColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return AppColors.cardLetters;
      case 'numbers':
        return AppColors.cardNumbers;
      case 'colours':
      case 'colors':
        return AppColors.cardColours;
      case 'animals':
      default:
        return AppColors.cardAnimals;
    }
  }

  /// Resolves the category text/accent color.
  static Color getCategoryTextColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return AppColors.textLetters;
      case 'numbers':
        return AppColors.textNumbers;
      case 'colours':
      case 'colors':
        return AppColors.textColours;
      case 'animals':
      default:
        return AppColors.textAnimals;
    }
  }

  /// Resolves the category card border color.
  static Color getCategoryBorderColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return AppColors.borderLetters;
      case 'numbers':
        return AppColors.borderNumbers;
      case 'colours':
      case 'colors':
        return AppColors.borderColours;
      case 'animals':
      default:
        return AppColors.borderAnimals;
    }
  }

  /// Resolves the category primary icon.
  static IconData getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
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

  /// Formats percentage number to string.
  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
}
