import 'package:flutter/material.dart';

/// Represents a vocabulary learning category (e.g. Animals, Colours, Numbers, Letters).
class CategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;
  final String illustrationKey;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.illustrationKey,
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;
}
