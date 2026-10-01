import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/vocabulary_item_model.dart';
import '../models/quiz_question_model.dart';
import '../models/progress_model.dart';

/// Explicit repository for Week 4 UI mocking.
/// Strictly separated from future production Firebase repositories.
class MockDataRepository {
  static List<CategoryModel> getCategories() {
    return const [
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
        id: 'colours',
        nameEn: 'Colors',
        nameAr: 'الألوان',
        backgroundColor: AppColors.cardColours,
        textColor: AppColors.textColours,
        borderColor: AppColors.borderColours,
        icon: Icons.palette_rounded,
        illustrationKey: 'rainbow',
      ),
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
    ];
  }

  static List<VocabularyItemModel> getVocabularyForCategory(String categoryId) {
    switch (categoryId) {
      case 'colours':
        return const [
          VocabularyItemModel(
            id: 'red',
            categoryId: 'colours',
            wordEn: 'Red',
            wordAr: 'أَحْمَر',
            transliteration: 'Ahmar',
            imagePath: 'assets/red.png',
            audioPathEn: '/vocabulary/audio/en/red.mp3',
            audioPathAr: '/vocabulary/audio/ar/red.mp3',
          ),
          VocabularyItemModel(
            id: 'blue',
            categoryId: 'colours',
            wordEn: 'Blue',
            wordAr: 'أَزْرَق',
            transliteration: 'Azraq',
            imagePath: 'assets/blue.png',
            audioPathEn: '/vocabulary/audio/en/blue.mp3',
            audioPathAr: '/vocabulary/audio/ar/blue.mp3',
          ),
          VocabularyItemModel(
            id: 'green',
            categoryId: 'colours',
            wordEn: 'Green',
            wordAr: 'أَخْضَر',
            transliteration: 'Akhdar',
            imagePath: 'assets/green.png',
            audioPathEn: '/vocabulary/audio/en/green.mp3',
            audioPathAr: '/vocabulary/audio/ar/green.mp3',
          ),
        ];
      case 'numbers':
        return const [
          VocabularyItemModel(
            id: 'one',
            categoryId: 'numbers',
            wordEn: 'One',
            wordAr: 'وَاحِد',
            transliteration: 'Wahid',
            imagePath: 'assets/one.png',
            audioPathEn: '/vocabulary/audio/en/one.mp3',
            audioPathAr: '/vocabulary/audio/ar/one.mp3',
          ),
          VocabularyItemModel(
            id: 'two',
            categoryId: 'numbers',
            wordEn: 'Two',
            wordAr: 'اِثْنَان',
            transliteration: 'Ithnan',
            imagePath: 'assets/two.png',
            audioPathEn: '/vocabulary/audio/en/two.mp3',
            audioPathAr: '/vocabulary/audio/ar/two.mp3',
          ),
          VocabularyItemModel(
            id: 'three',
            categoryId: 'numbers',
            wordEn: 'Three',
            wordAr: 'ثَلَاثَة',
            transliteration: 'Thalatha',
            imagePath: 'assets/three.png',
            audioPathEn: '/vocabulary/audio/en/three.mp3',
            audioPathAr: '/vocabulary/audio/ar/three.mp3',
          ),
        ];
      case 'letters':
        return const [
          VocabularyItemModel(
            id: 'alif',
            categoryId: 'letters',
            wordEn: 'Letter A',
            wordAr: 'أَلِف',
            transliteration: 'Alif',
            imagePath: 'assets/alif.png',
            audioPathEn: '/vocabulary/audio/en/a.mp3',
            audioPathAr: '/vocabulary/audio/ar/alif.mp3',
          ),
          VocabularyItemModel(
            id: 'baa',
            categoryId: 'letters',
            wordEn: 'Letter B',
            wordAr: 'بَاء',
            transliteration: 'Baa',
            imagePath: 'assets/baa.png',
            audioPathEn: '/vocabulary/audio/en/b.mp3',
            audioPathAr: '/vocabulary/audio/ar/baa.mp3',
          ),
          VocabularyItemModel(
            id: 'taa',
            categoryId: 'letters',
            wordEn: 'Letter T',
            wordAr: 'تَاء',
            transliteration: 'Taa',
            imagePath: 'assets/taa.png',
            audioPathEn: '/vocabulary/audio/en/t.mp3',
            audioPathAr: '/vocabulary/audio/ar/taa.mp3',
          ),
        ];
      case 'animals':
      default:
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
  }

  static QuizQuestionModel getQuizQuestionForCategory(String categoryId) {
    switch (categoryId) {
      case 'colours':
        return const QuizQuestionModel(
          id: 'quiz_colour',
          promptEn: 'Which one is Red?',
          promptAr: 'أين اللون الأحمر؟',
          correctChoiceId: 'red',
          choices: [
            QuizChoice(
              id: 'red',
              labelEn: 'Red',
              labelAr: 'أحمر',
              icon: Icons.circle,
              accentColor: Color(0xFFEF4444),
            ),
            QuizChoice(
              id: 'blue',
              labelEn: 'Blue',
              labelAr: 'أزرق',
              icon: Icons.circle,
              accentColor: Color(0xFF3B82F6),
            ),
            QuizChoice(
              id: 'green',
              labelEn: 'Green',
              labelAr: 'أخضر',
              icon: Icons.circle,
              accentColor: Color(0xFF10B981),
            ),
          ],
        );
      case 'numbers':
        return const QuizQuestionModel(
          id: 'quiz_number',
          promptEn: 'Where is Number 1?',
          promptAr: 'أين الرقم ١؟',
          correctChoiceId: 'one',
          choices: [
            QuizChoice(
              id: 'one',
              labelEn: 'One',
              labelAr: 'واحد',
              icon: Icons.looks_one_rounded,
              accentColor: Color(0xFF0288D1),
            ),
            QuizChoice(
              id: 'two',
              labelEn: 'Two',
              labelAr: 'اثنان',
              icon: Icons.looks_two_rounded,
              accentColor: Color(0xFFF59E0B),
            ),
            QuizChoice(
              id: 'three',
              labelEn: 'Three',
              labelAr: 'ثلاثة',
              icon: Icons.looks_3_rounded,
              accentColor: Color(0xFF10B981),
            ),
          ],
        );
      case 'letters':
        return const QuizQuestionModel(
          id: 'quiz_letter',
          promptEn: 'Where is Letter A?',
          promptAr: 'أين حرف الألف؟',
          correctChoiceId: 'alif',
          choices: [
            QuizChoice(
              id: 'alif',
              labelEn: 'Letter A',
              labelAr: 'ألف',
              icon: Icons.text_fields_rounded,
              accentColor: Color(0xFF8E24AA),
            ),
            QuizChoice(
              id: 'baa',
              labelEn: 'Letter B',
              labelAr: 'باء',
              icon: Icons.text_fields_rounded,
              accentColor: Color(0xFF0288D1),
            ),
            QuizChoice(
              id: 'taa',
              labelEn: 'Letter T',
              labelAr: 'تاء',
              icon: Icons.text_fields_rounded,
              accentColor: Color(0xFFEF4444),
            ),
          ],
        );
      case 'animals':
      default:
        return const QuizQuestionModel(
          id: 'quiz_animal',
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
          categoryEn: 'Letters',
          categoryAr: 'الحروف',
          accuracy: 88,
          color: Color(0xFF9C27B0),
          icon: Icons.sort_by_alpha,
        ),
        CategoryAccuracy(
          categoryEn: 'Numbers',
          categoryAr: 'الأرقام',
          accuracy: 68,
          color: Color(0xFF2196F3),
          icon: Icons.format_list_numbered,
        ),
        CategoryAccuracy(
          categoryEn: 'Colors',
          categoryAr: 'الألوان',
          accuracy: 72,
          color: Color(0xFFFFB300),
          icon: Icons.palette,
        ),
        CategoryAccuracy(
          categoryEn: 'Animals',
          categoryAr: 'الحيوانات',
          accuracy: 85,
          color: Color(0xFF4CAF50),
          icon: Icons.pets,
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
          categoryEn: 'Colors',
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
