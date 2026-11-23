/// Centralized route definitions for the ASD Learning Assistant.
class AppRoutes {
  static const String initial = '/';
  
  // Child Interface Routes
  static const String childHome = '/child/home';
  static const String childCategories = '/child/categories';
  static const String childLearning = '/child/learning';
  static const String childQuiz = '/child/quiz';
  static const String childMatchingGame = '/child/matching-game';
  static const String childBubbleGame = '/child/bubble-game';

  // Parent & Educator Interface Routes
  static const String parentLogin = '/parent/login';
  static const String parentChildSelection = '/parent/child-selection';
  static const String parentDashboard = '/parent/dashboard';
  static const String parentSettings = '/parent/settings';

  // System Diagnostics (Week 2 Preserved Verification)
  static const String systemVerification = '/system/verification';
}
