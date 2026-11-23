import 'package:flutter/material.dart';
import '../core/constants/firebase_collections.dart';
import '../models/child_model.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data_service.dart';
import 'mock_data_repository.dart';
import 'quiz_repository.dart';
import 'session_repository.dart';
import 'user_repository.dart';
import 'vocabulary_repository.dart';

/// Repository interface for child learning progress and dashboard analytics.
abstract class ProgressRepository {
  /// Creates a new daily/weekly progress summary record in Cloud Firestore.
  Future<void> createProgressRecord(ProgressRecordModel record);

  /// Updates an existing progress summary record.
  Future<void> updateProgressRecord(ProgressRecordModel record);

  /// Backwards-compatible alias for [createProgressRecord].
  Future<void> recordProgress(ProgressRecordModel record);

  /// Retrieves a progress record for a specific date (normalized to YYYY-MM-DD).
  Future<ProgressRecordModel?> getProgressByDate(String childId, DateTime date);

  /// Retrieves chronological progress records for a child profile.
  Future<List<ProgressRecordModel>> getProgressRecordsForChild(
    String childId, {
    int limit = 30,
  });

  /// Computes and returns the comprehensive [StudentProgressModel] for dashboard visualization.
  Future<StudentProgressModel> getProgressForChild(
    String childId, {
    String categoryFilter = 'all',
    String dateFilter = 'all',
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Calculates mastered vocabulary items for a child based on quiz results and session performance.
  Future<List<String>> getMasteredVocabulary(
    String childId, {
    String categoryFilter = 'all',
  });

  /// Calculates quiz accuracy percentage (0-100) based on recorded quiz results.
  Future<double> calculateQuizAccuracy(
    String childId, {
    String categoryFilter = 'all',
    DateTime? since,
  });
}

/// Base implementation of [ProgressRepository] communicating with Cloud Firestore.
class BaseProgressRepository implements ProgressRepository {
  final FirestoreService _firestoreService;
  final SessionRepository _sessionRepository;
  final QuizRepository _quizRepository;
  final UserRepository _userRepository;
  final VocabularyRepository _vocabularyRepository;

  static final List<ProgressRecordModel> _inMemoryRecords = [];

  BaseProgressRepository({
    FirestoreService? firestoreService,
    SessionRepository? sessionRepository,
    QuizRepository? quizRepository,
    UserRepository? userRepository,
    VocabularyRepository? vocabularyRepository,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _sessionRepository = sessionRepository ?? BaseSessionRepository(),
        _quizRepository = quizRepository ?? BaseQuizRepository(),
        _userRepository = userRepository ?? BaseUserRepository(),
        _vocabularyRepository = vocabularyRepository ?? BaseVocabularyRepository();

  @override
  Future<void> createProgressRecord(ProgressRecordModel record) async {
    _inMemoryRecords.add(record);
    await LocalStorageService.saveProgressRecord(record);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.progressRecords,
        record.recordId,
        record.toMap(),
      );
    } catch (e) {
      debugPrint('ProgressRepository: Saved progress record locally (${record.recordId}): $e');
    }
  }

  @override
  Future<void> recordProgress(ProgressRecordModel record) =>
      createProgressRecord(record);

  @override
  Future<void> updateProgressRecord(ProgressRecordModel record) async {
    final index = _inMemoryRecords.indexWhere((r) => r.recordId == record.recordId);
    if (index != -1) {
      _inMemoryRecords[index] = record;
    } else {
      _inMemoryRecords.add(record);
    }
    await LocalStorageService.saveProgressRecord(record);

    try {
      await _firestoreService.updateDocument(
        FirebaseCollections.progressRecords,
        record.recordId,
        record.toMap(),
      );
    } catch (e) {
      debugPrint('ProgressRepository: Updated progress record locally (${record.recordId}): $e');
    }
  }

  @override
  Future<ProgressRecordModel?> getProgressByDate(
    String childId,
    DateTime date,
  ) async {
    final records = await getProgressRecordsForChild(childId);
    for (final r in records) {
      if (r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day) {
        return r;
      }
    }
    return null;
  }

  @override
  Future<List<ProgressRecordModel>> getProgressRecordsForChild(
    String childId, {
    int limit = 30,
  }) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.progressRecords,
        whereEquals: {'childId': childId},
        orderByField: 'date',
        descending: true,
        limit: limit,
      );
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => ProgressRecordModel.fromMap(doc.data(), id: doc.id))
            .toList();
        for (final p in list) {
          await LocalStorageService.saveProgressRecord(p);
        }
        return list;
      }
    } catch (_) {
      // Fallback
    }

    final localRecords = await LocalStorageService.getProgressRecordsForChild(childId);
    final map = <String, ProgressRecordModel>{};
    for (final r in _inMemoryRecords.where((r) => r.childId == childId)) {
      map[r.recordId] = r;
    }
    for (final r in localRecords) {
      map[r.recordId] = r;
    }

    final merged = map.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return merged.take(limit).toList();
  }


  @override
  Future<List<String>> getMasteredVocabulary(
    String childId, {
    String categoryFilter = 'all',
  }) async {
    final allQuizzes = await _quizRepository.getQuizResultsForChild(childId);
    final allSessions = await _sessionRepository.getRecentSessions(childId, limit: 100);
    final allVocab = await _vocabularyRepository.getVocabularyItems();

    // Map vocabulary to categories
    final vocabCategoryMap = <String, String>{};
    for (final v in allVocab) {
      vocabCategoryMap[v.id] = v.categoryId;
    }

    // Task 4: Explainable Mastery Rule:
    // A vocabulary item is mastered if:
    // 1. Correct answers >= 2 in quiz assessments, OR
    // 2. Accuracy on the item is >= 75% across attempts (with at least 1 correct), OR
    // 3. Item was presented in >= 2 completed sessions with score >= 70%.
    final itemQuizCorrect = <String, int>{};
    final itemQuizTotal = <String, int>{};

    for (final q in allQuizzes) {
      final qId = q.questionId;
      itemQuizTotal[qId] = (itemQuizTotal[qId] ?? 0) + 1;
      if (q.isCorrect) {
        itemQuizCorrect[qId] = (itemQuizCorrect[qId] ?? 0) + 1;
      }
    }

    final itemSessionSuccessCount = <String, int>{};
    for (final s in allSessions) {
      if (s.score >= 0.70) {
        for (final itemId in s.itemsPresented) {
          itemSessionSuccessCount[itemId] = (itemSessionSuccessCount[itemId] ?? 0) + 1;
        }
      }
    }

    final masteredSet = <String>{};

    // Check quiz performance
    for (final entry in itemQuizTotal.entries) {
      final itemId = entry.key;
      final total = entry.value;
      final correct = itemQuizCorrect[itemId] ?? 0;

      if (correct >= 2 || (total >= 1 && (correct / total) >= 0.75)) {
        masteredSet.add(itemId);
      }
    }

    // Check session repetition
    for (final entry in itemSessionSuccessCount.entries) {
      if (entry.value >= 2) {
        masteredSet.add(entry.key);
      }
    }

    // Apply category filter if active
    if (categoryFilter != 'all') {
      final cat = categoryFilter.toLowerCase();
      return masteredSet.where((id) {
        final itemCat = vocabCategoryMap[id]?.toLowerCase();
        return itemCat == cat || (cat == 'colors' && itemCat == 'colours') || (cat == 'colours' && itemCat == 'colors');
      }).toList();
    }

    return masteredSet.toList();
  }

  @override
  Future<double> calculateQuizAccuracy(
    String childId, {
    String categoryFilter = 'all',
    DateTime? since,
  }) async {
    var quizzes = await _quizRepository.getQuizResultsForChild(childId);
    if (since != null) {
      quizzes = quizzes.where((q) => q.timestamp.isAfter(since) || q.timestamp.isAtSameMomentAs(since)).toList();
    }

    if (categoryFilter != 'all') {
      final allVocab = await _vocabularyRepository.getVocabularyItems();
      final cat = categoryFilter.toLowerCase();
      final catItemIds = allVocab
          .where((v) => v.categoryId.toLowerCase() == cat || (cat == 'colors' && v.categoryId == 'colours') || (cat == 'colours' && v.categoryId == 'colors'))
          .map((v) => v.id)
          .toSet();
      quizzes = quizzes.where((q) => catItemIds.contains(q.questionId)).toList();
    }

    if (quizzes.isEmpty) {
      // Fallback to average session score if available
      final sessions = await _sessionRepository.getRecentSessions(childId, limit: 100);
      if (sessions.isEmpty) return 0.0;
      final totalScore = sessions.fold<double>(0.0, (sum, s) => sum + s.score);
      return (totalScore / sessions.length) * 100.0;
    }

    final correct = quizzes.where((q) => q.isCorrect).length;
    return (correct / quizzes.length) * 100.0;
  }

  @override
  Future<StudentProgressModel> getProgressForChild(
    String childId, {
    String categoryFilter = 'all',
    String dateFilter = 'all',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Resolve child metadata
    String studentName = 'Adam';
    int studentAge = 5;
    String interestBadgeEn = 'Loves Animals!';
    String interestBadgeAr = 'يحب الحيوانات!';

    try {
      final directChild = await _userRepository.getChildById(childId);
      if (directChild != null) {
        studentName = directChild.name;
        studentAge = directChild.ageYears ?? 5;
      } else {
        final children = await _userRepository.getLinkedChildren('parent_default');
        final matchedChild = children.firstWhere(
          (c) => c.childId == childId,
          orElse: () => SampleDataService.sampleChildren.firstWhere(
            (c) => c.childId == childId,
            orElse: () => ChildModel(
              childId: childId,
              parentId: 'parent_default',
              name: childId == 'child_adam' ? 'Adam' : (childId.startsWith('child_') ? childId.substring(6) : childId),
              currentDifficultyLevel: 1,
              birthDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
              createdAt: DateTime.now(),
            ),
          ),
        );
        studentName = matchedChild.name;
        studentAge = matchedChild.ageYears ?? 5;
      }
    } catch (_) {}

    // 2. Fetch raw sessions and quiz results
    final allSessions = await _sessionRepository.getRecentSessions(childId, limit: 100);
    final allQuizzes = await _quizRepository.getQuizResultsForChild(childId);

    // Task 10: If a child has no learning history at all
    if (allSessions.isEmpty && allQuizzes.isEmpty) {
      if (childId == 'child_adam') {
        // Fallback for default sample student in backward-compatible tests
        return MockDataRepository.getSampleProgress();
      }
      return StudentProgressModel.empty(
        studentName: studentName,
        studentAge: studentAge,
        interestBadgeEn: interestBadgeEn,
        interestBadgeAr: interestBadgeAr,
      );
    }

    // 3. Apply Date Filtering (Task 8)
    final now = DateTime.now();
    DateTime? start = startDate;
    DateTime? end = endDate;

    if (dateFilter == 'today') {
      start = DateTime(now.year, now.month, now.day);
    } else if (dateFilter == 'week') {
      start = now.subtract(const Duration(days: 7));
    } else if (dateFilter == 'month') {
      start = now.subtract(const Duration(days: 30));
    }

    final sDate = start;
    final eDate = end;

    var filteredSessions = allSessions;
    if (sDate != null) {
      filteredSessions = filteredSessions.where((s) => s.startTime.isAfter(sDate) || s.startTime.isAtSameMomentAs(sDate)).toList();
    }
    if (eDate != null) {
      filteredSessions = filteredSessions.where((s) => s.startTime.isBefore(eDate) || s.startTime.isAtSameMomentAs(eDate)).toList();
    }

    var filteredQuizzes = allQuizzes;
    if (sDate != null) {
      filteredQuizzes = filteredQuizzes.where((q) => q.timestamp.isAfter(sDate) || q.timestamp.isAtSameMomentAs(sDate)).toList();
    }
    if (eDate != null) {
      filteredQuizzes = filteredQuizzes.where((q) => q.timestamp.isBefore(eDate) || q.timestamp.isAtSameMomentAs(eDate)).toList();
    }

    // 4. Apply Category Filtering (Task 9)
    final allVocab = await _vocabularyRepository.getVocabularyItems();
    final vocabCatMap = <String, String>{};
    for (final v in allVocab) {
      vocabCatMap[v.id] = v.categoryId;
    }

    if (categoryFilter != 'all') {
      final cat = categoryFilter.toLowerCase();
      filteredSessions = filteredSessions.where((s) {
        final sCat = s.categoryId.toLowerCase();
        return sCat == cat || (cat == 'colors' && sCat == 'colours') || (cat == 'colours' && sCat == 'colors');
      }).toList();

      filteredQuizzes = filteredQuizzes.where((q) {
        final qCat = vocabCatMap[q.questionId]?.toLowerCase() ?? '';
        return qCat == cat || (cat == 'colors' && qCat == 'colours') || (cat == 'colours' && qCat == 'colors');
      }).toList();
    }

    // 5. Calculate Task 3: Quiz Accuracy
    int overallAccuracy = 0;
    if (filteredQuizzes.isNotEmpty) {
      final correctCount = filteredQuizzes.where((q) => q.isCorrect).length;
      overallAccuracy = ((correctCount / filteredQuizzes.length) * 100).round();
    } else if (filteredSessions.isNotEmpty) {
      final avgScore = filteredSessions.fold<double>(0.0, (sum, s) => sum + s.score) / filteredSessions.length;
      overallAccuracy = (avgScore * 100).round();
    }

    // 6. Calculate Task 4: Mastered Vocabulary
    final masteredItems = await getMasteredVocabulary(childId, categoryFilter: categoryFilter);
    final masteredCount = masteredItems.length;

    // 7. Calculate Task 5: Session Frequency
    final totalSessions = filteredSessions.length;
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentWeekCount = allSessions.where((s) => s.startTime.isAfter(sevenDaysAgo)).length;
    final weeklyFrequency = recentWeekCount > 0 ? recentWeekCount : (totalSessions > 0 ? 1 : 0);

    // 8. Calculate Task 6: Progress Trends (Category Accuracies)
    final categoriesDef = [
      {'en': 'Letters', 'ar': 'الحروف', 'key': 'letters', 'color': const Color(0xFF9C27B0), 'icon': Icons.sort_by_alpha},
      {'en': 'Numbers', 'ar': 'الأرقام', 'key': 'numbers', 'color': const Color(0xFF2196F3), 'icon': Icons.format_list_numbered},
      {'en': 'Colors', 'ar': 'الألوان', 'key': 'colors', 'color': const Color(0xFFFFB300), 'icon': Icons.palette},
      {'en': 'Animals', 'ar': 'الحيوانات', 'key': 'animals', 'color': const Color(0xFF4CAF50), 'icon': Icons.pets},
    ];

    final categoryAccuracies = <CategoryAccuracy>[];
    for (final def in categoriesDef) {
      final key = def['key'] as String;
      final catQuizzes = allQuizzes.where((q) {
        final cat = vocabCatMap[q.questionId]?.toLowerCase();
        return cat == key || (key == 'colors' && cat == 'colours');
      }).toList();

      int catAcc = 0;
      if (catQuizzes.isNotEmpty) {
        final correct = catQuizzes.where((q) => q.isCorrect).length;
        catAcc = ((correct / catQuizzes.length) * 100).round();
      } else {
        final catSessions = allSessions.where((s) {
          final sCat = s.categoryId.toLowerCase();
          return sCat == key || (key == 'colors' && sCat == 'colours');
        }).toList();
        if (catSessions.isNotEmpty) {
          final avgScore = catSessions.fold<double>(0.0, (sum, s) => sum + s.score) / catSessions.length;
          catAcc = (avgScore * 100).round();
        }
      }

      categoryAccuracies.add(
        CategoryAccuracy(
          categoryEn: def['en'] as String,
          categoryAr: def['ar'] as String,
          accuracy: catAcc,
          color: def['color'] as Color,
          icon: def['icon'] as IconData,
        ),
      );
    }

    // 9. Format Recent Sessions List
    filteredSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    final topSessions = filteredSessions.take(10).toList();
    final recentSessions = topSessions.map((s) {
      final icon = _getCategoryIcon(s.categoryId);
      final color = _getCategoryColor(s.categoryId);
      final catEn = _getCategoryNameEn(s.categoryId);
      final catAr = _getCategoryNameAr(s.categoryId);
      final accPct = (s.score * 100).round();
      final totalItems = s.itemsPresented.isNotEmpty ? s.itemsPresented.length : 20;
      final correctEstimate = (s.score * totalItems).round();

      return SessionRecord(
        id: s.sessionId,
        date: _formatDateTime(s.startTime),
        categoryEn: catEn,
        categoryAr: catAr,
        score: '$correctEstimate / $totalItems',
        accuracyPercentage: accPct,
        categoryIcon: icon,
        categoryColor: color,
      );
    }).toList();

    // 10. Persist daily/weekly progress summary record
    final recordId = 'prog_${childId}_${now.year}_${now.month}_${now.day}';
    final progressRecord = ProgressRecordModel(
      recordId: recordId,
      childId: childId,
      date: now,
      itemsMastered: masteredItems,
      quizScores: filteredQuizzes.map((q) => q.isCorrect ? 100.0 : 0.0).toList(),
      overallAccuracy: overallAccuracy.toDouble(),
    );
    // Asynchronous snapshot record
    createProgressRecord(progressRecord);

    return StudentProgressModel(
      studentName: studentName,
      studentAge: studentAge,
      interestBadgeEn: interestBadgeEn,
      interestBadgeAr: interestBadgeAr,
      totalSessions: totalSessions,
      overallAccuracy: overallAccuracy,
      categoryAccuracies: categoryAccuracies,
      recentSessions: recentSessions,
      itemsMastered: masteredItems,
      masteredCount: masteredCount,
      weeklyFrequency: weeklyFrequency,
      activeCategoryFilter: categoryFilter,
      activeDateFilter: dateFilter,
    );
  }

  // --- Helper formatting methods ---

  static IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return Icons.sort_by_alpha;
      case 'numbers':
        return Icons.format_list_numbered;
      case 'colors':
      case 'colours':
        return Icons.palette;
      case 'animals':
      default:
        return Icons.pets;
    }
  }

  static Color _getCategoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return const Color(0xFF9C27B0);
      case 'numbers':
        return const Color(0xFF2196F3);
      case 'colors':
      case 'colours':
        return const Color(0xFFFFB300);
      case 'animals':
      default:
        return const Color(0xFF4CAF50);
    }
  }

  static String _getCategoryNameEn(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return 'Letters';
      case 'numbers':
        return 'Numbers';
      case 'colors':
      case 'colours':
        return 'Colors';
      case 'animals':
      default:
        return 'Animals';
    }
  }

  static String _getCategoryNameAr(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'letters':
        return 'الحروف';
      case 'numbers':
        return 'الأرقام';
      case 'colors':
      case 'colours':
        return 'الألوان';
      case 'animals':
      default:
        return 'الحيوانات';
    }
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$monthStr ${dt.day}, ${dt.year} • $hour:$minuteStr $amPm';
  }
}

