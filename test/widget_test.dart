import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asd_learning_assistant/main.dart';

void main() {
  testWidgets('App renders Backend Verification Dashboard on Web', (WidgetTester tester) async {
    // Set web viewport size
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build app widget
    await tester.pumpWidget(const ASDLearningApp());
    await tester.pump();

    // Verify main app title and architecture header
    expect(find.text('GenAI Adaptive Learning Assistant'), findsOneWidget);
    expect(find.text('Backend Services Status'), findsOneWidget);

    // Verify first service card
    expect(find.text('Firebase Authentication'), findsOneWidget);

    // Verify scrolled items are accessible
    final storageFinder = find.text('Firebase Cloud Storage');
    await tester.scrollUntilVisible(storageFinder, 150);
    expect(storageFinder, findsOneWidget);

    final functionsFinder = find.text('Cloud Functions & GenAI Proxy');
    await tester.scrollUntilVisible(functionsFinder, 150);
    expect(functionsFinder, findsOneWidget);
  });
}
