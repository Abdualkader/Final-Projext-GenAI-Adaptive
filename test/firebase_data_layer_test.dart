import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/core/constants/firebase_collections.dart';
import 'package:asd_learning_assistant/core/errors/app_exceptions.dart';
import 'package:asd_learning_assistant/core/errors/ui_state.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/learning_session_model.dart';
import 'package:asd_learning_assistant/models/progress_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/models/vocabulary_item_model.dart';
import 'package:asd_learning_assistant/providers/category_provider.dart';
import 'package:asd_learning_assistant/providers/vocabulary_provider.dart';
import 'package:asd_learning_assistant/repositories/category_repository.dart';
import 'package:asd_learning_assistant/repositories/progress_repository.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/repositories/vocabulary_repository.dart';
import 'package:asd_learning_assistant/services/sample_data_service.dart';
import 'package:asd_learning_assistant/services/storage_service.dart';

void main() {
  group('Task 2 & 10: Firestore Collections and Index Specifications', () {
    test('FirebaseCollections exposes all required database collections', () {
      expect(FirebaseCollections.users, 'users');
      expect(FirebaseCollections.children, 'children');
      expect(FirebaseCollections.categories, 'categories');
      expect(FirebaseCollections.vocabularyItems, 'vocabularyItems');
      expect(FirebaseCollections.sessions, 'sessions');
      expect(FirebaseCollections.quizResults, 'quizResults');
      expect(FirebaseCollections.progressRecords, 'progressRecords');
      expect(FirebaseCollections.systemHealth, '_system_health');
    });

    test('firestore.indexes.json defines all required composite indexes', () {
      final indexFile = File('firestore.indexes.json');
      expect(indexFile.existsSync(), true, reason: 'firestore.indexes.json must exist');

      final content = indexFile.readAsStringSync();
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      final indexes = jsonMap['indexes'] as List<dynamic>;

      expect(indexes.length, greaterThanOrEqualTo(3));

      // 1. sessions: childId ASC, startTime DESC
      final sessionIndex = indexes.firstWhere(
        (idx) => idx['collectionGroup'] == 'sessions',
        orElse: () => null,
      );
      expect(sessionIndex, isNotNull);
      final sessionFields = sessionIndex['fields'] as List<dynamic>;
      expect(sessionFields[0]['fieldPath'], 'childId');
      expect(sessionFields[0]['order'], 'ASCENDING');
      expect(sessionFields[1]['fieldPath'], 'startTime');
      expect(sessionFields[1]['order'], 'DESCENDING');

      // 2. vocabularyItems: categoryId ASC, difficultyLevel ASC
      final vocabIndex = indexes.firstWhere(
        (idx) => idx['collectionGroup'] == 'vocabularyItems',
        orElse: () => null,
      );
      expect(vocabIndex, isNotNull);
      final vocabFields = vocabIndex['fields'] as List<dynamic>;
      expect(vocabFields[0]['fieldPath'], 'categoryId');
      expect(vocabFields[0]['order'], 'ASCENDING');
      expect(vocabFields[1]['fieldPath'], 'difficultyLevel');
      expect(vocabFields[1]['order'], 'ASCENDING');

      // 3. progressRecords: childId ASC, date DESC
      final progressIndex = indexes.firstWhere(
        (idx) => idx['collectionGroup'] == 'progressRecords',
        orElse: () => null,
      );
      expect(progressIndex, isNotNull);
      final progressFields = progressIndex['fields'] as List<dynamic>;
      expect(progressFields[0]['fieldPath'], 'childId');
      expect(progressFields[0]['order'], 'ASCENDING');
      expect(progressFields[1]['fieldPath'], 'date');
      expect(progressFields[1]['order'], 'DESCENDING');
    });
  });

  group('Task 3: User Repository Operations and Security Scoping', () {
    late UserRepository userRepo;

    setUp(() {
      userRepo = BaseUserRepository();
    });

    test('getUserById retrieves user profile and supports fallback', () async {
      final user = await userRepo.getUserById('test_parent_uid');
      expect(user, isNotNull);
      expect(user!.role, isIn(['parent', 'educator']));
      expect(user.linkedChildIds, isNotEmpty);
    });

    test('saveUser saves user profile to repository without error', () async {
      final testUser = UserModel(
        userId: 'custom_usr_01',
        email: 'teacher@school.org',
        role: 'educator',
        preferredLanguage: 'ar',
        linkedChildIds: const ['child_adam'],
        difficultyLevel: 2,
        createdAt: DateTime.now(),
      );

      await expectLater(userRepo.saveUser(testUser), completes);
    });

    test('updatePreferredLanguage updates user preference', () async {
      await expectLater(
        userRepo.updatePreferredLanguage('custom_usr_01', 'ar'),
        completes,
      );
    });

    test('getLinkedChildIds returns list of child identifiers', () async {
      final childIds = await userRepo.getLinkedChildIds('parent_test_01');
      expect(childIds, isNotEmpty);
      expect(childIds, contains('child_adam'));
    });

    test('getLinkedChildren returns scoped child profiles for parent', () async {
      final children = await userRepo.getLinkedChildren('parent_test_01');
      expect(children.length, greaterThanOrEqualTo(3));
      expect(children.map((c) => c.name), containsAll(['Adam', 'Sara', 'Omar']));
    });

    test('addChildProfile adds a child and links ID to parent', () async {
      final newChild = ChildModel(
        childId: 'child_new_01',
        parentId: 'parent_test_01',
        name: 'Zaid',
        currentDifficultyLevel: 1,
        preferredLanguage: 'ar',
        createdAt: DateTime.now(),
      );

      await expectLater(
        userRepo.addChildProfile('parent_test_01', newChild),
        completes,
      );
    });
  });

  group('Task 4: Category Repository Operations (Bilingual & 4 Categories)', () {
    late CategoryRepository categoryRepo;

    setUp(() {
      categoryRepo = BaseCategoryRepository();
    });

    test('getCategories returns all 4 foundational categories with bilingual names', () async {
      final categories = await categoryRepo.getCategories();
      expect(categories.length, 4);

      final categoryIds = categories.map((c) => c.id).toList();
      expect(categoryIds, containsAll(['letters', 'numbers', 'colours', 'animals']));

      // Check Arabic and English localized names
      final animals = categories.firstWhere((c) => c.id == 'animals');
      expect(animals.nameEn, 'Animals');
      expect(animals.nameAr, contains('حيوانات'));
      expect(animals.localizedName(false), 'Animals');
      expect(animals.localizedName(true), contains('حيوانات'));

      final letters = categories.firstWhere((c) => c.id == 'letters');
      expect(letters.nameEn, 'Letters');
      expect(letters.nameAr, contains('حروف'));
    });

    test('getCategoryById retrieves specific category model', () async {
      final numbers = await categoryRepo.getCategoryById('numbers');
      expect(numbers, isNotNull);
      expect(numbers!.id, 'numbers');
      expect(numbers.nameEn, 'Numbers');
      expect(numbers.nameAr, contains('أرقام'));

      final unknown = await categoryRepo.getCategoryById('astronomy');
      expect(unknown, isNull);
    });

    test('seedCategories saves category batch to Firestore', () async {
      await expectLater(
        categoryRepo.seedCategories(SampleDataService.sampleCategories),
        completes,
      );
    });
  });

  group('Task 5: Vocabulary Repository Operations (Filtering & Schema Fields)', () {
    late VocabularyRepository vocabRepo;

    setUp(() {
      vocabRepo = BaseVocabularyRepository();
    });

    test('getVocabularyItems returns vocabulary list with difficulty filter', () async {
      final allItems = await vocabRepo.getVocabularyItems();
      expect(allItems, isNotEmpty);

      final level1Items = await vocabRepo.getVocabularyItems(maxDifficulty: 1);
      expect(level1Items, isNotEmpty);
      for (final item in level1Items) {
        expect(item.difficultyLevel, lessThanOrEqualTo(1));
      }
    });

    test('getVocabularyForCategory retrieves items filtered by category', () async {
      final animalItems = await vocabRepo.getVocabularyForCategory('animals');
      expect(animalItems, isNotEmpty);
      for (final item in animalItems) {
        expect(item.categoryId, 'animals');
        expect(item.labelEn, isNotEmpty);
        expect(item.labelAr, isNotEmpty);
        expect(item.imageUrl, isNotEmpty);
        expect(item.audioUrlAr, isNotEmpty);
        expect(item.audioUrlEn, isNotEmpty);
      }

      final colorItems = await vocabRepo.getVocabularyForCategory('colours');
      expect(colorItems, isNotEmpty);
      for (final item in colorItems) {
        expect(item.categoryId, 'colours');
      }
    });

    test('getVocabularyItemById retrieves individual item by identifier', () async {
      final catItem = await vocabRepo.getVocabularyItemById('cat');
      expect(catItem, isNotNull);
      expect(catItem!.id, 'cat');
      expect(catItem.labelEn, 'Cat');
      expect(catItem.labelAr, contains('قِطَّة'));

      final nonExistent = await vocabRepo.getVocabularyItemById('non_existent_item');
      expect(nonExistent, isNull);
    });

    test('saveVocabularyItem and seedVocabularyItems complete successfully', () async {
      final customItem = const VocabularyItemModel(
        id: 'elephant',
        categoryId: 'animals',
        labelEn: 'Elephant',
        labelAr: 'فِيل',
        transliteration: 'Feel',
        imageUrl: 'vocabulary/images/elephant.png',
        audioUrlAr: 'vocabulary/audio/ar/elephant.mp3',
        audioUrlEn: 'vocabulary/audio/en/elephant.mp3',
        difficultyLevel: 2,
      );

      await expectLater(vocabRepo.saveVocabularyItem(customItem), completes);
      await expectLater(
        vocabRepo.seedVocabularyItems([customItem]),
        completes,
      );
    });
  });

  group('Task 6: Firebase Storage Service Access and Path Resolution', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('getVocabularyImageUrl resolves paths to standard vocabulary/images prefix', () async {
      final resolvedRelative = await storageService.getVocabularyImageUrl('cat.png');
      expect(resolvedRelative, 'vocabulary/images/cat.png');

      final resolvedPrefixed = await storageService.getVocabularyImageUrl('vocabulary/images/dog.png');
      expect(resolvedPrefixed, 'vocabulary/images/dog.png');

      // Local asset paths pass through directly
      final localAsset = await storageService.getVocabularyImageUrl('assets/cat.png');
      expect(localAsset, 'assets/cat.png');

      // HTTPS URLs pass through directly
      final httpsUrl = await storageService.getVocabularyImageUrl('https://firebasestorage.googleapis.com/test.png');
      expect(httpsUrl, 'https://firebasestorage.googleapis.com/test.png');
    });

    test('getArabicAudioUrl resolves pronunciation path for Arabic', () async {
      final resolvedAudio = await storageService.getArabicAudioUrl('cat.mp3');
      expect(resolvedAudio, 'vocabulary/audio/ar/cat.mp3');
    });

    test('getEnglishAudioUrl resolves pronunciation path for English', () async {
      final resolvedAudio = await storageService.getEnglishAudioUrl('cat.mp3');
      expect(resolvedAudio, 'vocabulary/audio/en/cat.mp3');
    });

    test('empty paths return empty string safely', () async {
      expect(await storageService.getVocabularyImageUrl(''), isEmpty);
      expect(await storageService.getArabicAudioUrl(''), isEmpty);
      expect(await storageService.getEnglishAudioUrl(''), isEmpty);
    });
  });

  group('Task 7: Learning Sessions Repository Telemetry', () {
    late SessionRepository sessionRepo;

    setUp(() {
      sessionRepo = BaseSessionRepository();
    });

    test('createSession, updateSession, and completeSession manage session lifecycle', () async {
      final session = LearningSessionModel(
        sessionId: 'session_t7_01',
        childId: 'child_adam',
        categoryId: 'animals',
        startTime: DateTime.now().subtract(const Duration(minutes: 4)),
        itemsPresented: const ['cat', 'dog'],
        score: 0.0,
      );

      await sessionRepo.createSession(session);

      final retrieved = await sessionRepo.getSessionById('session_t7_01');
      expect(retrieved, isNotNull);
      expect(retrieved!.sessionId, 'session_t7_01');
      expect(retrieved.childId, 'child_adam');
      expect(retrieved.itemsPresented, containsAll(['cat', 'dog']));

      // Complete session
      final completionTime = DateTime.now();
      await sessionRepo.completeSession(
        'session_t7_01',
        endTime: completionTime,
        score: 1.0,
      );

      final completed = await sessionRepo.getSessionById('session_t7_01');
      expect(completed, isNotNull);
      expect(completed!.score, 1.0);
      expect(completed.endTime, isNotNull);
    });

    test('getRecentSessions retrieves sessions for specific child', () async {
      final sessions = await sessionRepo.getRecentSessions('child_adam');
      expect(sessions, isNotEmpty);
      for (final s in sessions) {
        expect(s.childId, 'child_adam');
      }
    });
  });

  group('Task 8: Quiz Results Repository Attempt Logging', () {
    late QuizRepository quizRepo;

    setUp(() {
      quizRepo = BaseQuizRepository();
    });

    test('recordQuizResult stores attempt with question ID, choice, and correctness', () async {
      final result = QuizResultModel(
        resultId: 'qr_test_01',
        sessionId: 'session_t7_01',
        childId: 'child_adam',
        questionId: 'q_animals_01',
        childResponse: 'cat',
        isCorrect: true,
        responseTimeMs: 1250,
        timestamp: DateTime.now(),
      );

      await quizRepo.recordQuizResult(result);

      final sessionResults = await quizRepo.getQuizResultsForSession('session_t7_01');
      expect(sessionResults, isNotEmpty);
      expect(sessionResults.any((r) => r.resultId == 'qr_test_01'), true);

      final childResults = await quizRepo.getQuizResultsForChild('child_adam');
      expect(childResults, isNotEmpty);
      expect(childResults.any((r) => r.resultId == 'qr_test_01'), true);
    });

    test('getQuizQuestionForCategory returns structured 3-option question', () async {
      final question = await quizRepo.getQuizQuestionForCategory('animals');
      expect(question.id, isNotEmpty);
      expect(question.choices.length, 3);
      expect(question.correctChoiceId, isNotEmpty);
      expect(question.promptEn, isNotEmpty);
      expect(question.promptAr, isNotEmpty);
    });
  });

  group('Task 9: Progress Repository Analytics & Aggregation', () {
    late ProgressRepository progressRepo;

    setUp(() {
      progressRepo = BaseProgressRepository();
    });

    test('createProgressRecord stores daily summary supporting mastered items & accuracy', () async {
      final today = DateTime.now();
      final record = ProgressRecordModel(
        recordId: 'pr_test_01',
        childId: 'child_adam',
        date: today,
        itemsMastered: const ['cat', 'dog', 'one'],
        quizScores: const [100.0, 90.0],
        overallAccuracy: 0.95,
      );

      await progressRepo.createProgressRecord(record);

      final records = await progressRepo.getProgressRecordsForChild('child_adam');
      expect(records, isNotEmpty);
      expect(records.any((r) => r.recordId == 'pr_test_01'), true);

      final dateRecord = await progressRepo.getProgressByDate('child_adam', today);
      expect(dateRecord, isNotNull);
      expect(dateRecord!.overallAccuracy, 0.95);
      expect(dateRecord.itemsMastered, containsAll(['cat', 'dog', 'one']));
    });

    test('getProgressForChild returns StudentProgressModel for dashboard', () async {
      final studentProgress = await progressRepo.getProgressForChild('child_adam');
      expect(studentProgress, isNotNull);
      expect(studentProgress.studentName, isNotEmpty);
      expect(studentProgress.totalSessions, greaterThan(0));
      expect(studentProgress.overallAccuracy, inInclusiveRange(0, 100));
      expect(studentProgress.categoryAccuracies, isNotEmpty);
    });
  });

  group('Task 11: Security Rules Structure & Prohibited Credentials', () {
    test('firestore.rules restricts user profiles and child access', () {
      final rulesFile = File('firestore.rules');
      expect(rulesFile.existsSync(), true);

      final content = rulesFile.readAsStringSync();
      expect(content, contains('isOwner(userId)'));
      expect(content, contains('resource.data.parentId == request.auth.uid'));
      expect(content, contains('match /users/{userId}'));
      expect(content, contains('match /children/{childId}'));
      expect(content, contains('match /categories/{categoryId}'));
      expect(content, contains('match /vocabularyItems/{itemId}'));
      expect(content, contains('match /sessions/{sessionId}'));
      expect(content, contains('match /quizResults/{resultId}'));
      expect(content, contains('match /progressRecords/{recordId}'));

      // Ensure private credentials prohibition is documented
      expect(content, contains('Sensitive credentials/passwords must NEVER be stored here'));
    });

    test('storage.rules restricts writing to authenticated accounts', () {
      final rulesFile = File('storage.rules');
      expect(rulesFile.existsSync(), true);

      final content = rulesFile.readAsStringSync();
      expect(content, contains('match /vocabulary/{allPaths=**}'));
      expect(content, contains('allow write: if request.auth != null;'));
      expect(content, contains('match /user_uploads/{userId}/{allPaths=**}'));
    });
  });

  group('Task 12: Error Handling & UI States', () {
    test('UiState covers loading, success, empty, and error lifecycles', () {
      const loading = UiState<List<String>>.loading();
      expect(loading.isLoading, true);
      expect(loading.isSuccess, false);

      const empty = UiState<List<String>>.empty();
      expect(empty.isEmpty, true);

      const success = UiState<List<String>>.success(['apple']);
      expect(success.isSuccess, true);
      expect(success.data, contains('apple'));

      final error = UiState<List<String>>.error(
        NetworkException(message: 'Connection timed out'),
      );
      expect(error.isError, true);
      expect(error.getDisplayError(false, isChildMode: true), contains('resting'));
      expect(error.getDisplayError(true, isChildMode: true), contains('سحابة الإنترنت'));
      expect(error.getDisplayError(false), contains('Connection timed out'));
    });

    test('CategoryProvider transitions between loading and success', () async {
      final provider = CategoryProvider(categoryRepository: BaseCategoryRepository());
      expect(provider.uiState.isInitial, true);

      await provider.loadCategories();
      expect(provider.uiState.isSuccess, true);
      expect(provider.categories.length, 4);

      provider.selectCategory('animals');
      expect(provider.selectedCategory?.id, 'animals');
    });

    test('VocabularyProvider transitions between loading and success', () async {
      final provider = VocabularyProvider(
        vocabularyRepository: BaseVocabularyRepository(),
      );
      expect(provider.uiState.isInitial, true);

      await provider.loadVocabulary('animals');
      expect(provider.uiState.isSuccess, true);
      expect(provider.items, isNotEmpty);
      expect(provider.currentCategoryId, 'animals');
    });
  });

  group('Task 13 & 14: Sample Data and End-to-End Data Layer Integration', () {
    test('SampleDataService provides complete controlled development dataset', () {
      expect(SampleDataService.sampleCategories.length, 4);
      expect(SampleDataService.sampleVocabulary.length, greaterThanOrEqualTo(12));
      expect(SampleDataService.sampleParentUser.userId, 'parent_test_01');
      expect(SampleDataService.sampleChildren.length, 3);
      expect(SampleDataService.sampleSession.sessionId, 'session_sample_01');
      expect(SampleDataService.sampleQuizResult.resultId, 'quiz_sample_01');
      expect(SampleDataService.sampleProgressRecord.recordId, 'progress_sample_01');
    });

    test('End-to-End Integration Flow: User -> Children -> Categories -> Vocabulary -> Storage URLs', () async {
      final userRepo = BaseUserRepository();
      final categoryRepo = BaseCategoryRepository();
      final vocabRepo = BaseVocabularyRepository();
      final storageService = StorageService();

      // 1. Authenticated User Profile
      final user = await userRepo.getUserById('parent_test_01');
      expect(user, isNotNull);
      expect(user!.linkedChildIds, isNotEmpty);

      // 2. Child Selection
      final children = await userRepo.getLinkedChildren(user.userId);
      expect(children, isNotEmpty);
      final selectedChild = children.first;
      expect(selectedChild.name, 'Adam');

      // 3. Load Categories
      final categories = await categoryRepo.getCategories();
      expect(categories.length, 4);
      final selectedCategory = categories.firstWhere((c) => c.id == 'animals');

      // 4. Load Vocabulary for Selected Category and Difficulty Level
      final vocabList = await vocabRepo.getVocabularyForCategory(
        selectedCategory.id,
        maxDifficulty: selectedChild.currentDifficultyLevel,
      );
      expect(vocabList, isNotEmpty);

      // 5. Resolve Media Assets via StorageService
      final firstItem = vocabList.first;
      final resolvedImage = await storageService.getVocabularyImageUrl(firstItem.imageUrl);
      final resolvedAudioAr = await storageService.getArabicAudioUrl(firstItem.audioUrlAr);
      final resolvedAudioEn = await storageService.getEnglishAudioUrl(firstItem.audioUrlEn);

      expect(resolvedImage, contains('vocabulary/images/'));
      expect(resolvedAudioAr, contains('vocabulary/audio/ar/'));
      expect(resolvedAudioEn, contains('vocabulary/audio/en/'));
    });
  });
}
