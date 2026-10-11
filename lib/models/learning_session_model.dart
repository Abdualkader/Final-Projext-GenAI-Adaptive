/// Represents a learning session record tracking learner engagement and telemetry.
/// Matches schema in PROJECT_REFERENCE.md Section 5 (Collection: 'sessions').
class LearningSessionModel {
  final String sessionId;
  final String childId;
  final String categoryId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> itemsPresented;
  final double score;

  const LearningSessionModel({
    required this.sessionId,
    required this.childId,
    required this.categoryId,
    required this.startTime,
    this.endTime,
    this.itemsPresented = const [],
    this.score = 0.0,
  });

  /// Duration of the session if finished.
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'childId': childId,
      'categoryId': categoryId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'itemsPresented': itemsPresented,
      'score': score,
    };
  }

  factory LearningSessionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return LearningSessionModel(
      sessionId: id ?? map['sessionId'] as String? ?? '',
      childId: map['childId'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      startTime: map['startTime'] != null
          ? (map['startTime'] is String
              ? DateTime.tryParse(map['startTime'] as String) ?? DateTime.now()
              : DateTime.now())
          : DateTime.now(),
      endTime: map['endTime'] != null
          ? (map['endTime'] is String
              ? DateTime.tryParse(map['endTime'] as String)
              : null)
          : null,
      itemsPresented: (map['itemsPresented'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LearningSessionModel copyWith({
    String? sessionId,
    String? childId,
    String? categoryId,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? itemsPresented,
    double? score,
  }) {
    return LearningSessionModel(
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      itemsPresented: itemsPresented ?? this.itemsPresented,
      score: score ?? this.score,
    );
  }
}
