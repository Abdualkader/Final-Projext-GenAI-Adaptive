import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';

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

  /// Updates playback volume (0.0 to 1.0).
  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    debugPrint('AudioService: Volume set to ${(_volume * 100).toInt()}%');
  }

  /// Plays pronunciation audio for a vocabulary word.
  Future<void> playVocabularyAudio(String audioSource) async {
    try {
      _currentAudioSource = audioSource;
      _isPlaying = true;
      debugPrint('AudioService: Playing vocabulary audio -> $audioSource (Vol: $_volume)');
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

  /// Plays gentle, sensory-calibrated positive reinforcement chime (Task 10).
  Future<void> playSuccessChime() async {
    try {
      debugPrint('AudioService: Playing gentle star celebration chime 🌟');
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
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('AudioService gentle retry notice: $e');
    }
  }

  /// Halts any active audio playback.
  Future<void> stop() async {
    _isPlaying = false;
    _currentAudioSource = null;
    debugPrint('AudioService: Playback stopped');
  }
}
