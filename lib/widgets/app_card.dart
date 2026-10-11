import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Reusable card container tailored for ASD learners.
/// Features soft rounded corners, calm border contrast, and comfortable padding.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spaceL),
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.borderLight,
    this.borderWidth = 1.5,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimensions.cardBorderRadius;

    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: container,
        ),
      );
    }

    return container;
  }
}
