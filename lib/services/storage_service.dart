import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Firebase Cloud Storage for learning assets.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Retrieves the public download URL for a storage path.
  /// If the path is already an HTTPS URL or local asset path, returns it directly.
  Future<String> getDownloadUrl(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('assets/')) {
      return path;
    }

    try {
      final ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw NetworkException(
        message: 'Failed to retrieve media asset from storage path $path: $e',
        originalError: e,
      );
    }
  }

  /// Uploads binary bytes (e.g. child drawing or audio clip) to Cloud Storage.
  Future<String> uploadBytes(
    String destinationPath,
    Uint8List data, {
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref(destinationPath);
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(data, metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw NetworkException(
        message: 'Failed to upload asset to $destinationPath: $e',
        originalError: e,
      );
    }
  }
}
