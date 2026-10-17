import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/category_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/loading_widget.dart';

/// Category Selection Screen allowing child or educator to browse available domains.
/// Conforms to Week 8 Task 2: Categories retrieved dynamically from Cloud Firestore.
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider?>(context, listen: false);
      if (categoryProvider != null && categoryProvider.categories.isEmpty) {
        categoryProvider.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryProvider =
        Provider.of<CategoryProvider?>(context, listen: true);

    final bool hasProvider = categoryProvider != null;
    final categories = (hasProvider && categoryProvider.categories.isNotEmpty)
        ? categoryProvider.categories
        : MockDataRepository.getCategories();

    // Handle loading states when provider is available
    Widget bodyContent;
    if (hasProvider && categoryProvider.uiState.isLoading) {
      bodyContent = const LoadingWidget();
    } else if (hasProvider && categoryProvider.uiState.isError) {
      bodyContent = AppErrorWidget(
        message: categoryProvider.uiState.getDisplayError(l10n.isArabic, isChildMode: true),
        onRetry: () => categoryProvider.loadCategories(),
        isChildMode: true,
      );
    } else if (hasProvider && categoryProvider.uiState.isEmpty && categories.isEmpty) {
      bodyContent = EmptyStateWidget(
        title: l10n.isArabic ? 'لا توجد أقسام تعليمية' : 'No categories available',
        subtitle: l10n.isArabic
            ? 'يرجى التحقق من اتصال الإنترنت'
            : 'Please check your internet connection',
        icon: Icons.category_rounded,
        actionLabel: l10n.isArabic ? 'إعادة المحاولة' : 'Retry',
        onAction: () => categoryProvider.loadCategories(),
      );
    } else {
      bodyContent = GridView.builder(
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
      );
    }

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
          child: bodyContent,
        ),
      ),
    );
  }
}
