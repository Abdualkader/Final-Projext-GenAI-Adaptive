import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:asd_learning_assistant/core/constants/app_colors.dart';
import 'package:asd_learning_assistant/core/constants/app_routes.dart';
import 'package:asd_learning_assistant/core/errors/app_exceptions.dart';
import 'package:asd_learning_assistant/core/errors/ui_state.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:asd_learning_assistant/core/utils/content_validator.dart';
import 'package:asd_learning_assistant/core/utils/ui_helpers.dart';
import 'package:asd_learning_assistant/models/category_model.dart';
import 'package:asd_learning_assistant/models/vocabulary_item_model.dart';
import 'package:asd_learning_assistant/providers/category_provider.dart';
import 'package:asd_learning_assistant/providers/vocabulary_provider.dart';
import 'package:asd_learning_assistant/repositories/category_repository.dart';
import 'package:asd_learning_assistant/repositories/vocabulary_repository.dart';
import 'package:asd_learning_assistant/screens/child/category_selection_screen.dart';
import 'package:asd_learning_assistant/screens/child/vocabulary_learning_screen.dart';
import 'package:asd_learning_assistant/services/audio_service.dart';
import 'package:asd_learning_assistant/services/sample_data_service.dart';
import 'package:asd_learning_assistant/services/storage_service.dart';
import 'package:asd_learning_assistant/widgets/app_error_widget.dart';
import 'package:asd_learning_assistant/widgets/empty_state_widget.dart';
import 'package:asd_learning_assistant/widgets/loading_widget.dart';
import 'package:asd_learning_assistant/widgets/vocabulary_card.dart';

/// Test wrapper providing MaterialApp, localizations, and optional providers.
Widget _buildTestApp({
  required Widget child,
  CategoryProvider? categoryProvider,
  VocabularyProvider? vocabularyProvider,
  Locale locale = const Locale('en'),
}) {
  return MultiProvider(
    providers: [
      if (categoryProvider != null)
        ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider)
      else
        ChangeNotifierProvider<CategoryProvider>(create: (_) => CategoryProvider()),
      if (vocabularyProvider != null)
        ChangeNotifierProvider<VocabularyProvider>.value(value: vocabularyProvider)
      else
        ChangeNotifierProvider<VocabularyProvider>(create: (_) => VocabularyProvider()),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        AppRoutes.childLearning: (context) {
          final catId = ModalRoute.of(context)?.settings.arguments as String? ?? 'animals';
          return VocabularyLearningScreen(categoryId: catId);
        },
      },
      home: child,
    ),
  );
}

void main() {
  group('Week 8 - Task 2: Categories Model and Repository', () {
    late CategoryRepository categoryRepo;

    setUp(() {
      categoryRepo = BaseCategoryRepository();
    });

    test('Loads the four primary categories with required fields', () async {
      final categories = await categoryRepo.getCategories();

      expect(categories.length, greaterThanOrEqualTo(4));

      final categoryIds = categories.map((c) => c.categoryId).toList();
      expect(categoryIds, contains('letters'));
      expect(categoryIds, contains('numbers'));
      expect(categoryIds.any((id) => id == 'colours' || id == 'colors'), isTrue);
      expect(categoryIds, contains('animals'));

      for (final cat in categories) {
        expect(cat.categoryId, isNotEmpty);
        expect(cat.nameAr, isNotEmpty);
        expect(cat.nameEn, isNotEmpty);
        expect(cat.isValid, isTrue);
      }
    });

    test('Category names support Arabic and English localization', () async {
      final animals = await categoryRepo.getCategoryById('animals');
      expect(animals, isNotNull);
      expect(animals!.localizedName(false), 'Animals');
      expect(animals.localizedName(true), 'الحيوانات');

      final letters = await categoryRepo.getCategoryById('letters');
      expect(letters, isNotNull);
      expect(letters!.localizedName(false), 'Letters');
      expect(letters.localizedName(true), 'الحروف');
    });

    test('getCategoryById resolves both "colors" and "colours"', () async {
      final byColours = await categoryRepo.getCategoryById('colours');
      final byColors = await categoryRepo.getCategoryById('colors');

      expect(byColours, isNotNull);
      expect(byColors, isNotNull);
      expect(byColours!.nameEn, 'Colors');
      expect(byColors!.nameEn, 'Colors');
    });

    test('CategoryModel.fromMap correctly populates themed colors and icons', () {
      final model = CategoryModel.fromMap({
        'categoryId': 'numbers',
        'nameEn': 'Numbers',
        'nameAr': 'الأرقام',
      });

      expect(model.id, 'numbers');
      expect(model.nameEn, 'Numbers');
      expect(model.nameAr, 'الأرقام');
      expect(model.backgroundColor, AppColors.cardNumbers);
      expect(model.textColor, AppColors.textNumbers);
      expect(model.borderColor, AppColors.borderNumbers);
      expect(model.icon, Icons.looks_one_rounded);
    });
  });

  group('Week 8 - Task 3 & 4: Vocabulary Dataset & Difficulty System', () {
    late VocabularyRepository vocabRepo;

    setUp(() {
      vocabRepo = BaseVocabularyRepository();
    });

    test('Sample dataset contains vocabulary items across all 4 categories', () {
      final dataset = SampleDataService.sampleVocabulary;
      expect(dataset.length, greaterThanOrEqualTo(16));

      final categoriesInDataset = dataset.map((i) => i.categoryId).toSet();
      expect(categoriesInDataset, contains('animals'));
      expect(categoriesInDataset, contains('colours'));
      expect(categoriesInDataset, contains('numbers'));
      expect(categoriesInDataset, contains('letters'));
    });

    test('Every vocabulary item contains all required fields', () {
      final dataset = SampleDataService.sampleVocabulary;

      for (final item in dataset) {
        expect(item.itemId, isNotEmpty, reason: 'itemId should not be empty');
        expect(item.categoryId, isNotEmpty, reason: 'categoryId should not be empty');
        expect(item.labelAr, isNotEmpty, reason: 'labelAr should not be empty');
        expect(item.labelEn, isNotEmpty, reason: 'labelEn should not be empty');
        expect(item.imageUrl, isNotEmpty, reason: 'imageUrl should not be empty');
        expect(item.difficultyLevel, isIn([1, 2, 3]), reason: 'difficultyLevel should be 1, 2, or 3');
        expect(item.audioUrlAr, isNotEmpty);
        expect(item.audioUrlEn, isNotEmpty);
        expect(item.isValid, isTrue);
      }
    });

    test('Supports difficulty levels 1 (Easy), 2 (Medium), and 3 (Hard)', () async {
      final allItems = await vocabRepo.getVocabularyItems();

      final easyItems = allItems.where((i) => i.difficultyLevel == 1).toList();
      final mediumItems = allItems.where((i) => i.difficultyLevel == 2).toList();
      final hardItems = allItems.where((i) => i.difficultyLevel == 3).toList();

      expect(easyItems, isNotEmpty, reason: 'Should have Easy items (Level 1)');
      expect(mediumItems, isNotEmpty, reason: 'Should have Medium items (Level 2)');
      expect(hardItems, isNotEmpty, reason: 'Should have Hard items (Level 3)');

      // Filter by maxDifficulty = 1
      final onlyEasy = await vocabRepo.getVocabularyItems(maxDifficulty: 1);
      expect(onlyEasy.every((i) => i.difficultyLevel <= 1), isTrue);

      // Filter by maxDifficulty = 2
      final easyAndMedium = await vocabRepo.getVocabularyItems(maxDifficulty: 2);
      expect(easyAndMedium.every((i) => i.difficultyLevel <= 2), isTrue);
      expect(easyAndMedium.length, greaterThan(onlyEasy.length));
    });
  });

  group('Week 8 - Task 5 & 6: Storage Service, Images & Audio Paths', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('Generates structured category storage image path', () {
      final animalImg = storageService.getVocabularyImagePath(categoryId: 'animals', fileName: 'cat.png');
      expect(animalImg, 'storage/vocabulary/animals/cat.png');

      final colorImg = storageService.getVocabularyImagePath(categoryId: 'colors', fileName: 'red.png');
      expect(colorImg, 'storage/vocabulary/colors/red.png');
    });

    test('Generates structured bilingual audio storage paths', () {
      final arAudio = storageService.getVocabularyAudioPath(
        categoryId: 'animals',
        fileName: 'cat.mp3',
        isArabic: true,
      );
      expect(arAudio, 'storage/vocabulary/animals/audio/ar/cat.mp3');

      final enAudio = storageService.getVocabularyAudioPath(
        categoryId: 'animals',
        fileName: 'cat.mp3',
        isArabic: false,
      );
      expect(enAudio, 'storage/vocabulary/animals/audio/en/cat.mp3');
    });

    test('resolveMediaUrl preserves HTTP URLs and assets', () async {
      const httpUrl = 'https://firebasestorage.googleapis.com/v0/b/app/cat.png';
      expect(await storageService.resolveMediaUrl(httpUrl), httpUrl);

      const assetPath = 'assets/images/cat.png';
      expect(await storageService.resolveMediaUrl(assetPath), assetPath);
    });
  });

  group('Week 8 - Task 7 & 11: Bilingual Labels and Audio Preview', () {
    test('localizedWord returns correct label based on language selection', () {
      const item = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'vocabulary/images/cat.png',
        difficultyLevel: 1,
      );

      expect(item.localizedWord(false), 'Cat');
      expect(item.localizedWord(true), 'قِطَّة');
    });

    test('VocabularyProvider plays Arabic and English audio safely without crash', () async {
      final provider = VocabularyProvider();
      await provider.loadVocabulary('animals');

      expect(provider.items, isNotEmpty);
      final firstItem = provider.currentItem!;

      // Play Arabic audio
      await provider.playAudioFor(firstItem, isArabic: true);
      expect(provider.isPlayingAudio, isFalse);

      // Play English audio
      await provider.playAudioFor(firstItem, isArabic: false);
      expect(provider.isPlayingAudio, isFalse);

      // Missing audio on custom item should not crash
      const itemWithoutAudio = VocabularyItemModel(
        id: 'silent_test',
        categoryId: 'animals',
        labelEn: 'Silent',
        labelAr: 'صامت',
        imageUrl: 'test.png',
        audioUrlAr: '',
        audioUrlEn: '',
      );

      await expectLater(
        provider.playAudioFor(itemWithoutAudio, isArabic: true),
        completes,
      );
    });
  });

  group('Week 8 - Task 8: Category Filtering Flow', () {
    late VocabularyRepository vocabRepo;

    setUp(() {
      vocabRepo = BaseVocabularyRepository();
    });

    test('Select Category -> Load Vocabulary -> Filter by Category for all 4 domains', () async {
      // 1. Letters
      final letters = await vocabRepo.getVocabularyForCategory('letters');
      expect(letters, isNotEmpty);
      expect(letters.every((i) => i.categoryId == 'letters'), isTrue);

      // 2. Numbers
      final numbers = await vocabRepo.getVocabularyForCategory('numbers');
      expect(numbers, isNotEmpty);
      expect(numbers.every((i) => i.categoryId == 'numbers'), isTrue);

      // 3. Colors (supports both 'colours' and 'colors')
      final colours = await vocabRepo.getVocabularyForCategory('colours');
      expect(colours, isNotEmpty);
      expect(colours.every((i) => i.categoryId == 'colours' || i.categoryId == 'colors'), isTrue);

      final colors = await vocabRepo.getVocabularyForCategory('colors');
      expect(colors, isNotEmpty);
      expect(colors.length, colours.length);

      // 4. Animals
      final animals = await vocabRepo.getVocabularyForCategory('animals');
      expect(animals, isNotEmpty);
      expect(animals.every((i) => i.categoryId == 'animals'), isTrue);
    });
  });

  group('Week 8 - Task 9: Vocabulary Loading States', () {
    test('VocabularyProvider handles loading, success, and empty states cleanly', () async {
      final provider = VocabularyProvider();

      expect(provider.uiState.isInitial, isTrue);

      // Load existing category -> Success
      final loadFuture = provider.loadVocabulary('animals');
      expect(provider.uiState.isLoading, isTrue);
      await loadFuture;
      expect(provider.uiState.isSuccess, isTrue);
      expect(provider.items, isNotEmpty);

      // Load non-existent category -> Empty state
      await provider.loadVocabulary('unknown_category_xyz');
      expect(provider.uiState.isEmpty, isTrue);
      expect(provider.items, isEmpty);
    });
  });

  group('Week 8 - Task 12: Content Validation', () {
    test('ContentValidator validates valid items and filters invalid ones', () {
      const validItem = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'cat.png',
        difficultyLevel: 1,
      );
      expect(ContentValidator.isValidVocabularyItem(validItem), isTrue);

      // Missing id
      const invalidNoId = VocabularyItemModel(
        id: '',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'cat.png',
      );
      expect(ContentValidator.isValidVocabularyItem(invalidNoId), isFalse);

      // Invalid category
      const invalidCat = VocabularyItemModel(
        id: 'cat',
        categoryId: 'unknown_cat',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'cat.png',
      );
      expect(ContentValidator.isValidVocabularyItem(invalidCat), isFalse);

      // Missing labelAr
      const invalidNoAr = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: '',
        imageUrl: 'cat.png',
      );
      expect(ContentValidator.isValidVocabularyItem(invalidNoAr), isFalse);

      // Missing labelEn
      const invalidNoEn = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: '',
        labelAr: 'قِطَّة',
        imageUrl: 'cat.png',
      );
      expect(ContentValidator.isValidVocabularyItem(invalidNoEn), isFalse);

      // Missing imageUrl
      const invalidNoImg = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: '',
      );
      expect(ContentValidator.isValidVocabularyItem(invalidNoImg), isFalse);

      // Invalid difficultyLevel (> 3 or < 1)
      const invalidDiff = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'cat.png',
        difficultyLevel: 5,
      );
      expect(ContentValidator.isValidVocabularyItem(invalidDiff), isFalse);

      // filterValidItems cleans dirty list
      final mixed = [validItem, invalidNoId, invalidNoImg, invalidDiff];
      final filtered = ContentValidator.filterValidItems(mixed);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'cat');
    });

    test('ContentValidator validates categories', () {
      const validCategory = CategoryModel(
        id: 'animals',
        nameEn: 'Animals',
        nameAr: 'الحيوانات',
      );
      expect(ContentValidator.isValidCategory(validCategory), isTrue);

      const invalidNoName = CategoryModel(
        id: 'animals',
        nameEn: '',
        nameAr: '',
      );
      expect(ContentValidator.isValidCategory(invalidNoName), isFalse);
    });
  });

  group('Week 8 - Task 13: UI Widget Tests across all 4 categories', () {
    testWidgets('Letters category loads, displays bilingual labels, difficulty, image and audio',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('letters');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'letters'),
        ),
      );
      await tester.pumpAndSettle();

      // Check category pill and progress
      expect(find.text('Letters'), findsWidgets);

      // Check letter vocabulary labels
      expect(find.text('Letter A'), findsOneWidget);
      expect(find.text('أَلِف'), findsOneWidget);

      // Check difficulty level
      expect(find.text('Level 1: Easy'), findsOneWidget);

      // Check audio buttons
      expect(find.text('🔊  Play Audio'), findsOneWidget);

      // Tap audio button and verify safe playback
      await tester.tap(find.text('🔊  Play Audio'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔊 Letter A • أَلِف'), findsOneWidget);

      // Navigate Next item
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Letter B'), findsOneWidget);
      expect(find.text('بَاء'), findsOneWidget);
    });

    testWidgets('Numbers category loads, displays bilingual labels, and difficulty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('numbers');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'numbers'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Numbers'), findsWidgets);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('وَاحِد'), findsOneWidget);
      expect(find.text('Level 1: Easy'), findsOneWidget);

      // Advance to Two
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('اِثْنَان'), findsOneWidget);
    });

    testWidgets('Colors category loads, displays bilingual labels, and difficulty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('colours');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'colours'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Colours'), findsWidgets);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('أَحْمَر'), findsOneWidget);
      expect(find.text('Level 1: Easy'), findsOneWidget);

      // Advance to Blue
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('أَزْرَق'), findsOneWidget);
    });

    testWidgets('Animals category loads, displays bilingual labels, and difficulty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final vocabProvider = VocabularyProvider();
      await vocabProvider.loadVocabulary('animals');

      await tester.pumpWidget(
        _buildTestApp(
          vocabularyProvider: vocabProvider,
          child: const VocabularyLearningScreen(categoryId: 'animals'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Animals'), findsWidgets);
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('قِطَّة'), findsOneWidget);
      expect(find.text('Level 1: Easy'), findsOneWidget);

      // Advance to Dog
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('كَلْب'), findsOneWidget);
    });

    testWidgets('CategorySelectionScreen renders categories from provider and navigates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final catProvider = CategoryProvider();
      await catProvider.loadCategories();

      await tester.pumpWidget(
        _buildTestApp(
          categoryProvider: catProvider,
          child: const CategorySelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose a Category'), findsOneWidget);
      expect(find.text('Letters'), findsOneWidget);
      expect(find.text('Numbers'), findsOneWidget);
      expect(find.text('Colors'), findsOneWidget);
      expect(find.text('Animals'), findsOneWidget);

      // Tap Animals category card
      await tester.tap(find.text('Animals'));
      await tester.pumpAndSettle();

      // Verify navigation to learning screen
      expect(find.byType(VocabularyLearningScreen), findsOneWidget);
    });

    testWidgets('VocabularyCard fallback UI displays gracefully when image fails or is missing',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const itemWithBrokenImage = VocabularyItemModel(
        id: 'cat',
        categoryId: 'animals',
        labelEn: 'Cat',
        labelAr: 'قِطَّة',
        imageUrl: 'https://invalid-non-existent-domain.xyz/broken.png',
        difficultyLevel: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VocabularyCard(
              item: itemWithBrokenImage,
              onPlayAudio: () {},
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify fallback illustration displays without error
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('قِطَّة'), findsOneWidget);
      expect(find.text('🐱 Cat / قطة'), findsOneWidget);
    });
  });
}
