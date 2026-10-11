import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/firebase_collections.dart';
import '../models/category_model.dart';
import '../models/child_model.dart';
import '../models/learning_session_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_result_model.dart';
import '../models/user_model.dart';
import '../models/vocabulary_item_model.dart';
import 'firestore_service.dart';

/// Managed service for controlled development and test datasets.
/// Follows Week 7 specifications: 4 categories, curated vocabulary items,
/// test parent/educator account, and test child profiles.
class SampleDataService {
  /// The 4 foundational learning categories required by the project.
  static List<CategoryModel> get sampleCategories => const [
        CategoryModel(
          id: 'letters',
          nameEn: 'Letters',
          nameAr: 'الحروف',
          backgroundColor: AppColors.cardLetters,
          textColor: AppColors.textLetters,
          borderColor: AppColors.borderLetters,
          icon: Icons.spellcheck_rounded,
          illustrationKey: 'letters_abc',
          iconUrl: 'vocabulary/images/letters.png',
          orderIndex: 0,
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
          iconUrl: 'vocabulary/images/numbers.png',
          orderIndex: 1,
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
          iconUrl: 'vocabulary/images/colours.png',
          orderIndex: 2,
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
          iconUrl: 'vocabulary/images/animals.png',
          orderIndex: 3,
        ),
      ];

  /// Controlled vocabulary items across all 4 categories with difficulty ratings.
  static List<VocabularyItemModel> get sampleVocabulary => const [
        // Animals
        VocabularyItemModel(
          id: 'cat',
          categoryId: 'animals',
          labelEn: 'Cat',
          labelAr: 'قِطَّة',
          transliteration: 'Qittah',
          imageUrl: 'vocabulary/images/cat.png',
          audioUrlAr: 'vocabulary/audio/ar/cat.mp3',
          audioUrlEn: 'vocabulary/audio/en/cat.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'dog',
          categoryId: 'animals',
          labelEn: 'Dog',
          labelAr: 'كَلْب',
          transliteration: 'Kalb',
          imageUrl: 'vocabulary/images/dog.png',
          audioUrlAr: 'vocabulary/audio/ar/dog.mp3',
          audioUrlEn: 'vocabulary/audio/en/dog.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'rabbit',
          categoryId: 'animals',
          labelEn: 'Rabbit',
          labelAr: 'أَرْنَب',
          transliteration: 'Arnab',
          imageUrl: 'vocabulary/images/rabbit.png',
          audioUrlAr: 'vocabulary/audio/ar/rabbit.mp3',
          audioUrlEn: 'vocabulary/audio/en/rabbit.mp3',
          difficultyLevel: 2,
        ),
        VocabularyItemModel(
          id: 'lion',
          categoryId: 'animals',
          labelEn: 'Lion',
          labelAr: 'أَسَد',
          transliteration: 'Asad',
          imageUrl: 'vocabulary/images/lion.png',
          audioUrlAr: 'vocabulary/audio/ar/lion.mp3',
          audioUrlEn: 'vocabulary/audio/en/lion.mp3',
          difficultyLevel: 3,
        ),

        // Colors
        VocabularyItemModel(
          id: 'red',
          categoryId: 'colours',
          labelEn: 'Red',
          labelAr: 'أَحْمَر',
          transliteration: 'Ahmar',
          imageUrl: 'vocabulary/images/red.png',
          audioUrlAr: 'vocabulary/audio/ar/red.mp3',
          audioUrlEn: 'vocabulary/audio/en/red.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'blue',
          categoryId: 'colours',
          labelEn: 'Blue',
          labelAr: 'أَزْرَق',
          transliteration: 'Azraq',
          imageUrl: 'vocabulary/images/blue.png',
          audioUrlAr: 'vocabulary/audio/ar/blue.mp3',
          audioUrlEn: 'vocabulary/audio/en/blue.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'green',
          categoryId: 'colours',
          labelEn: 'Green',
          labelAr: 'أَخْضَر',
          transliteration: 'Akhdar',
          imageUrl: 'vocabulary/images/green.png',
          audioUrlAr: 'vocabulary/audio/ar/green.mp3',
          audioUrlEn: 'vocabulary/audio/en/green.mp3',
          difficultyLevel: 2,
        ),
        VocabularyItemModel(
          id: 'yellow',
          categoryId: 'colours',
          labelEn: 'Yellow',
          labelAr: 'أَصْفَر',
          transliteration: 'Asfar',
          imageUrl: 'vocabulary/images/yellow.png',
          audioUrlAr: 'vocabulary/audio/ar/yellow.mp3',
          audioUrlEn: 'vocabulary/audio/en/yellow.mp3',
          difficultyLevel: 2,
        ),

        // Numbers
        VocabularyItemModel(
          id: 'one',
          categoryId: 'numbers',
          labelEn: 'One',
          labelAr: 'وَاحِد',
          transliteration: 'Wahid',
          imageUrl: 'vocabulary/images/one.png',
          audioUrlAr: 'vocabulary/audio/ar/one.mp3',
          audioUrlEn: 'vocabulary/audio/en/one.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'two',
          categoryId: 'numbers',
          labelEn: 'Two',
          labelAr: 'اِثْنَان',
          transliteration: 'Ithnan',
          imageUrl: 'vocabulary/images/two.png',
          audioUrlAr: 'vocabulary/audio/ar/two.mp3',
          audioUrlEn: 'vocabulary/audio/en/two.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'three',
          categoryId: 'numbers',
          labelEn: 'Three',
          labelAr: 'ثَلَاثَة',
          transliteration: 'Thalatha',
          imageUrl: 'vocabulary/images/three.png',
          audioUrlAr: 'vocabulary/audio/ar/three.mp3',
          audioUrlEn: 'vocabulary/audio/en/three.mp3',
          difficultyLevel: 2,
        ),
        VocabularyItemModel(
          id: 'four',
          categoryId: 'numbers',
          labelEn: 'Four',
          labelAr: 'أَرْبَعَة',
          transliteration: 'Arbaah',
          imageUrl: 'vocabulary/images/four.png',
          audioUrlAr: 'vocabulary/audio/ar/four.mp3',
          audioUrlEn: 'vocabulary/audio/en/four.mp3',
          difficultyLevel: 2,
        ),

        // Letters
        VocabularyItemModel(
          id: 'alif',
          categoryId: 'letters',
          labelEn: 'Letter A',
          labelAr: 'أَلِف',
          transliteration: 'Alif',
          imageUrl: 'vocabulary/images/alif.png',
          audioUrlAr: 'vocabulary/audio/ar/alif.mp3',
          audioUrlEn: 'vocabulary/audio/en/alif.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'baa',
          categoryId: 'letters',
          labelEn: 'Letter B',
          labelAr: 'بَاء',
          transliteration: 'Baa',
          imageUrl: 'vocabulary/images/baa.png',
          audioUrlAr: 'vocabulary/audio/ar/baa.mp3',
          audioUrlEn: 'vocabulary/audio/en/baa.mp3',
          difficultyLevel: 1,
        ),
        VocabularyItemModel(
          id: 'taa',
          categoryId: 'letters',
          labelEn: 'Letter T',
          labelAr: 'تَاء',
          transliteration: 'Taa',
          imageUrl: 'vocabulary/images/taa.png',
          audioUrlAr: 'vocabulary/audio/ar/taa.mp3',
          audioUrlEn: 'vocabulary/audio/en/taa.mp3',
          difficultyLevel: 2,
        ),
        VocabularyItemModel(
          id: 'thaa',
          categoryId: 'letters',
          labelEn: 'Letter Th',
          labelAr: 'ثَاء',
          transliteration: 'Thaa',
          imageUrl: 'vocabulary/images/thaa.png',
          audioUrlAr: 'vocabulary/audio/ar/thaa.mp3',
          audioUrlEn: 'vocabulary/audio/en/thaa.mp3',
          difficultyLevel: 2,
        ),
      ];

  /// Controlled test parent/educator account.
  static UserModel get sampleParentUser => UserModel(
        userId: 'parent_test_01',
        email: 'educator@example.com',
        displayName: 'Test Educator',
        role: 'educator',
        preferredLanguage: 'en',
        linkedChildIds: const ['child_adam', 'child_sara', 'child_omar'],
        difficultyLevel: 1,
        createdAt: DateTime(2026, 1, 1),
      );

  /// Controlled test child profiles.
  static List<ChildModel> get sampleChildren => [
        ChildModel(
          childId: 'child_adam',
          parentId: 'parent_test_01',
          name: 'Adam',
          birthDate: DateTime(2021, 5, 12),
          currentDifficultyLevel: 1,
          preferredLanguage: 'en',
          createdAt: DateTime(2026, 1, 1),
        ),
        ChildModel(
          childId: 'child_sara',
          parentId: 'parent_test_01',
          name: 'Sara',
          birthDate: DateTime(2020, 8, 20),
          currentDifficultyLevel: 2,
          preferredLanguage: 'en',
          createdAt: DateTime(2026, 1, 1),
        ),
        ChildModel(
          childId: 'child_omar',
          parentId: 'parent_test_01',
          name: 'Omar',
          birthDate: DateTime(2021, 3, 15),
          currentDifficultyLevel: 2,
          preferredLanguage: 'ar',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  /// Controlled sample learning session telemetry.
  static LearningSessionModel get sampleSession => LearningSessionModel(
        sessionId: 'session_sample_01',
        childId: 'child_adam',
        categoryId: 'animals',
        startTime: DateTime(2026, 10, 11, 10, 0),
        endTime: DateTime(2026, 10, 11, 10, 5),
        itemsPresented: const ['cat', 'dog'],
        score: 1.0,
      );

  /// Controlled sample quiz result.
  static QuizResultModel get sampleQuizResult => QuizResultModel(
        resultId: 'quiz_sample_01',
        sessionId: 'session_sample_01',
        childId: 'child_adam',
        questionId: 'q_animals_01',
        childResponse: 'cat',
        isCorrect: true,
        responseTimeMs: 1450,
        timestamp: DateTime(2026, 10, 11, 10, 4),
      );

  /// Controlled sample progress record.
  static ProgressRecordModel get sampleProgressRecord => ProgressRecordModel(
        recordId: 'progress_sample_01',
        childId: 'child_adam',
        date: DateTime(2026, 10, 11),
        itemsMastered: const ['cat', 'dog', 'red'],
        quizScores: const [100.0, 90.0, 85.0],
        overallAccuracy: 0.92,
      );

  /// Seeds all controlled development data into Cloud Firestore.
  /// Used for test fixture setup, developer bootstrapping, and offline fallback initialization.
  static Future<void> seedAll(
    FirestoreService firestoreService, {
    bool overwrite = false,
  }) async {
    // 1. Seed Categories
    for (final category in sampleCategories) {
      await firestoreService.setDocument(
        FirebaseCollections.categories,
        category.id,
        category.toMap(),
        merge: !overwrite,
      );
    }

    // 2. Seed Vocabulary Items
    for (final item in sampleVocabulary) {
      await firestoreService.setDocument(
        FirebaseCollections.vocabularyItems,
        item.id,
        item.toMap(),
        merge: !overwrite,
      );
    }

    // 3. Seed Sample User Profile
    await firestoreService.setDocument(
      FirebaseCollections.users,
      sampleParentUser.userId,
      sampleParentUser.toMap(),
      merge: !overwrite,
    );

    // 4. Seed Linked Children
    for (final child in sampleChildren) {
      await firestoreService.setDocument(
        FirebaseCollections.children,
        child.childId,
        child.toMap(),
        merge: !overwrite,
      );
    }

    // 5. Seed Telemetry (Session, Quiz, Progress)
    await firestoreService.setDocument(
      FirebaseCollections.sessions,
      sampleSession.sessionId,
      sampleSession.toMap(),
      merge: !overwrite,
    );

    await firestoreService.setDocument(
      FirebaseCollections.quizResults,
      sampleQuizResult.resultId,
      sampleQuizResult.toMap(),
      merge: !overwrite,
    );

    await firestoreService.setDocument(
      FirebaseCollections.progressRecords,
      sampleProgressRecord.recordId,
      sampleProgressRecord.toMap(),
      merge: !overwrite,
    );
  }
}
