import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/category_card.dart';
import '../../widgets/large_icon_button.dart';

/// Category Selection Screen allowing child or educator to browse available domains.
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = MockDataRepository.getCategories();

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
        title: Text(l10n.text('category_selection_title')),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spaceM,
              mainAxisSpacing: AppDimensions.spaceM,
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                isArabic: l10n.isArabic,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.childLearning,
                    arguments: category.id,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
