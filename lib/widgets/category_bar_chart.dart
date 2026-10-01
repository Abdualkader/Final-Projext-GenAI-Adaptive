import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/progress_model.dart';

/// Clean, high-legibility Bar Chart widget matching Wireframe 3.
/// Visualizes category mastery percentages without excessive animations or noise.
class CategoryBarChart extends StatelessWidget {
  final List<CategoryAccuracy> items;
  final bool isArabic;

  const CategoryBarChart({
    super.key,
    required this.items,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Title and dropdown pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    isArabic
                        ? 'دقة الاختبارات حسب القسم'
                        : 'Quiz Accuracy by Category',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.textMuted.withOpacity(0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceM,
                  vertical: AppDimensions.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? 'مخطط بياني' : 'Bar Chart',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          // Chart Graphic Area
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-Axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('75%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('50%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('25%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('0%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(width: AppDimensions.spaceM),
                // Bars Area
                Expanded(
                  child: Stack(
                    children: [
                      // Gridlines
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) => Container(
                              height: 1,
                              color: AppColors.borderLight.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      // Bars Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: items.map((item) {
                          final double barHeightFactor = item.accuracy / 100.0;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Percentage readout
                              Text(
                                '${item.accuracy}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: item.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Bar Container
                              Container(
                                width: 44,
                                height: 140 * barHeightFactor,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          // Category Badges & Labels row
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.map((item) {
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: item.color, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(item.icon, size: 20, color: item.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.localizedCategory(isArabic),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
