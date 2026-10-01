import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Large touch-target icon button (minimum 48dp, default 56-72dp).
/// Used for audio playback, pagination, and back navigation.
class LargeIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final bool isCircle;
  final String? tooltip;
  final bool hasOuterGlow;

  const LargeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppDimensions.standardTouchTarget,
    this.iconSize = 28.0,
    this.backgroundColor = Colors.white,
    this.iconColor = AppColors.primaryBlue,
    this.borderColor = AppColors.borderLight,
    this.isCircle = true,
    this.tooltip,
    this.hasOuterGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(AppDimensions.radiusM),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2.0)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          if (hasOuterGlow)
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: isCircle
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
        child: tooltip != null
            ? Tooltip(message: tooltip!, child: buttonContent)
            : buttonContent,
      ),
    );
  }
}
