import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

/// State management controller for category listing and selection.
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  CategoryProvider({CategoryRepository? categoryRepository})
      : _categoryRepository = categoryRepository ?? BaseCategoryRepository();

  UiState<List<CategoryModel>> _uiState = const UiState.initial();
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  UiState<List<CategoryModel>> get uiState => _uiState;
  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;

  /// Loads available categories.
  Future<void> loadCategories() async {
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final list = await _categoryRepository.getCategories();
      _categories = list;
      if (list.isEmpty) {
        _uiState = const UiState.empty();
      } else {
        _uiState = UiState.success(list);
      }
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load categories: $e'),
      );
    }
    notifyListeners();
  }

  /// Sets the currently selected category by ID.
  void selectCategory(String categoryId) {
    try {
      _selectedCategory = _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      _selectedCategory = null;
    }
    notifyListeners();
  }
}
