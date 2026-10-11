import 'app_routes.dart';

/// Navigation route guard responsible for evaluating access permissions.
/// Distinguishes between open child-accessible screens and protected parent/educator screens.
class RouteGuard {
  /// Routes that require parent or educator authentication.
  static const Set<String> protectedRoutes = {
    AppRoutes.parentChildSelection,
    AppRoutes.parentDashboard,
    AppRoutes.parentSettings,
  };

  /// Routes that are open to children without requiring login.
  static const Set<String> openRoutes = {
    AppRoutes.initial,
    AppRoutes.childHome,
    AppRoutes.childCategories,
    AppRoutes.childLearning,
    AppRoutes.childQuiz,
    AppRoutes.parentLogin,
    AppRoutes.systemVerification,
  };

  /// Determines if a given route name requires authentication.
  static bool isProtected(String? routeName) {
    if (routeName == null) return false;
    return protectedRoutes.contains(routeName);
  }

  /// Verifies whether access should be granted based on authentication status.
  static bool canAccess(String? routeName, {required bool isAuthenticated}) {
    if (!isProtected(routeName)) return true;
    return isAuthenticated;
  }
}
