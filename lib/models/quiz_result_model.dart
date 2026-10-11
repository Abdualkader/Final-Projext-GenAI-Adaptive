/// Represents a granular per-question attempt log recorded during quizzes.
/// Matches schema in PROJECT_REFERENCE.md Section 5 (Collection: 'quizResults').
class QuizResultModel {
  final String resultId;
  final String sessionId;
  final String childId;
  final String questionId;
  final String childResponse;
  final bool isCorrect;
  final int? responseTimeMs;
  final DateTime timestamp;

  const QuizResultModel({
    required this.resultId,
    required this.sessionId,
    this.childId = '',
    required this.questionId,
    required this.childResponse,
    required this.isCorrect,
    this.responseTimeMs,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'sessionId': sessionId,
      'childId': childId,
      'questionId': questionId,
      'childResponse': childResponse,
      'isCorrect': isCorrect,
      'responseTimeMs': responseTimeMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return QuizResultModel(
      resultId: id ?? map['resultId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      childId: map['childId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      childResponse: map['childResponse'] as String? ?? '',
      isCorrect: map['isCorrect'] as bool? ?? false,
      responseTimeMs: (map['responseTimeMs'] as num?)?.toInt(),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is String
              ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
              : DateTime.now())
          : DateTime.now(),
    );
  }

  QuizResultModel copyWith({
    String? resultId,
    String? sessionId,
    String? childId,
    String? questionId,
    String? childResponse,
    bool? isCorrect,
    int? responseTimeMs,
    DateTime? timestamp,
  }) {
    return QuizResultModel(
      resultId: resultId ?? this.resultId,
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      questionId: questionId ?? this.questionId,
      childResponse: childResponse ?? this.childResponse,
      isCorrect: isCorrect ?? this.isCorrect,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
