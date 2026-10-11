import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/errors/app_exceptions.dart';

/// Clean abstraction service over Firebase Cloud Storage for learning assets.
/// Provides safe URL resolution for vocabulary images and bilingual audio clips
/// without exposing Firebase Storage internals directly to UI widgets.
class StorageService {
  final FirebaseStorage? _customStorage;

  StorageService({FirebaseStorage? storage}) : _customStorage = storage;

  FirebaseStorage get _storage => _customStorage ?? FirebaseStorage.instance;

  /// Retrieves the public download URL for a storage path.
  /// If the path is already an HTTPS URL or local asset path, returns it directly.
  Future<String> getDownloadUrl(String path) async {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('assets/')) {
      return path;
    }

    try {
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final ref = _storage.ref(cleanPath);
      return await ref.getDownloadURL();
    } catch (e) {
      // In offline / test environment or missing storage, return original path safely
      return path;
    }
  }

  /// Resolves the storage URL for a vocabulary card image.
  /// Standard location: `vocabulary/images/<filename>`
  Future<String> getVocabularyImageUrl(String fileNameOrPath) async {
    if (fileNameOrPath.isEmpty) return '';
    if (fileNameOrPath.startsWith('http') || fileNameOrPath.startsWith('assets/')) {
      return fileNameOrPath;
    }
    final clean = fileNameOrPath.startsWith('/')
        ? fileNameOrPath.substring(1)
        : fileNameOrPath;
    final path = clean.startsWith('vocabulary/images/')
        ? clean
        : 'vocabulary/images/$clean';
    return getDownloadUrl(path);
  }

  /// Resolves the pronunciation audio URL for Arabic vocabulary.
  /// Standard location: `vocabulary/audio/ar/<filename>`
  Future<String> getArabicAudioUrl(String fileNameOrPath) async {
    if (fileNameOrPath.isEmpty) return '';
    if (fileNameOrPath.startsWith('http') || fileNameOrPath.startsWith('assets/')) {
      return fileNameOrPath;
    }
    final clean = fileNameOrPath.startsWith('/')
        ? fileNameOrPath.substring(1)
        : fileNameOrPath;
    final path = clean.startsWith('vocabulary/audio/ar/')
        ? clean
        : 'vocabulary/audio/ar/$clean';
    return getDownloadUrl(path);
  }

  /// Resolves the pronunciation audio URL for English vocabulary.
  /// Standard location: `vocabulary/audio/en/<filename>`
  Future<String> getEnglishAudioUrl(String fileNameOrPath) async {
    if (fileNameOrPath.isEmpty) return '';
    if (fileNameOrPath.startsWith('http') || fileNameOrPath.startsWith('assets/')) {
      return fileNameOrPath;
    }
    final clean = fileNameOrPath.startsWith('/')
        ? fileNameOrPath.substring(1)
        : fileNameOrPath;
    final path = clean.startsWith('vocabulary/audio/en/')
        ? clean
        : 'vocabulary/audio/en/$clean';
    return getDownloadUrl(path);
  }

  /// Uploads binary bytes (e.g. child drawing or audio clip) to Cloud Storage.
  Future<String> uploadBytes(
    String destinationPath,
    Uint8List data, {
    String? contentType,
  }) async {
    try {
      final cleanPath = destinationPath.startsWith('/')
          ? destinationPath.substring(1)
          : destinationPath;
      final ref = _storage.ref(cleanPath);
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
