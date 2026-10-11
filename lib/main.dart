import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/learning_session_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const ASDLearningApp());
}

/// Root Application Widget with MultiProvider state management
/// and dynamic RTL/LTR bilingual state management.
class ASDLearningApp extends StatefulWidget {
  final AuthProvider? authProvider;

  const ASDLearningApp({
    super.key,
    this.authProvider,
  });

  @override
  State<ASDLearningApp> createState() => _ASDLearningAppState();
}

class _ASDLearningAppState extends State<ASDLearningApp> {
  late final AuthProvider _authProvider;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider();

    // Task 9: Initialize language preference from authenticated user profile if available
    final prefLang = _authProvider.currentUser?.preferredLanguage;
    if (prefLang != null && (prefLang == 'ar' || prefLang == 'en')) {
      _locale = Locale(prefLang);
    }
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });

    if (_authProvider.isAuthenticated) {
      _authProvider.updatePreferredLanguage(_locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<CategoryProvider>(create: (_) => CategoryProvider()),
        ChangeNotifierProvider<VocabularyProvider>(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider<LearningSessionProvider>(create: (_) => LearningSessionProvider()),
        ChangeNotifierProvider<QuizProvider>(create: (_) => QuizProvider()),
        ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
      ],
      child: ListenableBuilder(
        listenable: _authProvider,
        builder: (context, _) {
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
              isAuthenticated: _authProvider.isAuthenticated,
              authProvider: _authProvider,
            ),
          );
        },
      ),
    );
  }
}
