import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Cloud Firestore database operations.
/// Prevents Firestore queries from being directly embedded in UI widgets.
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore {
    final custom = _customFirestore;
    if (custom != null) return custom;
    if (!_isFirebaseAvailable) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Retrieves a single document by ID from a given collection.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument(
    String collection,
    String docId,
  ) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      return await firestore
          .collection(collection)
          .doc(docId)
          .get()
          .timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException('$collection/$docId', e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to retrieve document from $collection/$docId: $e',
        originalError: e,
      );
    }
  }

  /// Sets or overwrites a document in a collection.
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      await firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge))
          .timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException('$collection/$docId', e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to set document in $collection/$docId: $e',
        originalError: e,
      );
    }
  }

  /// Adds a new document with an auto-generated ID to a collection.
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      return await firestore
          .collection(collection)
          .add(data)
          .timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException(collection, e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to add document to $collection: $e',
        originalError: e,
      );
    }
  }

  /// Updates specific fields of an existing document.
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      await firestore
          .collection(collection)
          .doc(docId)
          .update(data)
          .timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException('$collection/$docId', e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to update document in $collection/$docId: $e',
        originalError: e,
      );
    }
  }

  /// Deletes a document by ID.
  Future<void> deleteDocument(String collection, String docId) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      await firestore
          .collection(collection)
          .doc(docId)
          .delete()
          .timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException('$collection/$docId', e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to delete document from $collection/$docId: $e',
        originalError: e,
      );
    }
  }

  /// Queries all documents in a collection with optional ordering and limit.
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection, {
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      Query<Map<String, dynamic>> query = firestore.collection(collection);
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get().timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException(collection, e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to query collection $collection: $e',
        originalError: e,
      );
    }
  }

  /// Queries documents in a collection with equality filters, range bounds, ordering, and limit.
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
    String collection, {
    Map<String, dynamic>? whereEquals,
    String? whereLessThanOrEqualToField,
    dynamic whereLessThanOrEqualToValue,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const NetworkException(
        message: 'Firestore unavailable: Firebase not initialized.',
      );
    }

    try {
      Query<Map<String, dynamic>> query = firestore.collection(collection);

      if (whereEquals != null) {
        whereEquals.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      if (whereLessThanOrEqualToField != null &&
          whereLessThanOrEqualToValue != null) {
        query = query.where(
          whereLessThanOrEqualToField,
          isLessThanOrEqualTo: whereLessThanOrEqualToValue,
        );
      }

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get().timeout(const Duration(seconds: 4));
    } on FirebaseException catch (e) {
      _handleFirebaseException(collection, e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to query collection $collection: $e',
        originalError: e,
      );
    }
  }

  /// Streams real-time updates for a collection.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    String? orderByField,
    bool descending = false,
  }) {
    final firestore = _firestore;
    if (firestore == null) {
      return const Stream.empty();
    }
    Query<Map<String, dynamic>> query = firestore.collection(collection);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    return query.snapshots();
  }

  Never _handleFirebaseException(String target, FirebaseException e) {
    if (e.code == 'permission-denied') {
      throw AppException(
        code: 'PERMISSION_DENIED',
        message: 'Permission denied accessing $target: ${e.message ?? e.code}',
        originalError: e,
      );
    } else if (e.code == 'unavailable') {
      throw NetworkException(
        message: 'Firestore service is currently unavailable. Please check your connection.',
        originalError: e,
      );
    } else if (e.code == 'not-found') {
      throw AppException(
        code: 'NOT_FOUND',
        message: 'Resource $target was not found in Firestore.',
        originalError: e,
      );
    }
    throw NetworkException(
      message: 'Firestore operation failed on $target (${e.code}): ${e.message}',
      originalError: e,
    );
  }
}
