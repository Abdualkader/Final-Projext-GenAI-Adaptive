/// Represents a registered parent or educator user profile in Cloud Firestore.
/// Matches schema in PROJECT_REFERENCE.md Section 5 (Collection: 'users').
class UserModel {
  final String userId;
  final String email;
  final String? displayName;
  final String role; // 'parent' | 'educator'
  final String preferredLanguage; // 'ar' | 'en'
  final List<String> linkedChildIds;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    this.role = 'parent',
    this.preferredLanguage = 'en',
    this.linkedChildIds = const [],
    required this.createdAt,
  });

  bool get isEducator => role == 'educator';
  bool get isParent => role == 'parent';

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'role': role,
      'preferredLanguage': preferredLanguage,
      'linkedChildIds': linkedChildIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      userId: id ?? map['userId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      role: map['role'] as String? ?? 'parent',
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      linkedChildIds: (map['linkedChildIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.parse(map['createdAt'] as String)
              : DateTime.now())
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? role,
    String? preferredLanguage,
    List<String>? linkedChildIds,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      linkedChildIds: linkedChildIds ?? this.linkedChildIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
