/// Represents an individual child learner profile managed by a parent or educator.
/// Matches schema in PROJECT_REFERENCE.md Section 5 (Collection: 'children').
class ChildModel {
  final String childId;
  final String parentId;
  final String name;
  final DateTime? birthDate;
  final int currentDifficultyLevel; // 1 (Beginner), 2 (Intermediate), 3 (Advanced)
  final String preferredLanguage; // 'ar' | 'en'
  final DateTime createdAt;

  const ChildModel({
    required this.childId,
    required this.parentId,
    required this.name,
    this.birthDate,
    this.currentDifficultyLevel = 1,
    this.preferredLanguage = 'en',
    required this.createdAt,
  });

  /// Approximate age in years if birthDate is available.
  int? get ageYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'parentId': parentId,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'currentDifficultyLevel': currentDifficultyLevel,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChildModel(
      childId: id ?? map['childId'] as String? ?? '',
      parentId: map['parentId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] is String
              ? DateTime.tryParse(map['birthDate'] as String)
              : null)
          : null,
      currentDifficultyLevel:
          (map['currentDifficultyLevel'] as num?)?.toInt() ?? 1,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
              : DateTime.now())
          : DateTime.now(),
    );
  }

  ChildModel copyWith({
    String? childId,
    String? parentId,
    String? name,
    DateTime? birthDate,
    int? currentDifficultyLevel,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return ChildModel(
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      currentDifficultyLevel:
          currentDifficultyLevel ?? this.currentDifficultyLevel,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
