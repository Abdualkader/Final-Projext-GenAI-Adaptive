/// Centralized Firebase Firestore collection names.
/// Matches the database schema specified in PROJECT_REFERENCE.md Section 5.
class FirebaseCollections {
  /// User profiles for parents and educators.
  static const String users = 'users';

  /// Child learner profiles linked to parents/educators.
  static const String children = 'children';

  /// Top-level learning categories (Letters, Numbers, Colors, Animals).
  static const String categories = 'categories';

  /// Individual vocabulary cards and learning assets.
  static const String vocabularyItems = 'vocabularyItems';

  /// Learning session telemetry and duration tracking.
  static const String sessions = 'sessions';

  /// Granular per-question attempt logs from interactive quizzes.
  static const String quizResults = 'quizResults';

  /// Aggregated daily/weekly performance analytics for progress dashboard.
  static const String progressRecords = 'progressRecords';

  /// System health verification collection for developer diagnostics.
  static const String systemHealth = '_system_health';
}
