import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/progress_model.dart';
import '../repositories/progress_repository.dart';

/// State management controller for parent/educator dashboard and student analytics.
class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepository;

  ProgressProvider({ProgressRepository? progressRepository})
      : _progressRepository = progressRepository ?? BaseProgressRepository();

  UiState<StudentProgressModel> _uiState = const UiState.initial();
  StudentProgressModel? _progress;
  String _selectedCategoryFilter = 'all';

  UiState<StudentProgressModel> get uiState => _uiState;
  StudentProgressModel? get progress => _progress;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  /// Loads aggregated progress metrics for a child.
  Future<void> loadProgress(String childId) async {
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final data = await _progressRepository.getProgressForChild(childId);
      _progress = data;
      _uiState = UiState.success(data);
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load progress metrics: $e'),
      );
    }
    notifyListeners();
  }

  /// Sets the active category filter for the sessions list.
  void setCategoryFilter(String categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }
}
