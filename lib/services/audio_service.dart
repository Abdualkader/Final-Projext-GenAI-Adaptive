import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import 'audio_platform_stub.dart'
    if (dart.library.html) 'audio_platform_web.dart';

/// Clean abstraction service for multi-sensory auditory prompts and gentle feedback chimes.
/// Designed for calm, predictable auditory experiences adhering to ASD guidelines.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  double _volume = AppConstants.defaultVolume;
  bool _isPlaying = false;
  String? _currentAudioSource;

  double get volume => _volume;
  bool get isPlaying => _isPlaying;
  String? get currentAudioSource => _currentAudioSource;

  static const Map<String, Map<String, String>> _vocabularyWordMap = {
    // Animals
    'cat': {'en': 'Cat', 'ar': 'قِطَّة'},
    'dog': {'en': 'Dog', 'ar': 'كَلْب'},
    'rabbit': {'en': 'Rabbit', 'ar': 'أَرْنَب'},
    'bird': {'en': 'Bird', 'ar': 'عُصْفُور'},
    'cow': {'en': 'Cow', 'ar': 'بَقَرَة'},
    'lion': {'en': 'Lion', 'ar': 'أَسَد'},
    'elephant': {'en': 'Elephant', 'ar': 'فِيل'},
    'fish': {'en': 'Fish', 'ar': 'سَمَكَة'},
    // Colors
    'red': {'en': 'Red', 'ar': 'أَحْمَر'},
    'blue': {'en': 'Blue', 'ar': 'أَزْرَق'},
    'green': {'en': 'Green', 'ar': 'أَخْضَر'},
    'yellow': {'en': 'Yellow', 'ar': 'أَصْفَر'},
    'orange': {'en': 'Orange', 'ar': 'بُرْتُقَالِي'},
    'purple': {'en': 'Purple', 'ar': 'بَنَفْسَجِي'},
    // Numbers
    'one': {'en': 'One', 'ar': 'وَاحِد'},
    'two': {'en': 'Two', 'ar': 'اِثْنَان'},
    'three': {'en': 'Three', 'ar': 'ثَلَاثَة'},
    'four': {'en': 'Four', 'ar': 'أَرْبَعَة'},
    'five': {'en': 'Five', 'ar': 'خَمْسَة'},
    'six': {'en': 'Six', 'ar': 'سِتَّة'},
    'seven': {'en': 'Seven', 'ar': 'سَبْعَة'},
    'eight': {'en': 'Eight', 'ar': 'ثَمَانِيَة'},
    'nine': {'en': 'Nine', 'ar': 'تِسْعَة'},
    'ten': {'en': 'Ten', 'ar': 'عَشَرَة'},
    // Letters & letter shortcuts
    'a': {'en': 'Letter A', 'ar': 'أَلِف'},
    'b': {'en': 'Letter B', 'ar': 'بَاء'},
    't': {'en': 'Letter T', 'ar': 'تَاء'},
    'th': {'en': 'Letter Th', 'ar': 'ثَاء'},
    'j': {'en': 'Letter J', 'ar': 'جِيم'},
    'h': {'en': 'Letter H', 'ar': 'حَاء'},
    'kh': {'en': 'Letter Kh', 'ar': 'خَاء'},
    'd': {'en': 'Letter D', 'ar': 'دَال'},
    'dh': {'en': 'Letter Dh', 'ar': 'ذَال'},
    'r': {'en': 'Letter R', 'ar': 'رَاء'},
    'z': {'en': 'Letter Z', 'ar': 'زَاي'},
    's': {'en': 'Letter S', 'ar': 'سِين'},
    'sh': {'en': 'Letter Sh', 'ar': 'شِين'},
    'sad': {'en': 'Letter S', 'ar': 'صَاد'},
    'dad': {'en': 'Letter D', 'ar': 'ضَاد'},
    't2': {'en': 'Letter T', 'ar': 'طَاء'},
    'zh': {'en': 'Letter Zh', 'ar': 'ظَاء'},
    'ayn': {'en': 'Letter Ayn', 'ar': 'عَيْن'},
    'gh': {'en': 'Letter Gh', 'ar': 'غَيْن'},
    'f': {'en': 'Letter F', 'ar': 'فَاء'},
    'q': {'en': 'Letter Q', 'ar': 'قَاف'},
    'k': {'en': 'Letter K', 'ar': 'كَاف'},
    'l': {'en': 'Letter L', 'ar': 'لاَم'},
    'm': {'en': 'Letter M', 'ar': 'مِيم'},
    'n': {'en': 'Letter N', 'ar': 'نُون'},
    'ha': {'en': 'Letter H', 'ar': 'هَاء'},
    'w': {'en': 'Letter W', 'ar': 'وَاو'},
    'y': {'en': 'Letter Y', 'ar': 'يَاء'},
    'alif': {'en': 'Letter A', 'ar': 'أَلِف'},
    'alef': {'en': 'Letter A', 'ar': 'أَلِف'},
    'baa': {'en': 'Letter B', 'ar': 'بَاء'},
    'taa': {'en': 'Letter T', 'ar': 'تَاء'},
    'thaa': {'en': 'Letter Th', 'ar': 'ثَاء'},
    'jeem': {'en': 'Letter J', 'ar': 'جِيم'},
    'haa': {'en': 'Letter H', 'ar': 'حَاء'},
    'khaa': {'en': 'Letter Kh', 'ar': 'خَاء'},
    'daal': {'en': 'Letter D', 'ar': 'دَال'},
    'thaal': {'en': 'Letter Dh', 'ar': 'ذَال'},
    'raa': {'en': 'Letter R', 'ar': 'رَاء'},
    'zaay': {'en': 'Letter Z', 'ar': 'زَاي'},
    'seen': {'en': 'Letter S', 'ar': 'سِين'},
    'sheen': {'en': 'Letter Sh', 'ar': 'شِين'},
    'saad': {'en': 'Letter S', 'ar': 'صَاد'},
    'daad': {'en': 'Letter D', 'ar': 'ضَاد'},
    'ttaa': {'en': 'Letter T', 'ar': 'طَاء'},
    'zhaa': {'en': 'Letter Zh', 'ar': 'ظَاء'},
    'ghayn': {'en': 'Letter Gh', 'ar': 'غَيْن'},
    'faa': {'en': 'Letter F', 'ar': 'فَاء'},
    'qaaf': {'en': 'Letter Q', 'ar': 'قَاف'},
    'kaaf': {'en': 'Letter K', 'ar': 'كَاف'},
    'laam': {'en': 'Letter L', 'ar': 'لاَم'},
    'meem': {'en': 'Letter M', 'ar': 'مِيم'},
    'noon': {'en': 'Letter N', 'ar': 'نُون'},
    'hhaa': {'en': 'Letter H', 'ar': 'هَاء'},
    'waaw': {'en': 'Letter W', 'ar': 'وَاو'},
    'yaa': {'en': 'Letter Y', 'ar': 'يَاء'},
  };

  /// Updates playback volume (0.0 to 1.0).
  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    debugPrint('AudioService: Volume set to ${(_volume * 100).toInt()}%');
  }

  /// Plays pronunciation audio for a vocabulary word.
  Future<void> playVocabularyAudio(
    String audioSource, {
    String? wordText,
    String? language,
  }) async {
    try {
      _currentAudioSource = audioSource;
      _isPlaying = true;
      debugPrint('AudioService: Playing vocabulary audio -> $audioSource (Vol: $_volume)');

      final resolvedLang = language ?? (audioSource.contains('/ar/') ? 'ar' : 'en');
      String? resolvedText = wordText;

      final cleanKey = audioSource.split('/').last.split('.').first.toLowerCase();

      // If text not provided or needs translation matching the requested language
      if (resolvedText == null || resolvedText.isEmpty) {
        if (_vocabularyWordMap.containsKey(cleanKey)) {
          resolvedText = _vocabularyWordMap[cleanKey]![resolvedLang];
        } else {
          resolvedText = cleanKey;
        }
      } else {
        final currentText = resolvedText;
        final hasArabicChars = RegExp(r'[\u0600-\u06FF]').hasMatch(currentText);
        if (resolvedLang == 'ar' && !hasArabicChars) {
          // Look up Arabic equivalent
          for (final entry in _vocabularyWordMap.values) {
            if (entry['en']?.toLowerCase() == currentText.toLowerCase()) {
              resolvedText = entry['ar'];
              break;
            }
          }
        } else if (resolvedLang == 'en' && hasArabicChars) {
          // Look up English equivalent
          for (final entry in _vocabularyWordMap.values) {
            if (entry['ar'] == resolvedText) {
              resolvedText = entry['en'];
              break;
            }
          }
        }
      }

      AudioPlatform.playAudioUrl(
        audioSource,
        volume: _volume,
        fallbackText: resolvedText,
        language: resolvedLang,
      );

      // Simulates playback duration for current architecture stage
      await Future.delayed(const Duration(milliseconds: 600));
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
      throw AudioException(
        message: 'Could not play audio $audioSource: $e',
        originalError: e,
      );
    }
  }

  /// Speaks text directly using text-to-speech synthesis (e.g. for quiz prompts or instructions).
  Future<void> speakText(String text, {String language = 'en'}) async {
    try {
      debugPrint('AudioService: Speaking text -> "$text" ($language)');
      AudioPlatform.speak(text, language: language, volume: _volume);
    } catch (e) {
      debugPrint('AudioService speak notice: $e');
    }
  }

  /// Plays gentle, sensory-calibrated positive reinforcement chime (Task 10).
  Future<void> playSuccessChime() async {
    try {
      debugPrint('AudioService: Playing gentle star celebration chime 🌟');
      AudioPlatform.playChime(isSuccess: true, volume: _volume);
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint('AudioService celebration chime notice: $e');
    }
  }

  /// Plays soft, non-punitive neutral chime for gentle retry (Task 10).
  /// Strictly avoids harsh buzzer or alarm tones.
  Future<void> playGentleRetryChime() async {
    try {
      debugPrint('AudioService: Playing soft gentle retry chime 🌱');
      AudioPlatform.playChime(isSuccess: false, volume: _volume);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('AudioService gentle retry notice: $e');
    }
  }

  /// Halts any active audio playback.
  Future<void> stop() async {
    _isPlaying = false;
    _currentAudioSource = null;
    AudioPlatform.stop();
    debugPrint('AudioService: Playback stopped');
  }
}
