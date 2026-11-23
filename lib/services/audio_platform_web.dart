// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Web implementation of audio playback utilizing Web Audio API and Web Speech API.
class AudioPlatform {
  static void playChime({required bool isSuccess, double volume = 0.8}) {
    try {
      if (js.context.hasProperty('playAsdChime')) {
        js.context.callMethod('playAsdChime', [isSuccess, volume]);
      }
    } catch (_) {}
  }

  static void speak(String text, {required String language, double volume = 0.8}) {
    try {
      if (js.context.hasProperty('speakAsdWord')) {
        js.context.callMethod('speakAsdWord', [text, language, volume]);
      }
    } catch (_) {}
  }

  static void playAudioUrl(
    String url, {
    double volume = 0.8,
    String? fallbackText,
    String? language,
  }) {
    try {
      if (js.context.hasProperty('playAsdAudio')) {
        js.context.callMethod('playAsdAudio', [url, volume, fallbackText, language]);
      } else if (fallbackText != null) {
        speak(fallbackText, language: language ?? 'en', volume: volume);
      }
    } catch (_) {}
  }

  static void stop() {
    try {
      if (js.context.hasProperty('stopAsdAudio')) {
        js.context.callMethod('stopAsdAudio');
      }
    } catch (_) {}
  }
}
