import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/localization/app_localizations.dart';

/// Top header matching Wireframe 1: child avatar, personalized greeting, and settings button.
class AppHeader extends StatelessWidget {
  final String childName;
  final VoidCallback onSettingsTap;
  final VoidCallback? onAvatarTap;
  final Widget? trailing;

  const AppHeader({
    super.key,
    this.childName = 'Adam',
    required this.onSettingsTap,
    this.onAvatarTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Child Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.face_rounded,
                  size: 34,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          // Greeting Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.text('greeting_child'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.text('greeting_subtitle'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Trailing widget or Settings Button
          trailing ??
              IconButton(
                onPressed: onSettingsTap,
                iconSize: 26,
                padding: const EdgeInsets.all(AppDimensions.spaceS),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
                icon: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.primaryBlue,
                ),
                tooltip: l10n.text('settings_title'),
              ),
        ],
      ),
    );
  }
}
