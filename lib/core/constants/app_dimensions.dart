import 'package:flutter/material.dart';

/// Predictable sizing, padding, and accessibility dimensions.
/// Enforces minimum 48dp touch targets and rounded, calming shapes.
class AppDimensions {
  // Spacing Scale
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Touch Targets (ASD Accessibility Guidelines: minimum 48dp, ideal 56-72dp)
  static const double minTouchTarget = 48.0;
  static const double standardTouchTarget = 56.0;
  static const double largeTouchTarget = 72.0;

  // Radii
  static const double radiusS = 12.0;
  static const double radiusM = 18.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusFull = 999.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(radiusL);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(radiusM);
  static final BorderRadius largeCardBorderRadius = BorderRadius.circular(radiusXL);

  // Web Layout Max Width
  static const double maxContentWidth = 720.0;
  static const double maxTabletWidth = 960.0;
}
