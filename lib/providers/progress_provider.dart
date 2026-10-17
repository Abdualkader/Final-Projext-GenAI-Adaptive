import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/progress_model.dart';
import '../repositories/progress_repository.dart';
import 'auth_provider.dart';

/// State management controller for parent/educator dashboard and student analytics.
class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepository;

  ProgressProvider({ProgressRepository? progressRepository})
      : _progressRepository = progressRepository ?? BaseProgressRepository();

  UiState<StudentProgressModel> _uiState = const UiState.initial();
  StudentProgressModel? _progress;
  String _selectedCategoryFilter = 'all';
  String _selectedDateFilter = 'all';
  String? _activeChildId;

  UiState<StudentProgressModel> get uiState => _uiState;
  StudentProgressModel? get progress => _progress;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedDateFilter => _selectedDateFilter;
  String? get activeChildId => _activeChildId;

  /// Loads aggregated progress metrics for a child with security check and filters.
  Future<void> loadProgress(
    String childId, {
    AuthProvider? authProvider,
    bool notify = true,
  }) async {
    _activeChildId = childId;

    // Task 12: Security authorization check
    // Ensure parent/educator can only retrieve progress for linked children
    if (authProvider != null && authProvider.isAuthenticated) {
      final user = authProvider.currentUser;
      final linkedIds = user?.linkedChildIds ?? const [];
      final isLinked = linkedIds.contains(childId) || user?.userId == childId;

      if (!isLinked) {
        _uiState = UiState.error(
          const AppException(
            code: 'ACCESS_DENIED',
            message: 'You are not authorized to view progress for this child profile.',
          ),
        );
        _progress = null;
        if (notify) notifyListeners();
        return;
      }
    }

    _uiState = const UiState.loading();
    if (notify) notifyListeners();

    try {
      final data = await _progressRepository.getProgressForChild(
        childId,
        categoryFilter: _selectedCategoryFilter,
        dateFilter: _selectedDateFilter,
      );
      _progress = data;

      // Task 10 & 11: Empty state handling
      if (data.isEmpty) {
        _uiState = const UiState.empty();
      } else {
        _uiState = UiState.success(data);
      }
    } catch (e) {
      _uiState = UiState.error(
        AppException(message: 'Failed to load progress metrics: $e'),
      );
    }
    if (notify) notifyListeners();
  }

  /// Sets the active category filter (e.g. 'all', 'letters', 'numbers', 'colors', 'animals')
  Future<void> setCategoryFilter(String categoryId, {AuthProvider? authProvider}) async {
    _selectedCategoryFilter = categoryId;
    notifyListeners();

    if (_activeChildId != null) {
      await loadProgress(_activeChildId!, authProvider: authProvider);
    }
  }

  /// Sets the active date filter (e.g. 'all', 'today', 'week', 'month')
  Future<void> setDateFilter(String dateFilter, {AuthProvider? authProvider}) async {
    _selectedDateFilter = dateFilter;
    notifyListeners();

    if (_activeChildId != null) {
      await loadProgress(_activeChildId!, authProvider: authProvider);
    }
  }

  /// Refreshes the currently active child's progress analytics.
  Future<void> refreshProgress({AuthProvider? authProvider}) async {
    if (_activeChildId != null) {
      await loadProgress(_activeChildId!, authProvider: authProvider);
    }
  }
}
