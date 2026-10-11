import '../models/category_model.dart';
import 'mock_data_repository.dart';

/// Repository interface for learning categories.
abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel?> getCategoryById(String categoryId);
}

/// Base implementation of [CategoryRepository].
class BaseCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return MockDataRepository.getCategories();
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}
