import 'package:flutter/foundation.dart';
import '../core/constants/firebase_collections.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';
import 'mock_data_repository.dart';

/// Repository interface for child learning progress and dashboard analytics.
abstract class ProgressRepository {
  Future<StudentProgressModel> getProgressForChild(String childId);
  Future<void> recordProgress(ProgressRecordModel record);
}

/// Base implementation of [ProgressRepository].
class BaseProgressRepository implements ProgressRepository {
  final FirestoreService _firestoreService;

  BaseProgressRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<StudentProgressModel> getProgressForChild(String childId) async {
    // Current architecture phase provides sample progress for UI dashboard
    return MockDataRepository.getSampleProgress();
  }

  @override
  Future<void> recordProgress(ProgressRecordModel record) async {
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.progressRecords,
        record.recordId,
        record.toMap(),
      );
    } catch (e) {
      debugPrint('ProgressRepository: Progress record saved locally: $e');
    }
  }
}
