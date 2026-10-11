import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/audio_service.dart';

/// State management controller for parent/educator settings and audio preferences.
class SettingsProvider extends ChangeNotifier {
  final AudioService _audioService;

  SettingsProvider({AudioService? audioService})
      : _audioService = audioService ?? AudioService();

  Locale _locale = AppConstants.defaultLocale;
  double _volume = AppConstants.defaultVolume;
  int _sessionDurationMinutes = AppConstants.defaultSessionDurationMinutes;
  bool _soundEffectsEnabled = AppConstants.defaultSoundEffectsEnabled;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == AppConstants.langAr;
  double get volume => _volume;
  int get sessionDurationMinutes => _sessionDurationMinutes;
  bool get soundEffectsEnabled => _soundEffectsEnabled;

  /// Toggles between English and Arabic locales.
  void toggleLocale() {
    _locale = isArabic
        ? const Locale(AppConstants.langEn)
        : const Locale(AppConstants.langAr);
    notifyListeners();
  }

  /// Sets a specific locale.
  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  /// Updates volume level and synchronizes with [AudioService].
  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    _audioService.setVolume(_volume);
    notifyListeners();
  }

  /// Sets maximum lesson duration in minutes.
  void setSessionDuration(int minutes) {
    _sessionDurationMinutes = minutes.clamp(1, 30);
    notifyListeners();
  }

  /// Toggles sound effects.
  void toggleSoundEffects(bool enabled) {
    _soundEffectsEnabled = enabled;
    notifyListeners();
  }
}
