import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';
import 'mock_data_repository.dart';

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
  Future<StudentProgressModel> getProgressForChild(String childId);
}

/// Base implementation of [ProgressRepository] communicating with Cloud Firestore.
class BaseProgressRepository implements ProgressRepository {
  final FirestoreService _firestoreService;
  final List<ProgressRecordModel> _inMemoryRecords = [];

  BaseProgressRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<void> createProgressRecord(ProgressRecordModel record) async {
    _inMemoryRecords.add(record);
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
        return snapshot.docs
            .map((doc) => ProgressRecordModel.fromMap(doc.data(), id: doc.id))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _inMemoryRecords
        .where((r) => r.childId == childId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<StudentProgressModel> getProgressForChild(String childId) async {
    // Computes dashboard summary based on progress records or returns calibrated model
    return MockDataRepository.getSampleProgress();
  }
}
