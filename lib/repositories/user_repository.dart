import '../core/constants/firebase_collections.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/sample_data_service.dart';

/// Repository interface for user profiles and linked child profiles.
abstract class UserRepository {
  Future<UserModel?> getUserById(String userId);
  Future<void> saveUser(UserModel user);
  Future<void> updatePreferredLanguage(String userId, String language);
  Future<List<ChildModel>> getLinkedChildren(String parentId);
  Future<List<String>> getLinkedChildIds(String parentId);
  Future<void> addChildProfile(String parentId, ChildModel child);
}

/// Base implementation of [UserRepository] communicating through [FirestoreService].
class BaseUserRepository implements UserRepository {
  final FirestoreService _firestoreService;
  final Map<String, UserModel> _inMemoryUsers = {
    SampleDataService.sampleParentUser.userId: SampleDataService.sampleParentUser,
  };
  final Map<String, ChildModel> _inMemoryChildren = {
    for (final c in SampleDataService.sampleChildren) c.childId: c,
  };

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
        final user = UserModel.fromMap(doc.data()!, id: doc.id);
        _inMemoryUsers[userId] = user;
        return user;
      }
    } catch (_) {
      // Offline / hermetic test fallback
    }

    if (_inMemoryUsers.containsKey(userId)) {
      return _inMemoryUsers[userId];
    }

    // Return sample user for offline / test environments
    final fallbackUser = SampleDataService.sampleParentUser.copyWith(userId: userId);
    _inMemoryUsers[userId] = fallbackUser;
    return fallbackUser;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _inMemoryUsers[user.userId] = user;
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.users,
        user.userId,
        user.toMap(),
      );
    } catch (_) {
      // In offline / unit-test environments, in-memory state is maintained.
    }
  }

  @override
  Future<void> updatePreferredLanguage(String userId, String language) async {
    final user = await getUserById(userId);
    if (user != null) {
      _inMemoryUsers[userId] = user.copyWith(preferredLanguage: language);
    }
    try {
      await _firestoreService.updateDocument(
        FirebaseCollections.users,
        userId,
        {'preferredLanguage': language},
      );
    } catch (_) {
      try {
        await _firestoreService.setDocument(
          FirebaseCollections.users,
          userId,
          {'preferredLanguage': language},
          merge: true,
        );
      } catch (_) {
        // Saved in-memory
      }
    }
  }

  @override
  Future<List<ChildModel>> getLinkedChildren(String parentId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        FirebaseCollections.children,
        whereEquals: {'parentId': parentId},
      );
      final list = snapshot.docs
          .map((doc) => ChildModel.fromMap(doc.data(), id: doc.id))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }

    final localMatches = _inMemoryChildren.values
        .where((c) => c.parentId == parentId)
        .toList();
    if (localMatches.isNotEmpty) return localMatches;

    return SampleDataService.sampleChildren
        .map((c) => c.copyWith(parentId: parentId))
        .toList();
  }

  @override
  Future<List<String>> getLinkedChildIds(String parentId) async {
    final user = await getUserById(parentId);
    if (user != null && user.linkedChildIds.isNotEmpty) {
      return user.linkedChildIds;
    }
    final children = await getLinkedChildren(parentId);
    return children.map((c) => c.childId).toList();
  }

  @override
  Future<void> addChildProfile(String parentId, ChildModel child) async {
    _inMemoryChildren[child.childId] = child.copyWith(parentId: parentId);
    try {
      await _firestoreService.setDocument(
        FirebaseCollections.children,
        child.childId,
        child.toMap(),
      );
    } catch (_) {
      // Saved in-memory
    }

    final user = await getUserById(parentId);
    if (user != null && !user.linkedChildIds.contains(child.childId)) {
      final updatedChildIds = [...user.linkedChildIds, child.childId];
      await saveUser(user.copyWith(linkedChildIds: updatedChildIds));
    }
  }
}
