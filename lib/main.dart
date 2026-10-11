import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

import 'screens/child/home_screen.dart';
import 'screens/child/category_selection_screen.dart';
import 'screens/child/vocabulary_learning_screen.dart';
import 'screens/child/quiz_screen.dart';
import 'screens/parent/login_screen.dart';
import 'screens/parent/child_selection_screen.dart';
import 'screens/parent/progress_dashboard_screen.dart';
import 'screens/parent/settings_screen.dart';
import 'screens/developer/backend_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with Web options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const ASDLearningApp());
}

/// Root Application Widget with dynamic RTL/LTR bilingual state management.
class ASDLearningApp extends StatefulWidget {
  const ASDLearningApp({super.key});

  @override
  State<ASDLearningApp> createState() => _ASDLearningAppState();
}

class _ASDLearningAppState extends State<ASDLearningApp> {
  Locale _locale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASD Learning Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.childHome,
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
        settings,
        onToggleLocale: _toggleLocale,
      ),
      routes: {
        AppRoutes.childHome: (context) =>
            HomeScreen(onToggleLocale: _toggleLocale),
        AppRoutes.childCategories: (context) =>
            const CategorySelectionScreen(),
        AppRoutes.childLearning: (context) =>
            const VocabularyLearningScreen(),
        AppRoutes.childQuiz: (context) =>
            const QuizScreen(),
        AppRoutes.parentLogin: (context) =>
            const LoginScreen(),
        AppRoutes.parentChildSelection: (context) =>
            const ChildSelectionScreen(),
        AppRoutes.parentDashboard: (context) =>
            const ProgressDashboardScreen(),
        AppRoutes.parentSettings: (context) =>
            SettingsScreen(onToggleLocale: _toggleLocale),
        AppRoutes.systemVerification: (context) =>
            const BackendVerificationScreen(),
      },
    );
  }
}

