import '../../models/category_model.dart';
import '../../models/vocabulary_item_model.dart';

/// Content validator adhering to Week 8 Task 12:
/// Validates that all required vocabulary content and category data exist
/// before presentation to the child learner.
class ContentValidator {
  /// Recognized primary category identifiers.
  static const Set<String> validCategoryIds = {
    'letters',
    'numbers',
    'colors',
    'colours',
    'animals',
  };

  /// Validates that a vocabulary item contains all required fields:
  /// - [itemId] / [id] (non-empty)
  /// - [categoryId] (must be one of the four supported domains)
  /// - [labelAr] (non-empty)
  /// - [labelEn] (non-empty)
  /// - [imageUrl] (non-empty)
  /// - [difficultyLevel] (must be 1, 2, or 3)
  ///
  /// Note: [audioUrlAr] and [audioUrlEn] are optional. Missing audio does NOT
  /// cause validation to fail, ensuring the application remains robust and non-crashing.
  static bool isValidVocabularyItem(VocabularyItemModel? item) {
    if (item == null) return false;
    if (item.id.trim().isEmpty) return false;
    if (item.categoryId.trim().isEmpty) return false;
    if (!validCategoryIds.contains(item.categoryId.trim().toLowerCase())) return false;
    if (item.labelAr.trim().isEmpty) return false;
    if (item.labelEn.trim().isEmpty) return false;
    if (item.imageUrl.trim().isEmpty) return false;
    if (item.difficultyLevel < 1 || item.difficultyLevel > 3) return false;
    return true;
  }

  /// Filters a list of vocabulary items, omitting any corrupted or incomplete items.
  static List<VocabularyItemModel> filterValidItems(List<VocabularyItemModel> items) {
    return items.where(isValidVocabularyItem).toList();
  }

  /// Validates that a category contains all required fields (Task 2):
  /// - [categoryId] / [id] (non-empty)
  /// - [nameAr] (non-empty)
  /// - [nameEn] (non-empty)
  static bool isValidCategory(CategoryModel? category) {
    if (category == null) return false;
    if (category.id.trim().isEmpty) return false;
    if (category.nameAr.trim().isEmpty) return false;
    if (category.nameEn.trim().isEmpty) return false;
    return true;
  }

  /// Filters a list of categories, returning only valid categories.
  static List<CategoryModel> filterValidCategories(List<CategoryModel> categories) {
    return categories.where(isValidCategory).toList();
  }
}
