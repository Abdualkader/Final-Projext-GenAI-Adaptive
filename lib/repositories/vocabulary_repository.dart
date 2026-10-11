import '../core/constants/firebase_collections.dart';
import '../models/vocabulary_item_model.dart';
import '../services/firestore_service.dart';
import '../services/sample_data_service.dart';

/// Repository interface for vocabulary cards and learning items.
abstract class VocabularyRepository {
  /// Retrieves all vocabulary items with optional maximum difficulty ceiling.
  Future<List<VocabularyItemModel>> getVocabularyItems({int? maxDifficulty});

  /// Retrieves vocabulary items for a specific learning category.
  Future<List<VocabularyItemModel>> getVocabularyForCategory(
    String categoryId, {
    int? maxDifficulty,
  });

  /// Retrieves an individual vocabulary card by unique item identifier.
  Future<VocabularyItemModel?> getVocabularyItemById(String itemId);

  /// Saves or updates a single vocabulary item.
  Future<void> saveVocabularyItem(VocabularyItemModel item);

  /// Seeds a batch of vocabulary items into Cloud Firestore.
  Future<void> seedVocabularyItems(List<VocabularyItemModel> items);
}

/// Base implementation of [VocabularyRepository] communicating with Cloud Firestore.
class BaseVocabularyRepository implements VocabularyRepository {
  final FirestoreService _firestoreService;
  final List<VocabularyItemModel> _inMemoryItems =
      List.from(SampleDataService.sampleVocabulary);

  BaseVocabularyRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<VocabularyItemModel>> getVocabularyItems({int? maxDifficulty}) async {
    try {
      final snapshot = await _firestoreService.getCollection(
        FirebaseCollections.vocabularyItems,
      );
      if (snapshot.docs.isNotEmpty) {
        final items = snapshot.docs
            .map((doc) => VocabularyItemModel.fromMap(doc.data(), id: doc.id))
            .toList();
        if (maxDifficulty != null) {
          return items.where((i) => i.difficultyLevel <= maxDifficulty).toList();
        }
        return items;
      }
    } catch (_) {
      // Offline fallback
    }

    if (maxDifficulty != null) {
      return _inMemoryItems.where((i) => i.difficultyLevel <= maxDifficulty).toList();
    }
    return _inMemoryItems;
  }

  @override
  Future<List<VocabularyItemModel>> getVocabularyForCategory(
    String categoryId, {
    int? maxDifficulty,
  }) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.vocabularyItems,
        whereEquals: {'categoryId': categoryId},
      );
      if (snapshot.docs.isNotEmpty) {
        final items = snapshot.docs
            .map((doc) => VocabularyItemModel.fromMap(doc.data(), id: doc.id))
            .toList();
        if (maxDifficulty != null) {
          return items.where((i) => i.difficultyLevel <= maxDifficulty).toList();
        }
        return items;
      }
    } catch (_) {
      // Offline fallback
    }

    final items = _inMemoryItems
        .where((i) => i.categoryId == categoryId)
        .toList();
    if (maxDifficulty != null) {
      return items.where((i) => i.difficultyLevel <= maxDifficulty).toList();
    }
    return items;
  }

  @override
  Future<VocabularyItemModel?> getVocabularyItemById(String itemId) async {
    try {
      final doc = await _firestoreService.getDocument(
        FirebaseCollections.vocabularyItems,
        itemId,
      );
      if (doc != null && doc.exists && doc.data() != null) {
        return VocabularyItemModel.fromMap(doc.data()!, id: doc.id);
      }
    } catch (_) {
      // Offline fallback
    }

    try {
      return _inMemoryItems.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveVocabularyItem(VocabularyItemModel item) async {
    final index = _inMemoryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inMemoryItems[index] = item;
    } else {
      _inMemoryItems.add(item);
    }
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.vocabularyItems,
        item.id,
        item.toMap(),
      );
    } catch (_) {
      // Saved in-memory
    }
  }

  @override
  Future<void> seedVocabularyItems(List<VocabularyItemModel> items) async {
    for (final item in items) {
      await saveVocabularyItem(item);
    }
  }
}
