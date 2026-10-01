import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/main.dart';
import 'package:asd_learning_assistant/screens/child/vocabulary_learning_screen.dart';
import 'package:asd_learning_assistant/screens/child/quiz_screen.dart';
import 'package:asd_learning_assistant/screens/parent/progress_dashboard_screen.dart';
import 'package:asd_learning_assistant/screens/parent/child_selection_screen.dart';
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
  testWidgets('Test 1: Home Screen renders faithfully matching Wireframe 1',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ASDLearningApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, Adam! 👋'), findsOneWidget);
    expect(find.text('What would you like to learn today?'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Colours'), findsOneWidget);
    expect(find.text('Numbers'), findsOneWidget);
    expect(find.text('Letters'), findsOneWidget);
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
    expect(find.text('الحيوانات'), findsOneWidget);
    expect(find.text('الألوان'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);

    // Toggle back to English LTR
    await tester.tap(languageButton);
    await tester.pumpAndSettle();

    expect(find.text('Hello, Adam! 👋'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });

  testWidgets('Test 3: Vocabulary Learning Screen renders matching Wireframe 4',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const VocabularyLearningScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('قِطَّة'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byTooltip('Listen to pronunciation'), findsOneWidget);

    // Tap Audio
    await tester.tap(find.byTooltip('Listen to pronunciation'));
    await tester.pump();
    expect(find.text('🔊 Cat • قِطَّة'), findsOneWidget);
  });

  testWidgets('Test 4: Interactive Quiz Screen renders matching Wireframe 2',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWrapper(const QuizScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Where is the dog?'), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Dog'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('Fish'), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget);

    // Select Dog (Correct option)
    await tester.tap(find.text('Dog'));
    await tester.pumpAndSettle();

    // Verify Positive Reinforcement Mascot Banner
    expect(find.text('Excellent!'), findsOneWidget);
    expect(find.text('You found the dog!'), findsOneWidget);
    expect(find.text('15'), findsOneWidget); // +3 stars
  });

  testWidgets('Test 5: Progress Dashboard Screen renders matching Wireframe 3',
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
    expect(find.text('24'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Quiz Accuracy by Category'), findsOneWidget);
    expect(find.text('Recent Sessions'), findsOneWidget);
    expect(find.text('Animals'), findsWidgets);
    expect(find.text('Colours'), findsWidgets);
  });

  testWidgets('Test 6: Child Selection Screen renders student profiles',
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
  });
}
