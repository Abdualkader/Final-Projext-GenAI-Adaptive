import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Cloud Firestore database operations.
/// Prevents Firestore queries from being directly embedded in UI widgets.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Retrieves a single document by ID from a given collection.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
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
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
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
    try {
      return await _firestore.collection(collection).add(data);
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
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to update document in $collection/$docId: $e',
        originalError: e,
      );
    }
  }

  /// Deletes a document by ID.
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
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
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get();
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
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    return query.snapshots();
  }
}
