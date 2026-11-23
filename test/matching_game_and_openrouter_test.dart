import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/models/matching_game_model.dart';
import 'package:asd_learning_assistant/services/ai_adaptive_service.dart';
import 'package:asd_learning_assistant/services/openrouter_service.dart';

void main() {
  group('OpenRouterService Configuration & Free Models', () {
    late OpenRouterService openRouterService;

    setUp(() {
      openRouterService = OpenRouterService();
    });

    test('default model is Llama 3.3 70B Instruct', () {
      expect(openRouterService.model, equals('meta-llama/llama-3.3-70b-instruct'));
    });

    test('recognized models list includes leading open-weights Llama and Gemma LLMs', () {
      expect(
        OpenRouterService.availableFreeModels,
        contains('meta-llama/llama-3.3-70b-instruct'),
      );
      expect(
        OpenRouterService.availableFreeModels,
        contains('google/gemma-3-27b-it'),
      );
    });

    test('configure method updates API key and model', () {
      openRouterService.configure(
        apiKey: 'mock-openrouter-key-123',
        model: 'google/gemma-3-27b-it',
      );
      expect(openRouterService.hasApiKey, isTrue);
      expect(openRouterService.apiKey, equals('mock-openrouter-key-123'));
      expect(openRouterService.model, equals('google/gemma-3-27b-it'));
    });

    test('testConnection returns failure when no API key provided', () async {
      openRouterService.configure(apiKey: '');
      final result = await openRouterService.testConnection();
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('No OpenRouter API key provided'));
    });
  });

  group('Matching Game Data Model & Card Mechanics', () {
    test('creates image card and word card correctly', () {
      const pictureCard = MatchingCard(
        id: 'img_cat_1',
        pairId: 'cat',
        type: MatchingCardType.image,
        wordEn: 'Cat',
        wordAr: 'قطة',
        icon: Icons.pets_rounded,
        accentColor: Colors.amber,
      );

      const wordCard = MatchingCard(
        id: 'word_cat_1',
        pairId: 'cat',
        type: MatchingCardType.word,
        wordEn: 'Cat',
        wordAr: 'قطة',
        icon: Icons.text_fields_rounded,
        accentColor: Colors.amber,
      );

      expect(pictureCard.isImage, isTrue);
      expect(pictureCard.isWord, isFalse);
      expect(wordCard.isWord, isTrue);
      expect(wordCard.isImage, isFalse);
      expect(pictureCard.pairId, equals(wordCard.pairId));
    });

    test('copyWith updates state correctly', () {
      const card = MatchingCard(
        id: 'img_dog',
        pairId: 'dog',
        type: MatchingCardType.image,
        wordEn: 'Dog',
        wordAr: 'كلب',
        icon: Icons.pets_rounded,
      );

      final matched = card.copyWith(isMatched: true, isFaceUp: false);
      expect(matched.isMatched, isTrue);
      expect(matched.isFaceUp, isFalse);
      expect(matched.id, equals('img_dog'));
    });

    test('MatchingGameRound calculates totalPairs and initial isCompleted state', () {
      const cardsList = [
        MatchingCard(
          id: 'p1',
          pairId: 'cat',
          type: MatchingCardType.image,
          wordEn: 'Cat',
          wordAr: 'قطة',
        ),
        MatchingCard(
          id: 'w1',
          pairId: 'cat',
          type: MatchingCardType.word,
          wordEn: 'Cat',
          wordAr: 'قطة',
        ),
        MatchingCard(
          id: 'p2',
          pairId: 'dog',
          type: MatchingCardType.image,
          wordEn: 'Dog',
          wordAr: 'كلب',
        ),
        MatchingCard(
          id: 'w2',
          pairId: 'dog',
          type: MatchingCardType.word,
          wordEn: 'Dog',
          wordAr: 'كلب',
        ),
      ];

      final round = MatchingGameRound(
        gameId: 'round_test_1',
        categoryId: 'animals',
        difficultyLevel: 1,
        totalPairs: 2,
        cards: cardsList,
      );

      expect(round.totalPairs, equals(2));
      expect(round.isCompleted, isFalse);

      final completedRound = round.copyWith(
        cards: round.cards.map((c) => c.copyWith(isMatched: true)).toList(),
      );
      expect(completedRound.isCompleted, isTrue);
    });
  });

  group('AiAdaptiveService.generateMatchingGameRound', () {
    late BaseAiAdaptiveService aiService;

    setUp(() {
      aiService = BaseAiAdaptiveService();
    });

    test('generates sensory-safe 2-pair round for difficulty level 1', () async {
      final round = await aiService.generateMatchingGameRound(
        categoryId: 'animals',
        difficultyLevel: 1,
        preferredLanguage: 'en',
      );

      expect(round.categoryId, equals('animals'));
      expect(round.difficultyLevel, equals(1));
      // Level 1: 2 pairs = 4 cards total (2 image + 2 word)
      expect(round.cards.length, equals(4));
      expect(round.totalPairs, equals(2));

      final imageCards = round.cards.where((c) => c.isImage).toList();
      final wordCards = round.cards.where((c) => c.isWord).toList();
      expect(imageCards.length, equals(2));
      expect(wordCards.length, equals(2));

      // Each image card should have a corresponding word card with same pairId
      for (final p in imageCards) {
        expect(wordCards.any((w) => w.pairId == p.pairId), isTrue);
      }
    });

    test('generates 3-pair round for difficulty level 2', () async {
      final round = await aiService.generateMatchingGameRound(
        categoryId: 'colours',
        difficultyLevel: 2,
        preferredLanguage: 'ar',
      );

      expect(round.categoryId, equals('colours'));
      // Level 2: 3 pairs = 6 cards
      expect(round.cards.length, equals(6));
      expect(round.totalPairs, equals(3));
    });

    test('generates 4-pair round for difficulty level 3', () async {
      final round = await aiService.generateMatchingGameRound(
        categoryId: 'animals',
        difficultyLevel: 3,
        preferredLanguage: 'en',
      );

      expect(round.categoryId, equals('animals'));
      // Level 3: 4 pairs = 8 cards
      expect(round.cards.length, equals(8));
      expect(round.totalPairs, equals(4));
    });

    test('resolves proper calm icons for numbers, letters, and colours', () {
      final numIcon = BaseAiAdaptiveService.resolveIcon('one');
      expect(numIcon, equals(Icons.pin_rounded));

      final letterIcon = BaseAiAdaptiveService.resolveIcon('alef');
      expect(letterIcon, equals(Icons.menu_book_rounded));

      final color = BaseAiAdaptiveService.resolveColor('blue');
      expect(color, equals(const Color(0xFF3B82F6)));
    });
  });
}
