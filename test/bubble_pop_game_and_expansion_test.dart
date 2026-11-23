import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asd_learning_assistant/models/quiz_question_model.dart';
import 'package:asd_learning_assistant/repositories/mock_data_repository.dart';
import 'package:asd_learning_assistant/screens/child/bubble_pop_game_screen.dart';
import 'package:asd_learning_assistant/services/ai_adaptive_service.dart';
import 'package:asd_learning_assistant/services/audio_service.dart';
import 'package:asd_learning_assistant/widgets/quiz_choice_card.dart';

class MockAudioService implements AudioService {
  int successChimeCount = 0;
  int retryChimeCount = 0;
  List<String> spokenPrompts = [];

  @override
  double get volume => 0.8;

  @override
  bool get isPlaying => false;

  @override
  String? get currentAudioSource => null;

  @override
  void setVolume(double volume) {}

  @override
  Future<void> playSuccessChime() async {
    successChimeCount++;
  }

  @override
  Future<void> playGentleRetryChime() async {
    retryChimeCount++;
  }

  @override
  Future<void> playVocabularyAudio(
    String audioSource, {
    String? wordText,
    String? language,
  }) async {
    spokenPrompts.add('$audioSource ($language)');
  }

  @override
  Future<void> speakText(String text, {String language = 'en'}) async {
    spokenPrompts.add('$text ($language)');
  }

  @override
  Future<void> stop() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain Expansion Tests (Numbers 1-10 & All 28 Arabic Letters)', () {
    test('Numbers category contains numbers 1 through 10 with audio and transliterations', () {
      final numbers = MockDataRepository.getVocabularyForCategory('numbers');
      expect(numbers.length, 10);

      final ids = numbers.map((item) => item.id).toList();
      expect(ids, [
        'one', 'two', 'three', 'four', 'five',
        'six', 'seven', 'eight', 'nine', 'ten',
      ]);

      // Check Arabic names and audio
      final six = numbers.firstWhere((item) => item.id == 'six');
      expect(six.wordEn, 'Six');
      expect(six.wordAr, 'سِتَّة');
      expect(six.audioUrlEn.contains('vocabulary/audio/en/six.mp3'), isTrue);

      final ten = numbers.firstWhere((item) => item.id == 'ten');
      expect(ten.wordEn, 'Ten');
      expect(ten.wordAr, 'عَشَرَة');
      expect(ten.audioUrlEn.contains('vocabulary/audio/en/ten.mp3'), isTrue);
    });

    test('Letters category contains all 28 Arabic letters', () {
      final letters = MockDataRepository.getVocabularyForCategory('letters');
      expect(letters.length, 28);

      final letterIds = letters.map((l) => l.id).toList();
      expect(letterIds.contains('alif'), isTrue);
      expect(letterIds.contains('baa'), isTrue);
      expect(letterIds.contains('taa'), isTrue);
      expect(letterIds.contains('thaa'), isTrue);
      expect(letterIds.contains('jeem'), isTrue);
      expect(letterIds.contains('noon'), isTrue);
      expect(letterIds.contains('waaw'), isTrue);
      expect(letterIds.contains('yaa'), isTrue);
    });

    test('AiAdaptiveService allowedCategoryVocabulary includes 1..10 and all 28 letters', () {
      final allowedNumbers = BaseAiAdaptiveService.allowedCategoryVocabulary['numbers'];
      expect(allowedNumbers, isNotNull);
      expect(allowedNumbers!.length, 10);
      expect(allowedNumbers.contains('ten'), isTrue);

      final allowedLetters = BaseAiAdaptiveService.allowedCategoryVocabulary['letters'];
      expect(allowedLetters, isNotNull);
      expect(allowedLetters!.length >= 28, isTrue);
      expect(allowedLetters.contains('yaa'), isTrue);
    });
  });

  group('Visual Option Cards (QuizChoiceCard) Tests', () {
    testWidgets('Renders Arabic calligraphy badge for letter choice', (WidgetTester tester) async {
      const choice = QuizChoice(
        id: 'baa',
        labelEn: 'Baa',
        labelAr: 'باء',
        imageUrl: '',
        icon: Icons.menu_book_rounded,
        accentColor: Color(0xFF0288D1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 200,
              child: QuizChoiceCard(
                choice: choice,
                isSelected: false,
                isArabic: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify letter glyph 'ب' renders
      expect(find.text('ب'), findsOneWidget);
      expect(find.text('باء'), findsOneWidget);
    });

    testWidgets('Renders number digit badge for number choice', (WidgetTester tester) async {
      const choice = QuizChoice(
        id: 'seven',
        labelEn: 'Seven',
        labelAr: 'سبعة',
        imageUrl: '',
        icon: Icons.pin_rounded,
        accentColor: Color(0xFF8B5CF6),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 200,
              child: QuizChoiceCard(
                choice: choice,
                isSelected: false,
                isArabic: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify digit '7' renders
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Seven'), findsOneWidget);
    });

    testWidgets('Listen button previews choice audio', (WidgetTester tester) async {
      bool listened = false;
      const choice = QuizChoice(
        id: 'cat',
        labelEn: 'Cat',
        labelAr: 'قطة',
        imageUrl: '',
        icon: Icons.pets_rounded,
        accentColor: Color(0xFF10B981),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 200,
              child: QuizChoiceCard(
                choice: choice,
                isSelected: false,
                isArabic: false,
                onTap: () {},
                onListen: () {
                  listened = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap small preview audio icon
      await tester.tap(find.byIcon(Icons.volume_down_rounded));
      await tester.pump();

      expect(listened, isTrue);
    });
  });

  group('Bubble Pop Learning Game Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Renders BubblePopGameScreen with floating bubbles and target prompt',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockAudio = MockAudioService();

      await tester.pumpWidget(
        MaterialApp(
          home: BubblePopGameScreen(
            categoryId: 'letters',
            totalRounds: 3,
            audioService: mockAudio,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Top indicator
      expect(find.textContaining('Round 1 / 3'), findsOneWidget);

      // Verify prompt speaker and bubbles rendered
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      expect(find.textContaining('Target to pop:'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
