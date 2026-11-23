import 'package:flutter/foundation.dart';
import '../core/errors/app_exceptions.dart';
import '../core/errors/ui_state.dart';
import '../core/utils/content_validator.dart';
import '../models/vocabulary_item_model.dart';
import '../repositories/vocabulary_repository.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// State management controller for vocabulary presentation, batch cycling, and audio pronunciation.
class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository _vocabularyRepository;
  final AudioService _audioService;
  final StorageService _storageService;

  VocabularyProvider({
    VocabularyRepository? vocabularyRepository,
    AudioService? audioService,
    StorageService? storageService,
  })  : _vocabularyRepository =
            vocabularyRepository ?? BaseVocabularyRepository(),
        _audioService = audioService ?? AudioService(),
        _storageService = storageService ?? StorageService();

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
      final validList = ContentValidator.filterValidItems(list);
      _items = validList;
      if (validList.isEmpty) {
        _uiState = const UiState.empty();
      } else {
        _uiState = UiState.success(validList);
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

  /// Sets the active item by index.
  void goToIndex(int index) {
    if (index >= 0 && index < _items.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Plays pronunciation audio for the active vocabulary item.
  Future<void> playCurrentAudio(bool isArabic) async {
    final item = currentItem;
    if (item == null) return;
    await playAudioFor(item, isArabic: isArabic);
  }

  /// Plays pronunciation audio for a specific vocabulary item.
  /// Handles missing audio gracefully without throwing or crashing (Task 12).
  Future<void> playAudioFor(VocabularyItemModel item, {required bool isArabic}) async {
    final rawPath = isArabic ? item.audioUrlAr : item.audioUrlEn;
    final word = isArabic ? item.wordAr : item.wordEn;

    _isPlayingAudio = true;
    notifyListeners();

    try {
      if (rawPath.trim().isEmpty) {
        await _audioService.speakText(word, language: isArabic ? 'ar' : 'en');
      } else {
        final resolvedUrl = await _storageService.getDownloadUrl(rawPath);
        await _audioService.playVocabularyAudio(
          resolvedUrl,
          wordText: word,
          language: isArabic ? 'ar' : 'en',
        );
      }
    } catch (e) {
      debugPrint('VocabularyProvider audio playback notice (gracefully handled): $e');
    } finally {
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  /// Halts any active audio playback.
  Future<void> stopAudio() async {
    _isPlayingAudio = false;
    await _audioService.stop();
    notifyListeners();
  }
}
