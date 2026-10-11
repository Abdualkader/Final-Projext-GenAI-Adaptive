import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/category_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/category_card.dart';

/// Child Home Screen faithfully matching Wireframe 1:
/// Child greeting avatar, daily learning prompt with sun icon, 2x2 category grid, and floating navigation bar.
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLocale;

  const HomeScreen({
    super.key,
    required this.onToggleLocale,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

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
    final categories = (categoryProvider != null &&
            categoryProvider.categories.isNotEmpty)
        ? categoryProvider.categories
        : MockDataRepository.getCategories();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceS,
          ),
          child: Column(
            children: [
              // Top Header (Child Avatar + Greeting + Settings/Locale)
              AppHeader(
                childName: 'Adam',
                onSettingsTap: () {
                  Navigator.pushNamed(context, AppRoutes.parentSettings);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Language Switcher
                    IconButton(
                      onPressed: widget.onToggleLocale,
                      icon: const Icon(Icons.language_rounded, color: AppColors.primaryBlue),
                      tooltip: l10n.text('language'),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.parentLogin);
                      },
                      icon: const Icon(Icons.settings_rounded, color: AppColors.primaryBlue),
                      tooltip: l10n.text('parent_portal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Daily Learning Prompt with Sunshine Graphic
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.text('home_prompt'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.starBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.wb_sunny_rounded,
                          size: 34,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // 2x2 Category Cards Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
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
            ],
          ),
        ),
      ),
      // Floating Bottom Navigation Bar matching Wireframe 1
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceS,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: l10n.text('nav_home'),
              onTap: () => setState(() => _currentNavIndex = 0),
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.sports_esports_rounded,
              label: l10n.text('nav_games'),
              onTap: () {
                setState(() => _currentNavIndex = 1);
                Navigator.pushNamed(context, AppRoutes.childQuiz);
              },
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.emoji_events_rounded,
              label: l10n.text('nav_progress'),
              onTap: () {
                setState(() => _currentNavIndex = 2);
                Navigator.pushNamed(context, AppRoutes.parentDashboard);
              },
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: l10n.text('nav_profile'),
              onTap: () {
                setState(() => _currentNavIndex = 3);
                Navigator.pushNamed(context, AppRoutes.parentChildSelection);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentNavIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
