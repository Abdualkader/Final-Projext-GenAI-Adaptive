import '../models/vocabulary_item_model.dart';
import 'mock_data_repository.dart';

/// Repository interface for vocabulary cards and learning items.
abstract class VocabularyRepository {
  Future<List<VocabularyItemModel>> getVocabularyForCategory(
    String categoryId, {
    int? maxDifficulty,
  });

  Future<VocabularyItemModel?> getVocabularyItemById(String itemId);
}

/// Base implementation of [VocabularyRepository].
class BaseVocabularyRepository implements VocabularyRepository {
  @override
  Future<List<VocabularyItemModel>> getVocabularyForCategory(
    String categoryId, {
    int? maxDifficulty,
  }) async {
    final items = MockDataRepository.getVocabularyForCategory(categoryId);
    if (maxDifficulty != null) {
      return items.where((i) => i.difficultyLevel <= maxDifficulty).toList();
    }
    return items;
  }

  @override
  Future<VocabularyItemModel?> getVocabularyItemById(String itemId) async {
    for (final cat in ['animals', 'colours', 'numbers', 'letters']) {
      final items = MockDataRepository.getVocabularyForCategory(cat);
      for (final item in items) {
        if (item.id == itemId) return item;
      }
    }
    return null;
  }
}
