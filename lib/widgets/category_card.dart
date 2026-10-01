import 'package:flutter/material.dart';
import '../core/constants/app_dimensions.dart';
import '../models/category_model.dart';

/// Large category card matching Wireframe 1: calm pastel background,
/// friendly illustration, and bold rounded typography.
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isArabic;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.cardBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: category.backgroundColor,
            borderRadius: AppDimensions.cardBorderRadius,
            border: Border.all(
              color: category.borderColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: category.textColor.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration / Icon Badge
              Expanded(
                child: Center(
                  child: _buildIllustration(category.illustrationKey),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              // Category Title
              Text(
                category.localizedName(isArabic),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: category.textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(String key) {
    switch (key) {
      case 'dog':
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: category.borderColor, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.pets_rounded,
              size: 54,
              color: Color(0xFF43A047),
            ),
          ),
        );
      case 'rainbow':
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: category.borderColor, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.palette_rounded,
              size: 54,
              color: Color(0xFFFB8C00),
            ),
          ),
        );
      case 'numbers_123':
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: category.borderColor, width: 2),
          ),
          child: const Center(
            child: Text(
              '123',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0288D1),
              ),
            ),
          ),
        );
      case 'letters_abc':
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: category.borderColor, width: 2),
          ),
          child: const Center(
            child: Text(
              'ABC',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8E24AA),
              ),
            ),
          ),
        );
      default:
        return Icon(
          category.icon,
          size: 60,
          color: category.textColor,
        );
    }
  }
}
