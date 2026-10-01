import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../widgets/large_icon_button.dart';

/// Child Selection Screen for multi-child or classroom environments.
class ChildSelectionScreen extends StatelessWidget {
  const ChildSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final children = [
      {
        'name': 'Adam',
        'age': 5,
        'interest': l10n.text('child_interest'),
        'color': AppColors.primaryBlue,
        'icon': Icons.pets_rounded,
      },
      {
        'name': 'Sara',
        'age': 6,
        'interest': l10n.isArabic ? 'تحب الألوان!' : 'Loves Colours!',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.palette_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceS),
          child: LargeIconButton(
            icon: Icons.arrow_back_rounded,
            size: 44,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(l10n.text('child_selection_title')),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceL),
            itemCount: children.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spaceM),
            itemBuilder: (context, index) {
              final child = children[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.parentDashboard);
                  },
                  borderRadius: AppDimensions.cardBorderRadius,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppDimensions.cardBorderRadius,
                      border: Border.all(color: AppColors.borderLight, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (child['color'] as Color).withOpacity(0.12),
                            border: Border.all(
                              color: child['color'] as Color,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.face_rounded,
                            size: 38,
                            color: child['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child['name'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${l10n.text('child_age').replaceAll('{0}', (child['age'] as int).toString())} • ${child['interest']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
