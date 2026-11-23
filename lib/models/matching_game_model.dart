import 'package:flutter/material.dart';
import 'vocabulary_item_model.dart';

/// Type of matching card representation
enum MatchingCardType {
  image,
  word,
}

/// A single interactive card in the ASD Matching Game.
class MatchingCard {
  final String id;
  final String pairId;
  final MatchingCardType type;
  final String wordEn;
  final String wordAr;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;
  final bool isMatched;
  final bool isFaceUp;

  const MatchingCard({
    required this.id,
    required this.pairId,
    required this.type,
    required this.wordEn,
    required this.wordAr,
    this.imageUrl = '',
    this.icon = Icons.star_rounded,
    this.accentColor = const Color(0xFF3B82F6),
    this.isMatched = false,
    this.isFaceUp = false,
  });

  bool get isWord => type == MatchingCardType.word;
  bool get isImage => type == MatchingCardType.image;

  String localizedLabel(bool isArabic) => isArabic ? wordAr : wordEn;

  MatchingCard copyWith({
    String? id,
    String? pairId,
    MatchingCardType? type,
    String? wordEn,
    String? wordAr,
    String? imageUrl,
    IconData? icon,
    Color? accentColor,
    bool? isMatched,
    bool? isFaceUp,
  }) {
    return MatchingCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      type: type ?? this.type,
      wordEn: wordEn ?? this.wordEn,
      wordAr: wordAr ?? this.wordAr,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      isMatched: isMatched ?? this.isMatched,
      isFaceUp: isFaceUp ?? this.isFaceUp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pairId': pairId,
      'type': type.name,
      'wordEn': wordEn,
      'wordAr': wordAr,
      'imageUrl': imageUrl,
      'accentColor': accentColor.value,
      'isMatched': isMatched,
      'isFaceUp': isFaceUp,
    };
  }
}

/// A complete round of the AI-adaptive matching game.
class MatchingGameRound {
  final String gameId;
  final String categoryId;
  final int difficultyLevel;
  final List<MatchingCard> cards;
  final int totalPairs;
  final String promptEn;
  final String promptAr;

  const MatchingGameRound({
    required this.gameId,
    required this.categoryId,
    required this.difficultyLevel,
    required this.cards,
    required this.totalPairs,
    this.promptEn = 'Match each picture with its word!',
    this.promptAr = 'طابق كل صورة مع كلمتها المناسبة!',
  });

  bool get isCompleted => cards.every((c) => c.isMatched);

  int get matchedPairsCount =>
      cards.where((c) => c.isMatched && c.isImage).length;

  MatchingGameRound copyWith({
    String? gameId,
    String? categoryId,
    int? difficultyLevel,
    List<MatchingCard>? cards,
    int? totalPairs,
    String? promptEn,
    String? promptAr,
  }) {
    return MatchingGameRound(
      gameId: gameId ?? this.gameId,
      categoryId: categoryId ?? this.categoryId,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      cards: cards ?? this.cards,
      totalPairs: totalPairs ?? this.totalPairs,
      promptEn: promptEn ?? this.promptEn,
      promptAr: promptAr ?? this.promptAr,
    );
  }
}
