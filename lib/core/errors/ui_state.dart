import 'app_exceptions.dart';

/// Represents common UI state lifecycles across screens and providers.
enum UiStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Generic container representing the presentation state of asynchronous operations.
class UiState<T> {
  final UiStatus status;
  final T? data;
  final AppException? error;
  final String? customErrorMessage;

  const UiState({
    required this.status,
    this.data,
    this.error,
    this.customErrorMessage,
  });

  const UiState.initial()
      : status = UiStatus.initial,
        data = null,
        error = null,
        customErrorMessage = null;

  const UiState.loading()
      : status = UiStatus.loading,
        data = null,
        error = null,
        customErrorMessage = null;

  const UiState.success(this.data)
      : status = UiStatus.success,
        error = null,
        customErrorMessage = null;

  const UiState.empty()
      : status = UiStatus.empty,
        data = null,
        error = null,
        customErrorMessage = null;

  const UiState.error(this.error)
      : status = UiStatus.error,
        data = null,
        customErrorMessage = null;


  const UiState.errorMessage(String message)
      : status = UiStatus.error,
        data = null,
        error = null,
        customErrorMessage = message;

  bool get isInitial => status == UiStatus.initial;
  bool get isLoading => status == UiStatus.loading;
  bool get isSuccess => status == UiStatus.success;
  bool get isEmpty => status == UiStatus.empty;
  bool get isError => status == UiStatus.error;

  String getDisplayError(bool isArabic, {bool isChildMode = false}) {
    if (isChildMode) {
      return error?.toChildFriendlyMessage(isArabic) ??
          (isArabic
              ? 'دعنا نحاول مرة أخرى بلطف 🌱'
              : "Let's try again gently! 🌱");
    }
    return customErrorMessage ??
        error?.toParentMessage(isArabic) ??
        (isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred');
  }
}
