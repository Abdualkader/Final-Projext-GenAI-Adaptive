import 'package:flutter/material.dart';

class SessionRecord {
  final String id;
  final String date;
  final String categoryEn;
  final String categoryAr;
  final String score;
  final int accuracyPercentage;
  final IconData categoryIcon;
  final Color categoryColor;

  const SessionRecord({
    required this.id,
    required this.date,
    required this.categoryEn,
    required this.categoryAr,
    required this.score,
    required this.accuracyPercentage,
    required this.categoryIcon,
    required this.categoryColor,
  });

  String localizedCategory(bool isArabic) => isArabic ? categoryAr : categoryEn;
}

class CategoryAccuracy {
  final String categoryEn;
  final String categoryAr;
  final int accuracy;
  final Color color;
  final IconData icon;

  const CategoryAccuracy({
    required this.categoryEn,
    required this.categoryAr,
    required this.accuracy,
    required this.color,
    required this.icon,
  });

  String localizedCategory(bool isArabic) => isArabic ? categoryAr : categoryEn;
}

class StudentProgressModel {
  final String studentName;
  final int studentAge;
  final String interestBadgeEn;
  final String interestBadgeAr;
  final int totalSessions;
  final int overallAccuracy;
  final List<CategoryAccuracy> categoryAccuracies;
  final List<SessionRecord> recentSessions;

  const StudentProgressModel({
    required this.studentName,
    required this.studentAge,
    required this.interestBadgeEn,
    required this.interestBadgeAr,
    required this.totalSessions,
    required this.overallAccuracy,
    required this.categoryAccuracies,
    required this.recentSessions,
  });
}
