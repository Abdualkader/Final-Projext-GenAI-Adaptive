import 'package:flutter/foundation.dart';
import '../models/quiz_result_model.dart';
import '../repositories/user_repository.dart';

/// Actions that the adaptive engine can take after evaluating child performance.
enum AdaptiveAction {
  increase,
  maintain,
  decrease,
}

/// Structured, explainable evaluation result produced by [AdaptiveDifficultyService].
/// Satisfies Week 12 Tasks 7, 8, 9, and 10:
/// - Deterministic and explainable (Task 7)
/// - Strictly bounded between 1 (Easy) and 3 (Hard) (Task 8)
/// - Personalized recommendations for category focus (Task 9)
/// - Evaluation window gating to avoid unstable single-answer adjustments (Task 10)
class AdaptiveEvaluationResult {
  final int previousDifficulty;
  final int newDifficulty;
  final AdaptiveAction action;
  final double accuracy;
  final int totalQuestionsEvaluated;
  final int correctCount;
  final String explanationEn;
  final String explanationAr;
  final bool difficultyChanged;
  final String? recommendedCategory;
  final Map<String, double> categoryAccuracies;

  const AdaptiveEvaluationResult({
    required this.previousDifficulty,
    required this.newDifficulty,
    required this.action,
    required this.accuracy,
    required this.totalQuestionsEvaluated,
    required this.correctCount,
    required this.explanationEn,
    required this.explanationAr,
    required this.difficultyChanged,
    this.recommendedCategory,
    this.categoryAccuracies = const {},
  });

  String localizedExplanation(bool isArabic) =>
      isArabic ? explanationAr : explanationEn;

  Map<String, dynamic> toMap() {
    return {
      'previousDifficulty': previousDifficulty,
      'newDifficulty': newDifficulty,
      'action': action.name,
      'accuracy': accuracy,
      'totalQuestionsEvaluated': totalQuestionsEvaluated,
      'correctCount': correctCount,
      'explanationEn': explanationEn,
      'explanationAr': explanationAr,
      'difficultyChanged': difficultyChanged,
      'recommendedCategory': recommendedCategory,
      'categoryAccuracies': categoryAccuracies,
    };
  }
}

/// Service implementing the deterministic, explainable adaptive learning engine
/// for children with Autism Spectrum Disorder (ASD).
class AdaptiveDifficultyService {
  /// Minimum number of attempts required before difficulty can be adapted (Task 10).
  /// Prevents volatile oscillations from a single accidental tap or distraction.
  final int minEvaluationWindow;

  /// Evaluation window size (number of recent results inspected).
  final int evaluationWindow;

  /// Accuracy threshold at or above which difficulty increases (Task 7).
  final double highAccuracyThreshold;

  /// Accuracy threshold below which difficulty decreases (Task 7).
  final double lowAccuracyThreshold;

  const AdaptiveDifficultyService({
    this.minEvaluationWindow = 3,
    this.evaluationWindow = 5,
    this.highAccuracyThreshold = 0.85,
    this.lowAccuracyThreshold = 0.60,
  });

  /// Evaluates child performance over the recent window of quiz results and computes
  /// the next deterministic difficulty level bounded strictly to [1..3] (Tasks 7, 8, 10).
  AdaptiveEvaluationResult evaluateDifficulty({
    required int currentDifficulty,
    required List<QuizResultModel> recentResults,
    String? activeCategoryId,
  }) {
    // Task 8: Difficulty Boundaries enforcement (1=Easy, 2=Medium, 3=Hard)
    final clampedCurrent = currentDifficulty.clamp(1, 3);

    // Filter to the evaluation window (most recent N results)
    final windowResults = recentResults.length > evaluationWindow
        ? recentResults.sublist(recentResults.length - evaluationWindow)
        : recentResults;

    final sampleCount = windowResults.length;

    // Task 10: Require sufficient performance data before adjusting
    if (sampleCount < minEvaluationWindow) {
      final correctCount = windowResults.where((r) => r.isCorrect).length;
      final currentAccuracy = sampleCount > 0 ? correctCount / sampleCount : 0.0;

      return AdaptiveEvaluationResult(
        previousDifficulty: clampedCurrent,
        newDifficulty: clampedCurrent,
        action: AdaptiveAction.maintain,
        accuracy: currentAccuracy,
        totalQuestionsEvaluated: sampleCount,
        correctCount: correctCount,
        explanationEn:
            'Evaluating performance: at least $minEvaluationWindow attempts required before adjusting difficulty ($sampleCount/$minEvaluationWindow completed).',
        explanationAr:
            'جارٍ تقييم الأداء: يلزم $minEvaluationWindow محاولات على الأقل قبل تعديل مستوى الصعوبة ($sampleCount/$minEvaluationWindow مكتملة).',
        difficultyChanged: false,
        recommendedCategory: activeCategoryId,
      );
    }

    final correctCount = windowResults.where((r) => r.isCorrect).length;
    final accuracy = sampleCount > 0 ? (correctCount / sampleCount) : 0.0;

    int newDifficulty = clampedCurrent;
    AdaptiveAction action = AdaptiveAction.maintain;
    String explanationEn = '';
    String explanationAr = '';

    // Task 7: Deterministic adaptive logic
    if (accuracy >= highAccuracyThreshold) {
      if (clampedCurrent < 3) {
        newDifficulty = clampedCurrent + 1;
        action = AdaptiveAction.increase;
        explanationEn =
            'High performance (${(accuracy * 100).round()}% >= ${(highAccuracyThreshold * 100).round()}%). Advancing difficulty to level $newDifficulty.';
        explanationAr =
            'أداء متميز (نسبة الدقة ${(accuracy * 100).round()}%). تم رفع مستوى الصعوبة إلى المستوى $newDifficulty.';
      } else {
        newDifficulty = 3;
        action = AdaptiveAction.maintain;
        explanationEn =
            'Consistently excellent performance at maximum difficulty level 3 (${(accuracy * 100).round()}%). Maintaining advanced challenge.';
        explanationAr =
            'إتقان ممتاز في المستوى الأقصى 3 (نسبة الدقة ${(accuracy * 100).round()}%). الاستمرار في المستوى المتقدم.';
      }
    } else if (accuracy < lowAccuracyThreshold) {
      if (clampedCurrent > 1) {
        newDifficulty = clampedCurrent - 1;
        action = AdaptiveAction.decrease;
        explanationEn =
            'Performance indicates review needed (${(accuracy * 100).round()}% < ${(lowAccuracyThreshold * 100).round()}%). Reducing difficulty to level $newDifficulty to reinforce fundamentals.';
        explanationAr =
            'الأداء يشير إلى الحاجة للتعزيز (نسبة الدقة ${(accuracy * 100).round()}%). تم تقليل الصعوبة إلى المستوى $newDifficulty لدعم التعلّم.';
      } else {
        newDifficulty = 1;
        action = AdaptiveAction.maintain;
        explanationEn =
            'Currently at foundational difficulty level 1 (${(accuracy * 100).round()}%). Maintaining level with personalized review items.';
        explanationAr =
            'أنت في المستوى التأسيسي 1 (نسبة الدقة ${(accuracy * 100).round()}%). الاستمرار في المستوى لدعم المهارات الأساسية.';
      }
    } else {
      newDifficulty = clampedCurrent;
      action = AdaptiveAction.maintain;
      explanationEn =
          'Stable performance (${(accuracy * 100).round()}%). Maintaining difficulty level $newDifficulty for continuous reinforcement.';
      explanationAr =
          'أداء مستقر (نسبة الدقة ${(accuracy * 100).round()}%). الحفاظ على المستوى $newDifficulty لترسيخ المفاهيم.';
    }

    // Task 8: Strict boundary safety clamp
    newDifficulty = newDifficulty.clamp(1, 3);
    final difficultyChanged = newDifficulty != clampedCurrent;

    // Task 9: Personalized Exercise Selection (analyze category needs)
    final categoryAccuracies = _computeCategoryAccuracies(recentResults);
    final recommendedCategory =
        _recommendCategoryFocus(categoryAccuracies, defaultCategory: activeCategoryId);

    return AdaptiveEvaluationResult(
      previousDifficulty: clampedCurrent,
      newDifficulty: newDifficulty,
      action: action,
      accuracy: accuracy,
      totalQuestionsEvaluated: sampleCount,
      correctCount: correctCount,
      explanationEn: explanationEn,
      explanationAr: explanationAr,
      difficultyChanged: difficultyChanged,
      recommendedCategory: recommendedCategory,
      categoryAccuracies: categoryAccuracies,
    );
  }

  /// Calculates the updated child difficulty and persists it to the child profile
  /// via [UserRepository] when sufficient performance data exists (Task 10).
  Future<AdaptiveEvaluationResult> updateChildDifficulty(
    String childId, {
    required int currentDifficulty,
    required List<QuizResultModel> recentResults,
    required UserRepository userRepository,
    String? activeCategoryId,
  }) async {
    final result = evaluateDifficulty(
      currentDifficulty: currentDifficulty,
      recentResults: recentResults,
      activeCategoryId: activeCategoryId,
    );

    if (result.difficultyChanged) {
      try {
        await userRepository.updateChildDifficulty(childId, result.newDifficulty);
        debugPrint(
          'AdaptiveDifficultyService: Updated child $childId difficulty to ${result.newDifficulty}',
        );
      } catch (e) {
        debugPrint(
          'AdaptiveDifficultyService: Error saving updated difficulty for $childId: $e',
        );
      }
    }

    return result;
  }

  /// Groups results by category and calculates accuracy for each (Task 9).
  Map<String, double> _computeCategoryAccuracies(List<QuizResultModel> results) {
    final Map<String, List<bool>> grouped = {};
    for (final r in results) {
      // In our question ID naming convention, category is often prefix or recorded
      final category = _extractCategoryFromQuestionId(r.questionId);
      grouped.putIfAbsent(category, () => []).add(r.isCorrect);
    }

    final Map<String, double> accuracies = {};
    grouped.forEach((category, list) {
      final correct = list.where((v) => v).length;
      accuracies[category] = list.isNotEmpty ? (correct / list.length) : 0.0;
    });

    return accuracies;
  }

  /// Recommends a category that needs reinforcement or exploration (Task 9).
  /// For example: struggles with Colors (< 60%) -> More Color exercises.
  String? _recommendCategoryFocus(
    Map<String, double> categoryAccuracies, {
    String? defaultCategory,
  }) {
    if (categoryAccuracies.isEmpty) return defaultCategory;

    // Find category with lowest accuracy (< 60%) for reinforcement
    String? lowestCategory;
    double lowestAccuracy = 1.0;

    categoryAccuracies.forEach((cat, acc) {
      if (acc < lowestAccuracy) {
        lowestAccuracy = acc;
        lowestCategory = cat;
      }
    });

    if (lowestCategory != null && lowestAccuracy < lowAccuracyThreshold) {
      return lowestCategory;
    }

    return defaultCategory;
  }

  String _extractCategoryFromQuestionId(String questionId) {
    final lower = questionId.toLowerCase();
    if (lower.contains('animal')) return 'animals';
    if (lower.contains('color') || lower.contains('colour')) return 'colors';
    if (lower.contains('number')) return 'numbers';
    if (lower.contains('letter')) return 'letters';
    return 'general';
  }
}
