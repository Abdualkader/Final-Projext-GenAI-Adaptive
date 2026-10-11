import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../models/vocabulary_item_model.dart';
import '../repositories/vocabulary_repository.dart';
import '../services/audio_service.dart';

/// State management controller for vocabulary presentation, batch cycling, and audio pronunciation.
class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository _vocabularyRepository;
  final AudioService _audioService;

  VocabularyProvider({
    VocabularyRepository? vocabularyRepository,
    AudioService? audioService,
  })  : _vocabularyRepository =
            vocabularyRepository ?? BaseVocabularyRepository(),
        _audioService = audioService ?? AudioService();

  UiState<List<VocabularyItemModel>> _uiState = const UiState.initial();
  List<VocabularyItemModel> _items = [];
  int _currentIndex = 0;
  String _currentCategoryId = 'animals';
  bool _isPlayingAudio = false;

  UiState<List<VocabularyItemModel>> get uiState => _uiState;
  List<VocabularyItemModel> get items => _items;
  int get currentIndex => _currentIndex;
  String get currentCategoryId => _currentCategoryId;
  bool get isPlayingAudio => _isPlayingAudio;

  VocabularyItemModel? get currentItem {
    if (_items.isEmpty || _currentIndex >= _items.length) return null;
    return _items[_currentIndex];
  }

  bool get hasNext => _currentIndex < _items.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// Loads vocabulary items for a given category.
  Future<void> loadVocabulary(String categoryId, {int? maxDifficulty}) async {
    _currentCategoryId = categoryId;
    _currentIndex = 0;
    _uiState = const UiState.loading();
    notifyListeners();

    try {
      final list = await _vocabularyRepository.getVocabularyForCategory(
        categoryId,
        maxDifficulty: maxDifficulty,
      );
      _items = list;
      if (list.isEmpty) {
        _uiState = const UiState.empty();
      } else {
        _uiState = UiState.success(list);
      }
    } catch (e) {
      _uiState = UiState.error(
        e is AppException
            ? e
            : AppException(message: 'Failed to load vocabulary items: $e'),
      );
    }
    notifyListeners();
  }

  /// Advances to the next vocabulary item.
  void nextItem() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Navigates to the previous vocabulary item.
  void previousItem() {
    if (hasPrevious) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Plays pronunciation audio for the active vocabulary item.
  Future<void> playCurrentAudio(bool isArabic) async {
    final item = currentItem;
    if (item == null) return;

    final path = isArabic ? item.audioUrlAr : item.audioUrlEn;
    if (path.isEmpty) return;

    _isPlayingAudio = true;
    notifyListeners();

    try {
      await _audioService.playVocabularyAudio(path);
    } catch (e) {
      debugPrint('VocabularyProvider audio playback notice: $e');
    } finally {
      _isPlayingAudio = false;
      notifyListeners();
    }
  }
}
