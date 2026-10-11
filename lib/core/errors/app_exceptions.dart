/// Base exception class for the application.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  /// Returns a calming, sensory-gentle message tailored for children with ASD.
  /// Never displays stack traces or technical errors to child learners.
  String toChildFriendlyMessage(bool isArabic) {
    if (isArabic) {
      return 'لا بأس، دعنا نحاول مرة أخرى بلطف 🌱';
    }
    return "It's okay, let's try again gently! 🌱";
  }

  /// Returns an informative message for parents and educators.
  String toParentMessage(bool isArabic) {
    if (isArabic) {
      return message;
    }
    return message;
  }

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Thrown when network communication or Firebase connectivity fails.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Unable to connect to service. Please check internet connection.',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });

  @override
  String toChildFriendlyMessage(bool isArabic) {
    if (isArabic) {
      return 'سحابة الإنترنت نائمة قليلاً، سنحاول معاً بعد لحظات ☁️';
    }
    return 'The connection is resting, let’s try again in a moment! ☁️';
  }
}

/// Thrown when authentication or permission verification fails.
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed. Please verify credentials.',
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Thrown when a requested resource (vocabulary, child profile, category) is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested learning item was not found.',
    super.code = 'NOT_FOUND',
    super.originalError,
  });

  @override
  String toChildFriendlyMessage(bool isArabic) {
    if (isArabic) {
      return 'لم نجد هذه البطاقة الآن، دعنا نكتشف بطاقة أخرى! 🌟';
    }
    return 'We could not find this card, let’s explore another one! 🌟';
  }
}

/// Thrown when audio playback or asset loading encounters an issue.
class AudioException extends AppException {
  const AudioException({
    super.message = 'Unable to play pronunciation audio.',
    super.code = 'AUDIO_ERROR',
    super.originalError,
  });

  @override
  String toChildFriendlyMessage(bool isArabic) {
    if (isArabic) {
      return 'الصوت هادئ الآن، يمكنك المحاولة بالضغط على زر السماعة 🎧';
    }
    return 'The sound is quiet now, you can tap the speaker to try again! 🎧';
  }
}
