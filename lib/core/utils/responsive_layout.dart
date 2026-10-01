import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Ensures predictable, centered, and visually calm layout on Web, Tablet, and Mobile.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
