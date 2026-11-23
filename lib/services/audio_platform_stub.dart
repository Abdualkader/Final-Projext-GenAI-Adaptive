import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform implementation for audio playback on Desktop (Windows) / Unit Test runtimes.
class AudioPlatform {
  static bool get _isUnitTest =>
      Platform.environment.containsKey('FLUTTER_TEST');

  static void playChime({required bool isSuccess, double volume = 0.8}) {
    if (_isUnitTest) return;
    if (Platform.isWindows) {
      try {
        final freq = isSuccess ? '784' : '392';
        final dur = isSuccess ? '250' : '180';
        Process.start('powershell', [
          '-NoProfile',
          '-Command',
          "[console]::beep($freq, $dur)",
        ]);
      } catch (_) {}
    }
  }

  static Future<void> _playAudioFile(String filePath, double volume) async {
    try {
      final escaped = filePath.replaceAll("'", "''");
      final vol = volume.clamp(0.0, 1.0);
      await Process.start('powershell', [
        '-NoProfile',
        '-Command',
        "Add-Type -AssemblyName presentationCore; \$p = New-Object System.Windows.Media.MediaPlayer; \$p.Open([System.Uri]'$escaped'); \$p.Volume = $vol; \$p.Play(); Start-Sleep -Milliseconds 1500",
      ]);
    } catch (e) {
      debugPrint('AudioPlatform _playAudioFile notice: $e');
    }
  }

  static Future<void> _fetchAndPlayArabic(String text, double volume) async {
    try {
      final cleanText = text.trim();
      final cacheDir =
          Directory('${Directory.systemTemp.path}/asd_arabic_audio');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }

      final filename = 'ar_${cleanText.hashCode.abs()}.mp3';
      final file = File('${cacheDir.path}/$filename');

      if (!file.existsSync() || file.lengthSync() == 0) {
        final encoded = Uri.encodeComponent(cleanText);
        final url =
            'https://translate.google.com/translate_tts?ie=UTF-8&tl=ar&client=tw-ob&q=$encoded';
        final client = HttpClient();
        client.userAgent = 'Mozilla/5.0';
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode == 200) {
          final bytes = await response.fold<List<int>>(
              [], (acc, chunk) => acc..addAll(chunk));
          await file.writeAsBytes(bytes);
        }
      }

      if (file.existsSync() && file.lengthSync() > 0) {
        await _playAudioFile(file.path, volume);
        return;
      }
    } catch (e) {
      debugPrint('AudioPlatform _fetchAndPlayArabic notice: $e');
    }

    // Peaceful chime feedback if offline and not cached
    playChime(isSuccess: true, volume: volume);
  }

  static void speak(String text, {required String language, double volume = 0.8}) {
    if (_isUnitTest || text.trim().isEmpty) return;
    if (Platform.isWindows) {
      final isAr =
          language == 'ar' || RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      if (isAr) {
        _fetchAndPlayArabic(text, volume);
        return;
      }

      try {
        final safeText = text.replaceAll("'", "''");
        final volInt = (volume.clamp(0.0, 1.0) * 100).toInt();
        Process.start('powershell', [
          '-NoProfile',
          '-Command',
          "Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.Volume = $volInt; \$s.Speak('$safeText')",
        ]);
      } catch (_) {}
    }
  }

  static void playAudioUrl(
    String url, {
    double volume = 0.8,
    String? fallbackText,
    String? language,
  }) {
    if (_isUnitTest) return;
    if (url.isNotEmpty && File(url).existsSync()) {
      _playAudioFile(url, volume);
      return;
    }
    if (fallbackText != null && fallbackText.isNotEmpty) {
      speak(fallbackText, language: language ?? 'en', volume: volume);
    }
  }

  static void stop() {}
}

