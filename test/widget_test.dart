import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/main.dart';
import 'package:asd_learning_assistant/screens/child/vocabulary_learning_screen.dart';
import 'package:asd_learning_assistant/screens/child/quiz_screen.dart';
import 'package:asd_learning_assistant/screens/parent/login_screen.dart';
import 'package:asd_learning_assistant/screens/parent/progress_dashboard_screen.dart';
import 'package:asd_learning_assistant/screens/parent/child_selection_screen.dart';
import 'package:asd_learning_assistant/screens/parent/settings_screen.dart';
import 'package:asd_learning_assistant/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget _buildTestWrapper(Widget child, [Locale locale = const Locale('en')]) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  testWidgets('Test 1: Home Screen renders all four Week 4 learning categories',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ASDLearningApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, Adam! 👋'), findsOneWidget);
    expect(find.text('What would you like to learn today?'), findsOneWidget);

    // Week 4 Task 2 four categories: Letters, Numbers, Colors, Animals
    expect(find.text('Letters'), findsOneWidget);
    expect(find.text('Numbers'), findsOneWidget);
    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);

    // Navigation and bottom bar
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Test 2: Dynamic RTL / LTR Bilingual Toggle works smoothly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ASDLearningApp());
    await tester.pumpAndSettle();

    final languageButton = find.byTooltip('Language / اللغة');
    expect(languageButton, findsOneWidget);

    // Toggle to Arabic RTL
    await tester.tap(languageButton);
    await tester.pumpAndSettle();

    expect(find.text('أهلاً يا آدم! 👋'), findsOneWidget);
    expect(find.text('الحروف'), findsOneWidget);
    expect(find.text('الأرقام'), findsOneWidget);
    expect(find.text('الألوان'), findsOneWidget);
    expect(find.text('الحيوانات'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);

    // Toggle back to English LTR
    await tester.tap(languageButton);
    await tester.pumpAndSettle();

    expect(find.text('Hello, Adam! 👋'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });

  testWidgets('Test 3: Vocabulary Learning Screen renders Task 4 elements and Next navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const VocabularyLearningScreen(categoryId: 'animals')));
    await tester.pumpAndSettle();

    // Large vocabulary labels
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('قِطَّة'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);

    // Audio Play Button (Task 4)
    final audioBtn = find.text('🔊  Play Audio');
    expect(audioBtn, findsOneWidget);
    await tester.tap(audioBtn);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('🔊 Cat • قِطَّة'), findsOneWidget);

    // Next Button (Task 4)
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Advance to 2 / 3: Dog
    expect(find.text('Dog'), findsOneWidget);
    expect(find.text('كَلْب'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('Test 4: Interactive Quiz Screen handles Positive Reinforcement (Task 10)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const QuizScreen(categoryId: 'animals')));
    await tester.pumpAndSettle();

    expect(find.text('Where is the dog?'), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Dog'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('Fish'), findsOneWidget);

    // Select Dog (Correct Option) -> Positive Reinforcement
    await tester.tap(find.text('Dog'));
    await tester.pumpAndSettle();

    expect(find.text('Great job! 🌟'), findsOneWidget);
    expect(find.text('You got it right! Keep going!'), findsOneWidget);
    expect(find.text('15'), findsOneWidget); // +3 stars
  });

  testWidgets('Test 5: Interactive Quiz Screen gentle corrective feedback for incorrect selection (No red/harsh UI)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const QuizScreen(categoryId: 'animals')));
    await tester.pumpAndSettle();

    // Select Cat (Incorrect Option for "Where is the dog?")
    await tester.tap(find.text('Cat'));
    await tester.pumpAndSettle();

    // Must show gentle encouraging feedback without harsh red or negative buzzer
    expect(find.text('Good effort! 🌱'), findsOneWidget);
    expect(find.text("Let's try another one together!"), findsOneWidget);
    expect(find.text('12'), findsOneWidget); // Stars preserved without penalty
  });

  testWidgets('Test 6: Parent Login Screen displays validation messages on empty or invalid input (Task 6)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Parent & Educator Portal'), findsWidgets);

    // Tap Enter Portal button with empty fields
    final signInBtn = find.text('Enter Portal');
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    // Expect validation message area to show error
    expect(find.text('Please enter your email address'), findsOneWidget);
  });

  testWidgets('Test 7: Child Selection Screen displays student profiles (Task 7)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const ChildSelectionScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Select Student Profile'), findsOneWidget);
    expect(find.text('Adam'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Omar'), findsOneWidget);
  });

  testWidgets('Test 8: Progress Dashboard Screen renders Task 8 metrics and filters',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const ProgressDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Progress Dashboard'), findsOneWidget);
    expect(find.text('Monitor learning and growth'), findsOneWidget);
    expect(find.text('Adam'), findsOneWidget);

    // Metrics
    expect(find.text('18'), findsOneWidget); // Mastered Vocabulary
    expect(find.text('78%'), findsOneWidget); // Accuracy
    expect(find.text('24'), findsOneWidget); // Total Sessions
    expect(find.text('4/wk'), findsOneWidget); // Frequency

    // Filters (Date & Category)
    expect(find.text('May 1 – May 31, 2025'), findsOneWidget);
    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('Animals'), findsWidgets);
    expect(find.text('Colors'), findsWidgets);
  });

  testWidgets('Test 9: Settings Screen renders Volume Slider and Session Duration (Task 9)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(SettingsScreen(onToggleLocale: () {})));
    await tester.pumpAndSettle();

    expect(find.text('Settings & Accessibility'), findsOneWidget);
    expect(find.text('Volume Control'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Session Duration'), findsOneWidget);
    expect(find.text('10 mins'), findsOneWidget);
    expect(find.text('15 mins'), findsOneWidget);
    expect(find.text('20 mins'), findsOneWidget);

    // Switch duration to 20 mins
    await tester.tap(find.text('20 mins'));
    await tester.pumpAndSettle();
    expect(find.text('20 minutes'), findsOneWidget);
  });

  testWidgets('Test 10: Task 12 Arabic RTL & English LTR Verification across screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Child Home in Arabic RTL
    await tester.pumpWidget(const ASDLearningApp());
    await tester.pumpAndSettle();

    // Switch to Arabic
    await tester.tap(find.byTooltip('Language / اللغة'));
    await tester.pumpAndSettle();

    expect(find.text('أهلاً يا آدم! 👋'), findsOneWidget);
    expect(find.text('الحروف'), findsOneWidget);
    expect(find.text('الأرقام'), findsOneWidget);
    expect(find.text('الألوان'), findsOneWidget);
    expect(find.text('الحيوانات'), findsOneWidget);

    // 2. Vocabulary in Arabic RTL
    await tester.pumpWidget(_buildTestWrapper(
      const VocabularyLearningScreen(categoryId: 'animals'),
      const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('قِطَّة'), findsOneWidget);
    expect(find.text('الحيوانات'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);

    // 3. Quiz in Arabic RTL
    await tester.pumpWidget(_buildTestWrapper(
      const QuizScreen(categoryId: 'animals'),
      const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('أين الكلب؟'), findsOneWidget);
    expect(find.text('كلب'), findsOneWidget);
    expect(find.text('قطة'), findsOneWidget);
    expect(find.text('سمكة'), findsOneWidget);

    // 4. Settings in Arabic RTL
    await tester.pumpWidget(_buildTestWrapper(
      SettingsScreen(onToggleLocale: () {}),
      const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات وملاءمة الحواس'), findsOneWidget);
    expect(find.text('مستوى الصوت'), findsOneWidget);
    expect(find.text('مدة الجلسة اليومية'), findsOneWidget);
    expect(find.text('١٥ دقيقة'), findsOneWidget);
  });
}

