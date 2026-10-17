import '../core/constants/firebase_collections.dart';
import '../core/utils/content_validator.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/sample_data_service.dart';

/// Repository interface for learning categories.
abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel?> getCategoryById(String categoryId);
  Future<void> seedCategories(List<CategoryModel> categories);
}

/// Base implementation of [CategoryRepository] backed by Cloud Firestore.
class BaseCategoryRepository implements CategoryRepository {
  final FirestoreService _firestoreService;
  final List<CategoryModel> _inMemoryCategories = List.from(SampleDataService.sampleCategories);

  BaseCategoryRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestoreService.getCollection(
        FirebaseCollections.categories,
        orderByField: 'orderIndex',
      );
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data(), id: doc.id))
            .toList();
        return ContentValidator.filterValidCategories(list);
      }
    } catch (_) {
      // Offline fallback to sample categories
    }

    return ContentValidator.filterValidCategories(_inMemoryCategories);
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    final searchIds = (categoryId == 'colors' || categoryId == 'colours')
        ? ['colours', 'colors']
        : [categoryId];

    for (final id in searchIds) {
      try {
        final doc = await _firestoreService.getDocument(
          FirebaseCollections.categories,
          id,
        );
        if (doc != null && doc.exists && doc.data() != null) {
          final model = CategoryModel.fromMap(doc.data()!, id: doc.id);
          if (model.isValid) return model;
        }
      } catch (_) {
        // Fallback
      }

      try {
        final match = _inMemoryCategories.firstWhere((c) => c.id == id);
        if (match.isValid) return match;
      } catch (_) {
        // Continue searching
      }
    }

    return null;
  }

  @override
  Future<void> seedCategories(List<CategoryModel> categories) async {
    for (final category in categories) {
      final index = _inMemoryCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _inMemoryCategories[index] = category;
      } else {
        _inMemoryCategories.add(category);
      }
      try {
        await _firestoreService.setDocument(
          FirebaseCollections.categories,
          category.id,
          category.toMap(),
        );
      } catch (_) {
        // Saved in-memory
      }
    }
  }
}
