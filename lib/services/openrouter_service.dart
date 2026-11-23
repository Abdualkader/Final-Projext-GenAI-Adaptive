import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Client service for communicating with OpenRouter API.
/// Connects to LLM models (e.g. meta-llama/llama-3.3-70b-instruct, google/gemma-3-27b-it)
/// to dynamically generate adaptive quiz exercises and learning games for children with ASD.
class OpenRouterService {
  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  // Active configuration
  String? _apiKey;
  String _model = 'meta-llama/llama-3.3-70b-instruct';

  // Standard OpenRouter endpoints
  static const String endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  // Recognized Models available on OpenRouter (Llama & Gemma)
  static const List<String> availableFreeModels = [
    'meta-llama/llama-3.3-70b-instruct',
    'google/gemma-3-27b-it',
    'google/gemma-3-12b-it',
    'google/gemma-3-4b-it',
    'meta-llama/llama-3.1-8b-instruct',
  ];

  String get model => _model;
  String? get apiKey => _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.trim().isNotEmpty;

  void configure({String? apiKey, String? model}) {
    if (apiKey != null) {
      _apiKey = apiKey.trim();
    }
    if (model != null && model.isNotEmpty) {
      _model = model.trim();
    }
  }

  /// Pings OpenRouter with a minimal test prompt to verify API key and model availability.
  Future<OpenRouterPingResult> testConnection({String? customKey}) async {
    final effectiveKey = customKey?.trim() ?? _apiKey;
    if (effectiveKey == null || effectiveKey.isEmpty) {
      return const OpenRouterPingResult(
        isSuccess: false,
        message: 'No OpenRouter API key provided.',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $effectiveKey',
              'HTTP-Referer': 'https://asd-learning-assistant.edu',
              'X-Title': 'ASD Adaptive Learning Assistant',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': 'Say "connected" only.'}
              ],
              'max_tokens': 10,
              'temperature': 0.1,
            }),
          )
          .timeout(const Duration(seconds: 8));

      stopwatch.stop();

      if (response.statusCode == 200) {
        return OpenRouterPingResult(
          isSuccess: true,
          message: 'Connected to $_model (${stopwatch.elapsedMilliseconds}ms)',
          durationMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        return OpenRouterPingResult(
          isSuccess: false,
          statusCode: response.statusCode,
          message: 'OpenRouter returned HTTP ${response.statusCode}: ${response.body}',
          durationMs: stopwatch.elapsedMilliseconds,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return OpenRouterPingResult(
        isSuccess: false,
        message: 'Connection failed: $e',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// Generates a structured JSON multiple-choice exercise via OpenRouter.
  Future<Map<String, dynamic>?> generateQuizExerciseJson({
    required String categoryId,
    required int difficultyLevel,
    required String preferredLanguage,
    required String exerciseType,
    required double recentAccuracy,
    required String vocabListDescription,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    if (!hasApiKey) {
      return null;
    }

    final systemPrompt = '''
You are an educational assistant for children with Autism Spectrum Disorder (ASD).
Create a simple, predictable, gentle multiple-choice exercise.
Domain category: "$categoryId".
Difficulty level: $difficultyLevel (1=Easy, 2=Medium, 3=Hard).
Exercise type: "$exerciseType".
Learner accuracy context: ${recentAccuracy.toStringAsFixed(2)}.
Allowed vocabulary pool (USE ONLY THESE ITEMS): [$vocabListDescription].

Rules:
1. Provide exactly 3 choices from the allowed vocabulary pool.
2. Provide non-empty English prompt ("promptEn") and Arabic prompt ("promptAr").
3. Set "correctChoiceId" to one of the 3 choices.
4. Output MUST be ONLY valid JSON matching this schema:
{
  "promptEn": "Where is the Cat?",
  "promptAr": "أين القطة؟",
  "correctChoiceId": "cat",
  "choices": [
    {"id": "cat", "labelEn": "Cat", "labelAr": "قطة"},
    {"id": "dog", labelEn: "Dog", labelAr: "كلب"},
    {"id": "bird", labelEn: "Bird", labelAr: "عصفور"}
  ]
}''';

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'HTTP-Referer': 'https://asd-learning-assistant.edu',
              'X-Title': 'ASD Adaptive Learning Assistant',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': 'Generate 1 ASD exercise now in pure JSON format only.'}
              ],
              'temperature': 0.2,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final rawText = data['choices']?[0]?['message']?['content']?.toString();
        if (rawText != null) {
          final cleaned = _extractJson(rawText);
          final parsed = jsonDecode(cleaned);
          if (parsed is Map) {
            return Map<String, dynamic>.from(parsed);
          }
        }
      } else {
        debugPrint('OpenRouterService: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('OpenRouterService call notice: $e');
    }

    return null;
  }

  /// Cleans markdown code fences (```json ... ```) to safely parse JSON.
  static String _extractJson(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}

/// Diagnostic result from testing OpenRouter API connectivity.
class OpenRouterPingResult {
  final bool isSuccess;
  final String message;
  final int? statusCode;
  final int durationMs;

  const OpenRouterPingResult({
    required this.isSuccess,
    required this.message,
    this.statusCode,
    this.durationMs = 0,
  });
}
