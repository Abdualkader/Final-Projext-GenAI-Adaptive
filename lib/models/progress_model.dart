import 'package:flutter/material.dart';

/// Aggregated daily/weekly performance analytics document in Cloud Firestore.
/// Matches schema in PROJECT_REFERENCE.md Section 5 (Collection: 'progressRecords').
class ProgressRecordModel {
  final String recordId;
  final String childId;
  final DateTime date;
  final List<String> itemsMastered;
  final List<double> quizScores;
  final double overallAccuracy;

  const ProgressRecordModel({
    required this.recordId,
    required this.childId,
    required this.date,
    this.itemsMastered = const [],
    this.quizScores = const [],
    this.overallAccuracy = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'childId': childId,
      'date': date.toIso8601String(),
      'itemsMastered': itemsMastered,
      'quizScores': quizScores,
      'overallAccuracy': overallAccuracy,
    };
  }

  factory ProgressRecordModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ProgressRecordModel(
      recordId: id ?? map['recordId'] as String? ?? '',
      childId: map['childId'] as String? ?? '',
      date: map['date'] != null
          ? (map['date'] is String
              ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
              : DateTime.now())
          : DateTime.now(),
      itemsMastered: (map['itemsMastered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      quizScores: (map['quizScores'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      overallAccuracy: (map['overallAccuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ProgressRecordModel copyWith({
    String? recordId,
    String? childId,
    DateTime? date,
    List<String>? itemsMastered,
    List<double>? quizScores,
    double? overallAccuracy,
  }) {
    return ProgressRecordModel(
      recordId: recordId ?? this.recordId,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      itemsMastered: itemsMastered ?? this.itemsMastered,
      quizScores: quizScores ?? this.quizScores,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
    );
  }
}

/// UI presentation model for an individual session item in the parent dashboard.
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

/// UI presentation model for category-wise accuracy charts in the dashboard.
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

/// Comprehensive progress model feeding the parent/educator dashboard screen.
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
