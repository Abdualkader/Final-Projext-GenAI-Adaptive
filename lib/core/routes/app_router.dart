import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../screens/child/category_selection_screen.dart';
import '../../screens/child/home_screen.dart';
import '../../screens/child/matching_game_screen.dart';
import '../../screens/child/bubble_pop_game_screen.dart';
import '../../screens/child/quiz_screen.dart';
import '../../screens/child/vocabulary_learning_screen.dart';
import '../../screens/developer/backend_verification_screen.dart';
import '../../screens/parent/child_selection_screen.dart';
import '../../screens/parent/login_screen.dart';
import '../../screens/parent/progress_dashboard_screen.dart';
import '../../screens/parent/settings_screen.dart';
import '../../repositories/mock_data_repository.dart';
import '../../models/quiz_question_model.dart';
import 'app_routes.dart';
import 'route_guard.dart';

/// Centralized router for generating application routes, passing typed arguments,
/// and enforcing route guards.
class AppRouter {
  /// Generates a [Route] based on [RouteSettings] and authentication state.
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    VoidCallback? onToggleLocale,
    bool isAuthenticated = false,
    AuthProvider? authProvider,
  }) {
    final routeName = settings.name ?? AppRoutes.childHome;

    // Check Route Guard
    final effectiveAuth = isAuthenticated || (authProvider?.isAuthenticated ?? false);
    if (RouteGuard.isProtected(routeName) && !effectiveAuth) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => LoginScreen(
          onToggleLocale: onToggleLocale,
          authProvider: authProvider,
        ),
      );
    }

    switch (routeName) {
      case AppRoutes.initial:
      case AppRoutes.childHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(onToggleLocale: onToggleLocale ?? () {}),
        );

      case AppRoutes.childCategories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategorySelectionScreen(),
        );

      case AppRoutes.childLearning:
        final categoryId =
            settings.arguments is String ? settings.arguments as String : 'animals';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VocabularyLearningScreen(categoryId: categoryId),
        );

      case AppRoutes.childQuiz:
        String categoryId = 'animals';
        bool fullQuiz = false;
        bool useAi = false;
        int? count;
        if (settings.arguments is String) {
          categoryId = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          categoryId = (map['categoryId'] as String?) ?? 'animals';
          fullQuiz = (map['full'] as bool?) ?? false;
          useAi = (map['useAi'] as bool?) ?? false;
          count = map['count'] as int?;
        }

        final List<QuizQuestionModel>? questions = (!useAi &&
                (fullQuiz || (count != null && count > 1)))
            ? MockDataRepository.getQuizQuestionsForCategory(categoryId,
                count: count ?? 5)
            : null;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => QuizScreen(
            categoryId: categoryId,
            questions: questions,
            useAi: useAi,
          ),
        );

      case AppRoutes.childMatchingGame:
        String categoryId = 'animals';
        int? difficulty;
        if (settings.arguments is String) {
          categoryId = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          categoryId = (map['categoryId'] as String?) ?? 'animals';
          difficulty = map['difficultyLevel'] as int?;
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MatchingGameScreen(
            categoryId: categoryId,
            difficultyLevel: difficulty,
          ),
        );

      case AppRoutes.childBubbleGame:
        String categoryId = 'letters';
        if (settings.arguments is String) {
          categoryId = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          categoryId = (map['categoryId'] as String?) ?? 'letters';
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BubblePopGameScreen(
            categoryId: categoryId,
          ),
        );

      case AppRoutes.parentLogin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoginScreen(
            onToggleLocale: onToggleLocale,
            authProvider: authProvider,
          ),
        );

      case AppRoutes.parentChildSelection:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChildSelectionScreen(
            authProvider: authProvider,
            onToggleLocale: onToggleLocale,
          ),
        );

      case AppRoutes.parentDashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProgressDashboardScreen(),
        );

      case AppRoutes.parentSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SettingsScreen(onToggleLocale: onToggleLocale ?? () {}),
        );

      case AppRoutes.systemVerification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BackendVerificationScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(onToggleLocale: onToggleLocale ?? () {}),
        );
    }
  }
}

