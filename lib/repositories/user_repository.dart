import '../core/constants/firebase_collections.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Repository interface for user profiles and linked child profiles.
abstract class UserRepository {
  Future<UserModel?> getUserById(String userId);
  Future<void> saveUser(UserModel user);
  Future<List<ChildModel>> getLinkedChildren(String parentId);
  Future<void> addChildProfile(String parentId, ChildModel child);
}

/// Base implementation of [UserRepository] communicating through [FirestoreService].
class BaseUserRepository implements UserRepository {
  final FirestoreService _firestoreService;

  BaseUserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestoreService.getDocument(
        FirebaseCollections.users,
        userId,
      );
      if (doc != null && doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, id: doc.id);
      }
      return null;
    } catch (_) {
      // Return placeholder user for offline / mock testing
      return UserModel(
        userId: userId,
        email: 'educator@example.com',
        displayName: 'Adam Parent',
        role: 'parent',
        preferredLanguage: 'en',
        linkedChildIds: const ['child_adam'],
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _firestoreService.setDocument(
      FirebaseCollections.users,
      user.userId,
      user.toMap(),
    );
  }

  @override
  Future<List<ChildModel>> getLinkedChildren(String parentId) async {
    try {
      final snapshot = await _firestoreService.getCollection(
        FirebaseCollections.children,
      );
      final list = snapshot.docs
          .where((doc) => doc.data()['parentId'] == parentId)
          .map((doc) => ChildModel.fromMap(doc.data(), id: doc.id))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback sample child profile
    }

    return [
      ChildModel(
        childId: 'child_adam',
        parentId: parentId,
        name: 'Adam',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        currentDifficultyLevel: 1,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> addChildProfile(String parentId, ChildModel child) async {
    await _firestoreService.setDocument(
      FirebaseCollections.children,
      child.childId,
      child.toMap(),
    );
  }
}
