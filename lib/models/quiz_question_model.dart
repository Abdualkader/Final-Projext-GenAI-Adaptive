import 'package:flutter/material.dart';
import 'vocabulary_item_model.dart';

/// Single interactive answer choice card in a multiple-choice quiz question.
class QuizChoice {
  final String id;
  final String labelEn;
  final String labelAr;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;
  final VocabularyItemModel? vocabularyItem;

  const QuizChoice({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    this.imageUrl = '',
    this.icon = Icons.star_rounded,
    this.accentColor = const Color(0xFF3B82F6),
    this.vocabularyItem,
  });

  String get itemId => id;
  String get wordEn => labelEn;
  String get wordAr => labelAr;

  String localizedLabel(bool isArabic) => isArabic ? labelAr : labelEn;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'labelEn': labelEn,
      'labelAr': labelAr,
      'imageUrl': imageUrl,
      'accentColor': accentColor.value,
      if (vocabularyItem != null) 'vocabularyItem': vocabularyItem!.toMap(),
    };
  }

  factory QuizChoice.fromMap(Map<String, dynamic> map) {
    return QuizChoice(
      id: map['id'] as String? ?? '',
      labelEn: map['labelEn'] as String? ?? '',
      labelAr: map['labelAr'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      icon: Icons.star_rounded,
      accentColor: map['accentColor'] != null
          ? Color(map['accentColor'] as int)
          : const Color(0xFF3B82F6),
      vocabularyItem: map['vocabularyItem'] != null
          ? VocabularyItemModel.fromMap(map['vocabularyItem'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Model representing an interactive multiple-choice quiz question (Week 10 Task 3).
/// Supports questionId, questionText, correctItemId, options[], categoryId, and difficultyLevel.
class QuizQuestionModel {
  final String id;
  final String promptEn;
  final String promptAr;
  final String correctChoiceId;
  final List<QuizChoice> choices;
  final String categoryId;
  final int difficultyLevel;
  final VocabularyItemModel? targetItem;

  const QuizQuestionModel({
    required this.id,
    required this.promptEn,
    required this.promptAr,
    required this.correctChoiceId,
    required this.choices,
    this.categoryId = 'animals',
    this.difficultyLevel = 1,
    this.targetItem,
  });

  // Task 3 Specification Getters
  String get questionId => id;
  String get questionText => promptEn;
  String get correctItemId => correctChoiceId;
  List<QuizChoice> get options => choices;

  String localizedPrompt(bool isArabic) => isArabic ? promptAr : promptEn;
  String localizedQuestionText(bool isArabic) => localizedPrompt(isArabic);

  Map<String, dynamic> toMap() {
    return {
      'questionId': id,
      'id': id,
      'promptEn': promptEn,
      'promptAr': promptAr,
      'correctChoiceId': correctChoiceId,
      'choices': choices.map((c) => c.toMap()).toList(),
      'categoryId': categoryId,
      'difficultyLevel': difficultyLevel,
      if (targetItem != null) 'targetItem': targetItem!.toMap(),
    };
  }

  factory QuizQuestionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return QuizQuestionModel(
      id: id ?? map['questionId'] as String? ?? map['id'] as String? ?? '',
      promptEn: map['promptEn'] as String? ?? '',
      promptAr: map['promptAr'] as String? ?? '',
      correctChoiceId: map['correctChoiceId'] as String? ?? '',
      choices: (map['choices'] as List<dynamic>?)
              ?.map((e) => QuizChoice.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categoryId: map['categoryId'] as String? ?? 'animals',
      difficultyLevel: map['difficultyLevel'] as int? ?? 1,
      targetItem: map['targetItem'] != null
          ? VocabularyItemModel.fromMap(map['targetItem'] as Map<String, dynamic>)
          : null,
    );
  }

  QuizQuestionModel copyWith({
    String? id,
    String? promptEn,
    String? promptAr,
    String? correctChoiceId,
    List<QuizChoice>? choices,
    String? categoryId,
    int? difficultyLevel,
    VocabularyItemModel? targetItem,
  }) {
    return QuizQuestionModel(
      id: id ?? this.id,
      promptEn: promptEn ?? this.promptEn,
      promptAr: promptAr ?? this.promptAr,
      correctChoiceId: correctChoiceId ?? this.correctChoiceId,
      choices: choices ?? this.choices,
      categoryId: categoryId ?? this.categoryId,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      targetItem: targetItem ?? this.targetItem,
    );
  }
}
