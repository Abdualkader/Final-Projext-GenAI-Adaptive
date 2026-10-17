import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/content_validator.dart';
import '../core/utils/ui_helpers.dart';

/// Represents a vocabulary learning category (e.g. Animals, Colours, Numbers, Letters).
/// Compatible with Firestore schema in PROJECT_REFERENCE.md (Collection: 'categories').
class CategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;
  final String illustrationKey;
  final String iconUrl;
  final int orderIndex;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.backgroundColor = AppColors.cardAnimals,
    this.textColor = AppColors.textAnimals,
    this.borderColor = AppColors.borderAnimals,
    this.icon = Icons.category_rounded,
    this.illustrationKey = '',
    this.iconUrl = '',
    this.orderIndex = 0,
  });

  /// CategoryId alias for Firestore database schema alignment.
  String get categoryId => id;

  /// Content validation status conforming to Week 8 specifications.
  bool get isValid => ContentValidator.isValidCategory(this);

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;

  Map<String, dynamic> toMap() {
    return {
      'categoryId': id,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'iconUrl': iconUrl,
      'orderIndex': orderIndex,
      'illustrationKey': illustrationKey,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final catId = id ?? map['categoryId'] as String? ?? map['id'] as String? ?? '';
    final normalized = (catId == 'colors' || catId == 'colours') ? 'colours' : catId;
    final defaultKey = normalized == 'colours'
        ? 'rainbow'
        : normalized == 'numbers'
            ? 'numbers_123'
            : normalized == 'letters'
                ? 'letters_abc'
                : 'dog';

    return CategoryModel(
      id: catId,
      nameEn: map['nameEn'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
      illustrationKey: (map['illustrationKey'] as String?)?.isNotEmpty == true
          ? map['illustrationKey'] as String
          : defaultKey,
      backgroundColor: UiHelpers.getCategoryBackgroundColor(catId),
      textColor: UiHelpers.getCategoryTextColor(catId),
      borderColor: UiHelpers.getCategoryBorderColor(catId),
      icon: UiHelpers.getCategoryIcon(catId),
    );
  }
}
