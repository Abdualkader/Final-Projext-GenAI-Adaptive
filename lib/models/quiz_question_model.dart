import 'package:flutter/material.dart';

class QuizChoice {
  final String id;
  final String labelEn;
  final String labelAr;
  final IconData icon;
  final Color accentColor;

  const QuizChoice({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.icon,
    required this.accentColor,
  });

  String localizedLabel(bool isArabic) => isArabic ? labelAr : labelEn;
}

/// Model representing an interactive multiple-choice quiz question.
class QuizQuestionModel {
  final String id;
  final String promptEn;
  final String promptAr;
  final String correctChoiceId;
  final List<QuizChoice> choices;

  const QuizQuestionModel({
    required this.id,
    required this.promptEn,
    required this.promptAr,
    required this.correctChoiceId,
    required this.choices,
  });

  String localizedPrompt(bool isArabic) => isArabic ? promptAr : promptEn;
}
