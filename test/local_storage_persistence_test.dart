import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asd_learning_assistant/models/child_model.dart';
import 'package:asd_learning_assistant/models/learning_session_model.dart';
import 'package:asd_learning_assistant/models/quiz_result_model.dart';
import 'package:asd_learning_assistant/models/user_model.dart';
import 'package:asd_learning_assistant/providers/auth_provider.dart';
import 'package:asd_learning_assistant/repositories/progress_repository.dart';
import 'package:asd_learning_assistant/repositories/quiz_repository.dart';
import 'package:asd_learning_assistant/repositories/session_repository.dart';
import 'package:asd_learning_assistant/repositories/user_repository.dart';
import 'package:asd_learning_assistant/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService Child Persistence Tests', () {
    test('Persists and retrieves new child profile correctly', () async {
      final child = ChildModel(
        childId: 'child_noura_123',
        parentId: 'parent_456',
        name: 'Noura',
        currentDifficultyLevel: 2,
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
        preferredLanguage: 'ar',
        createdAt: DateTime.now(),
      );

      await LocalStorageService.saveChild(child);

      final retrieved = await LocalStorageService.getChildById('child_noura_123');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Noura');
      expect(retrieved.parentId, 'parent_456');
      expect(retrieved.currentDifficultyLevel, 2);

      final parentChildren = await LocalStorageService.getChildrenForParent('parent_456');
      expect(parentChildren.length, 1);
      expect(parentChildren.first.name, 'Noura');
    });

    test('Persists user credentials and retrieves user by email', () async {
      final user = UserModel(
        userId: 'user_father_1',
        email: 'father@gmail.com',
        displayName: 'Father',
        role: 'parent',
        linkedChildIds: ['child_noura_123'],
        preferredLanguage: 'ar',
        difficultyLevel: 1,
        createdAt: DateTime.now(),
      );

      await LocalStorageService.saveUser(user);
      await LocalStorageService.saveCredentials('father@gmail.com', 'mypassword');

      final foundUser = await LocalStorageService.getUserByEmail('father@gmail.com');
      expect(foundUser, isNotNull);
      expect(foundUser!.userId, 'user_father_1');

      final creds = await LocalStorageService.getCredentials();
      expect(creds['father@gmail.com'], 'mypassword');
    });

    test('Persists active child ID and retrieves it', () async {
      await LocalStorageService.saveActiveChildId('child_noura_123');
      final activeId = await LocalStorageService.getActiveChildId();
      expect(activeId, 'child_noura_123');
    });

    test('Persists quiz result and learning session for new child', () async {
      final session = LearningSessionModel(
        sessionId: 'session_noura_01',
        childId: 'child_noura_123',
        categoryId: 'letters',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 5)),
        score: 0.90,
        itemsPresented: ['alif', 'baa'],
      );

      final quizResult = QuizResultModel(
        resultId: 'quiz_noura_01',
        childId: 'child_noura_123',
        sessionId: 'session_noura_01',
        questionId: 'alif',
        childResponse: 'alif',
        isCorrect: true,
        responseTimeMs: 1500,
        timestamp: DateTime.now(),
      );

      final sessionRepo = BaseSessionRepository();
      final quizRepo = BaseQuizRepository();

      await sessionRepo.createSession(session);
      await quizRepo.recordQuizResult(quizResult);

      final retrievedSessions = await sessionRepo.getRecentSessions('child_noura_123');
      expect(retrievedSessions.any((s) => s.sessionId == 'session_noura_01'), isTrue);

      final retrievedQuizResults = await quizRepo.getQuizResultsForChild('child_noura_123');
      expect(retrievedQuizResults.any((q) => q.resultId == 'quiz_noura_01'), isTrue);
    });

    test('ProgressRepository computes accuracy and mastery for newly created child', () async {
      final progressRepo = BaseProgressRepository();
      final progress = await progressRepo.getProgressForChild('child_noura_123');

      expect(progress.studentName, 'Noura');
      expect(progress.totalSessions, greaterThanOrEqualTo(1));
      expect(progress.overallAccuracy, greaterThan(0));
    });

    test('AuthProvider restores user and child across simulated app restart', () async {
      // 1. Initial login and add child
      final authProvider1 = AuthProvider();
      await authProvider1.signIn('father@gmail.com', 'mypassword');
      expect(authProvider1.isAuthenticated, isTrue);

      final newChild = await authProvider1.addChildProfile(
        name: 'Tariq',
        age: 7,
        initialDifficulty: 1,
        preferredLanguage: 'ar',
      );
      expect(newChild.name, 'Tariq');
      expect(authProvider1.selectedChild?.name, 'Tariq');

      // 2. Simulate closing app by creating a new AuthProvider instance
      final authProvider2 = AuthProvider();

      // Sign in with same email
      final loggedIn = await authProvider2.signIn('father@gmail.com', 'mypassword');
      expect(loggedIn, isTrue);

      // Child 'Tariq' must NOT be deleted!
      expect(authProvider2.linkedChildren.any((c) => c.name == 'Tariq'), isTrue);
    });
  });
}
