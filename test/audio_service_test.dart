import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/services/audio_service.dart';

void main() {
  group('AudioService & Browser Web Audio Integration Tests', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
      audioService.setVolume(0.8);
    });

    tearDown(() async {
      await audioService.stop();
    });

    test('Initializes with default volume and volume clamping', () {
      expect(audioService.volume, 0.8);
      audioService.setVolume(1.5);
      expect(audioService.volume, 1.0);
      audioService.setVolume(-0.2);
      expect(audioService.volume, 0.0);
      audioService.setVolume(0.75);
      expect(audioService.volume, 0.75);
    });

    test('Plays vocabulary pronunciation for English and Arabic items', () async {
      expect(audioService.isPlaying, false);

      // 1. Play with explicit word text and language
      final future1 = audioService.playVocabularyAudio(
        'vocabulary/audio/en/cat.mp3',
        wordText: 'Cat',
        language: 'en',
      );
      expect(audioService.isPlaying, true);
      expect(audioService.currentAudioSource, 'vocabulary/audio/en/cat.mp3');
      await future1;
      expect(audioService.isPlaying, false);

      // 2. Play with implicit extraction from dictionary
      final future2 = audioService.playVocabularyAudio('vocabulary/audio/ar/cat.mp3');
      expect(audioService.isPlaying, true);
      await future2;
      expect(audioService.isPlaying, false);
    });

    test('Speaks text prompts for quiz questions or instructions', () async {
      await audioService.speakText('Where is the Cat?', language: 'en');
      await audioService.speakText('أين هي القطة؟', language: 'ar');
    });

    test('Plays gentle celebration and retry chimes without throwing', () async {
      await audioService.playSuccessChime();
      await audioService.playGentleRetryChime();
    });

    test('Halts playback safely on stop', () async {
      final future = audioService.playVocabularyAudio('vocabulary/audio/en/dog.mp3');
      expect(audioService.isPlaying, true);
      await audioService.stop();
      expect(audioService.isPlaying, false);
      expect(audioService.currentAudioSource, isNull);
      await future;
    });
  });
}
