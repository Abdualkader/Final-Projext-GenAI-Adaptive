import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../repositories/mock_data_repository.dart';
import '../../services/audio_service.dart';
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

    final authProvider = Provider.of<AuthProvider?>(context, listen: true);
    final activeChildName = authProvider?.selectedChild?.name;

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
                childName: activeChildName,
                onAvatarTap: () {
                  Navigator.pushNamed(context, AppRoutes.parentChildSelection);
                },
                onSettingsTap: () {
                  Navigator.pushNamed(context, AppRoutes.parentLogin);
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
                    // Admin / Parent Portal Button
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.parentLogin);
                      },
                      icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryBlue),
                      tooltip: l10n.text('parent_portal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Daily Learning Prompt with Sunshine Graphic & Audio Prompt
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
                    IconButton(
                      onPressed: () {
                        AudioService().speakText(
                          l10n.text('home_prompt'),
                          language: l10n.isArabic ? 'ar' : 'en',
                        );
                      },
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primaryBlue,
                        size: 30,
                      ),
                      tooltip: l10n.text('btn_listen'),
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
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
              // 2x2 Category Cards Grid with auditory pronunciation
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
                        AudioService().speakText(
                          category.localizedName(l10n.isArabic),
                          language: l10n.isArabic ? 'ar' : 'en',
                        );
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
                _showGameCategoryChooser(context, l10n);
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

  void _showGameCategoryChooser(BuildContext context, AppLocalizations l10n) {
    int selectedGameMode = 0; // 0: AI Quiz, 1: AI Match Game

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isArabic = l10n.isArabic;

            void launchGame(String catId) {
              Navigator.pop(ctx);
              if (selectedGameMode == 0) {
                Navigator.pushNamed(context, AppRoutes.childQuiz, arguments: {
                  'categoryId': catId,
                  'full': true,
                  'useAi': true,
                });
              } else if (selectedGameMode == 1) {
                Navigator.pushNamed(context, AppRoutes.childMatchingGame, arguments: {
                  'categoryId': catId,
                });
              } else {
                Navigator.pushNamed(context, AppRoutes.childBubbleGame, arguments: {
                  'categoryId': catId,
                });
              }
            }

            return Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic ? 'ألعاب التعلم الذكية 🎮' : 'AI Educational Games! 🎮',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceM),

                  // Mode Toggle: AI Quiz vs Matching Game vs Bubble Pop
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedGameMode = 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedGameMode == 0 ? AppColors.primaryBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quiz_rounded,
                                    size: 16,
                                    color: selectedGameMode == 0 ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? 'اختبار 🎯' : 'Quiz 🎯',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: selectedGameMode == 0 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedGameMode = 1;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedGameMode == 1 ? const Color(0xFF10B981) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.extension_rounded,
                                    size: 16,
                                    color: selectedGameMode == 1 ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? 'مطابقة 🧩' : 'Match 🧩',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: selectedGameMode == 1 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedGameMode = 2;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedGameMode == 2 ? const Color(0xFF8B5CF6) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bubble_chart_rounded,
                                    size: 16,
                                    color: selectedGameMode == 2 ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? 'فقاعات 🫧' : 'Bubbles 🫧',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: selectedGameMode == 2 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  Text(
                    isArabic ? 'اختر الفئة للبدء:' : 'Choose a category to start:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),

                  // Comprehensive Adventure option (all skills mixed)
                  _buildGameOption(
                    title: isArabic
                        ? '🌟 مغامرة شاملة (اختبار كافة المهارات معا)'
                        : '🌟 Comprehensive Adventure (All Skills)',
                    icon: Icons.auto_awesome_rounded,
                    color: const Color(0xFFE11D48),
                    onTap: () => launchGame('all'),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),

                  // Categories Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildGameOption(
                          title: l10n.text('category_animals'),
                          icon: Icons.pets_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () => launchGame('animals'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: _buildGameOption(
                          title: l10n.text('category_colours'),
                          icon: Icons.palette_rounded,
                          color: const Color(0xFF3B82F6),
                          onTap: () => launchGame('colours'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGameOption(
                          title: l10n.text('category_numbers'),
                          icon: Icons.looks_one_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () => launchGame('numbers'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: _buildGameOption(
                          title: l10n.text('category_letters'),
                          icon: Icons.text_fields_rounded,
                          color: const Color(0xFF8E24AA),
                          onTap: () => launchGame('letters'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceL),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGameOption({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceL,
            horizontal: AppDimensions.spaceM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
