import 'package:flutter/material.dart';

/// Centralized application-wide constants for the ASD Learning Assistant.
class AppConstants {
  // Application Information
  static const String appNameEn = 'ASD Learning Assistant';
  static const String appNameAr = 'مساعد التعلّم لاضطراب طيف التوحد';
  static const String appVersion = '1.0.0';

  // Supported Locales
  static const String langEn = 'en';
  static const String langAr = 'ar';
  static const List<Locale> supportedLocales = [
    Locale(langEn),
    Locale(langAr),
  ];
  static const Locale defaultLocale = Locale(langEn);

  // Core Category Identifiers
  static const String categoryLetters = 'letters';
  static const String categoryNumbers = 'numbers';
  static const String categoryColors = 'colours';
  static const String categoryAnimals = 'animals';

  static const List<String> allCategoryIds = [
    categoryLetters,
    categoryNumbers,
    categoryColors,
    categoryAnimals,
  ];

  // Default User & App Settings
  static const double defaultVolume = 0.8;
  static const int defaultSessionDurationMinutes = 5;
  static const int defaultDifficultyLevel = 1;
  static const bool defaultSoundEffectsEnabled = true;

  // Learning Configuration & ASD Sensory Safeguards
  static const int optionsPerQuizQuestion = 3;
  static const int questionsPerQuizSession = 5;
  static const int itemsPerLearningBatch = 5;
  static const double masteryAccuracyThreshold = 0.80; // 80% accuracy for mastery
  static const int minDifficultyLevel = 1;
  static const int maxDifficultyLevel = 3;
  static const int consecutiveSuccessesForLevelUp = 3;
  static const int targetSessionMinutes = 5; // ASD cognitive fatigue safeguard (~5 mins)

  // Accessibility & Motor Interaction Safeguards
  static const double minTouchTargetSize = 48.0; // Minimal accessible touch target (dp)
  static const double preferredTouchTargetSize = 64.0; // Recommended touch target for ASD children (dp)
}
