import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/vocabulary_item_model.dart';
import '../models/quiz_question_model.dart';
import '../models/progress_model.dart';

/// Explicit repository for Week 3 UI mocking.
/// Strictly separated from future production Firebase repositories.
class MockDataRepository {
  static List<CategoryModel> getCategories() {
    return const [
      CategoryModel(
        id: 'animals',
        nameEn: 'Animals',
        nameAr: 'الحيوانات',
        backgroundColor: AppColors.cardAnimals,
        textColor: AppColors.textAnimals,
        borderColor: AppColors.borderAnimals,
        icon: Icons.pets,
        illustrationKey: 'dog',
      ),
      CategoryModel(
        id: 'colours',
        nameEn: 'Colours',
        nameAr: 'الألوان',
        backgroundColor: AppColors.cardColours,
        textColor: AppColors.textColours,
        borderColor: AppColors.borderColours,
        icon: Icons.palette_rounded,
        illustrationKey: 'rainbow',
      ),
      CategoryModel(
        id: 'numbers',
        nameEn: 'Numbers',
        nameAr: 'الأرقام',
        backgroundColor: AppColors.cardNumbers,
        textColor: AppColors.textNumbers,
        borderColor: AppColors.borderNumbers,
        icon: Icons.looks_one_rounded,
        illustrationKey: 'numbers_123',
      ),
      CategoryModel(
        id: 'letters',
        nameEn: 'Letters',
        nameAr: 'الحروف',
        backgroundColor: AppColors.cardLetters,
        textColor: AppColors.textLetters,
        borderColor: AppColors.borderLetters,
        icon: Icons.spellcheck_rounded,
        illustrationKey: 'letters_abc',
      ),
    ];
  }

  static List<VocabularyItemModel> getAnimalVocabulary() {
    return const [
      VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        wordEn: 'Cat',
        wordAr: 'قِطَّة',
        transliteration: 'Qittah',
        imagePath: 'assets/cat.png',
        audioPathEn: '/vocabulary/audio/en/cat.mp3',
        audioPathAr: '/vocabulary/audio/ar/cat.mp3',
      ),
      VocabularyItemModel(
        id: 'dog',
        categoryId: 'animals',
        wordEn: 'Dog',
        wordAr: 'كَلْب',
        transliteration: 'Kalb',
        imagePath: 'assets/dog.png',
        audioPathEn: '/vocabulary/audio/en/dog.mp3',
        audioPathAr: '/vocabulary/audio/ar/dog.mp3',
      ),
      VocabularyItemModel(
        id: 'fish',
        categoryId: 'animals',
        wordEn: 'Fish',
        wordAr: 'سَمَكَة',
        transliteration: 'Samakah',
        imagePath: 'assets/fish.png',
        audioPathEn: '/vocabulary/audio/en/fish.mp3',
        audioPathAr: '/vocabulary/audio/ar/fish.mp3',
      ),
    ];
  }

  static QuizQuestionModel getSampleQuizQuestion() {
    return const QuizQuestionModel(
      id: 'quiz_q1',
      promptEn: 'Where is the dog?',
      promptAr: 'أين الكلب؟',
      correctChoiceId: 'dog',
      choices: [
        QuizChoice(
          id: 'dog',
          labelEn: 'Dog',
          labelAr: 'كلب',
          icon: Icons.pets,
          accentColor: Color(0xFF22C55E),
        ),
        QuizChoice(
          id: 'cat',
          labelEn: 'Cat',
          labelAr: 'قطة',
          icon: Icons.cruelty_free,
          accentColor: Color(0xFF3B82F6),
        ),
        QuizChoice(
          id: 'fish',
          labelEn: 'Fish',
          labelAr: 'سمكة',
          icon: Icons.set_meal,
          accentColor: Color(0xFFA855F7),
        ),
      ],
    );
  }

  static StudentProgressModel getSampleProgress() {
    return const StudentProgressModel(
      studentName: 'Adam',
      studentAge: 5,
      interestBadgeEn: 'Loves Animals!',
      interestBadgeAr: 'يحب الحيوانات!',
      totalSessions: 24,
      overallAccuracy: 78,
      categoryAccuracies: [
        CategoryAccuracy(
          categoryEn: 'Animals',
          categoryAr: 'الحيوانات',
          accuracy: 85,
          color: Color(0xFF4CAF50),
          icon: Icons.pets,
        ),
        CategoryAccuracy(
          categoryEn: 'Colours',
          categoryAr: 'الألوان',
          accuracy: 72,
          color: Color(0xFFFFB300),
          icon: Icons.palette,
        ),
        CategoryAccuracy(
          categoryEn: 'Numbers',
          categoryAr: 'الأرقام',
          accuracy: 68,
          color: Color(0xFF2196F3),
          icon: Icons.format_list_numbered,
        ),
        CategoryAccuracy(
          categoryEn: 'Letters',
          categoryAr: 'الحروف',
          accuracy: 88,
          color: Color(0xFF9C27B0),
          icon: Icons.sort_by_alpha,
        ),
      ],
      recentSessions: [
        SessionRecord(
          id: 's1',
          date: 'May 31, 2025 • 10:30 AM',
          categoryEn: 'Animals',
          categoryAr: 'الحيوانات',
          score: '17 / 20',
          accuracyPercentage: 85,
          categoryIcon: Icons.pets,
          categoryColor: Color(0xFF4CAF50),
        ),
        SessionRecord(
          id: 's2',
          date: 'May 28, 2025 • 4:15 PM',
          categoryEn: 'Colours',
          categoryAr: 'الألوان',
          score: '13 / 20',
          accuracyPercentage: 65,
          categoryIcon: Icons.palette,
          categoryColor: Color(0xFFFFB300),
        ),
        SessionRecord(
          id: 's3',
          date: 'May 25, 2025 • 9:00 AM',
          categoryEn: 'Numbers',
          categoryAr: 'الأرقام',
          score: '14 / 20',
          accuracyPercentage: 70,
          categoryIcon: Icons.format_list_numbered,
          categoryColor: Color(0xFF2196F3),
        ),
        SessionRecord(
          id: 's4',
          date: 'May 22, 2025 • 3:45 PM',
          categoryEn: 'Letters',
          categoryAr: 'الحروف',
          score: '18 / 20',
          accuracyPercentage: 90,
          categoryIcon: Icons.sort_by_alpha,
          categoryColor: Color(0xFF9C27B0),
        ),
      ],
    );
  }
}
