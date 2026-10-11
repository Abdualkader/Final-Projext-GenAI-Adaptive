import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/localization/app_localizations.dart';
import 'app_button.dart';

/// Reusable error widget providing gentle, comforting presentation for child learners
/// and clear actionable messaging for parents/educators.
class AppErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isChildMode;

  const AppErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.isChildMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isChildMode) {
      // Gentle child sensory safeguard
      final childMessage = message ??
          (l10n.isArabic
              ? 'لا بأس يا بطل، دعنا نحاول مرة أخرى معاً 🌱'
              : "It's okay, let's try again together! 🌱");

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spaceXL),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppDimensions.cardBorderRadius,
              border: Border.all(
                color: AppColors.borderLetters,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 52,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: AppDimensions.spaceM),
                Text(
                  childMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppDimensions.spaceL),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
                    child: AppButton(
                      label: l10n.isArabic ? 'المحاولة مجدداً' : 'Try Again',
                      icon: Icons.refresh_rounded,
                      backgroundColor: AppColors.primaryBlue,
                      onPressed: onRetry!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Parent & educator error view
    final parentMessage = message ??
        (l10n.isArabic
            ? 'حدث خطأ أثناء تحميل البيانات.'
            : 'An error occurred while loading data.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 48,
              color: AppColors.alertSoft,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              parentMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spaceL),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
                child: AppButton(
                  label: l10n.isArabic ? 'إعادة المحاولة' : 'Retry',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

