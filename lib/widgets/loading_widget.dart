import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/localization/app_localizations.dart';

/// Gentle, predictable loading widget designed to avoid sensory agitation.
/// Features a calm color palette and comforting status message.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isCompact;

  const LoadingWidget({
    super.key,
    this.message,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayMessage = message ??
        (l10n.isArabic
            ? 'جار التحميل بهدوء... 🌟'
            : 'Loading gently... 🌟');

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            backgroundColor: AppColors.primaryLight,
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            displayMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (isCompact) {
      return Center(child: content);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: content,
      ),
    );
  }
}
