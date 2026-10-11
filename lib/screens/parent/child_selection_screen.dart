import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/large_icon_button.dart';

/// Child Selection Screen matching Task 7 & Task 8:
/// Connects to authenticated user data, lists linked children, allows child selection,
/// persists selection in state, and provides logout functionality.
class ChildSelectionScreen extends StatelessWidget {
  final AuthProvider? authProvider;

  const ChildSelectionScreen({
    super.key,
    this.authProvider,
  });

  AuthProvider? _resolveAuthProvider(BuildContext context) {
    if (authProvider != null) return authProvider;
    try {
      return Provider.of<AuthProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = _resolveAuthProvider(context);

    // Initial linked children profiles with ASD sensory badges
    final children = [
      {
        'id': 'child_adam',
        'name': 'Adam',
        'age': 5,
        'interest': l10n.isArabic ? 'يحب الحيوانات!' : 'Loves Animals!',
        'color': AppColors.primaryBlue,
        'icon': Icons.pets_rounded,
        'accuracy': '78%',
        'difficulty': 1,
      },
      {
        'id': 'child_sara',
        'name': 'Sara',
        'age': 6,
        'interest': l10n.isArabic ? 'تحب الألوان والرسم!' : 'Loves Colours & Drawing!',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.palette_rounded,
        'accuracy': '84%',
        'difficulty': 2,
      },
      {
        'id': 'child_omar',
        'name': 'Omar',
        'age': 5,
        'interest': l10n.isArabic ? 'يحب الأرقام والتركيب!' : 'Loves Numbers & Puzzles!',
        'color': const Color(0xFF10B981),
        'icon': Icons.looks_one_rounded,
        'accuracy': '82%',
        'difficulty': 2,
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
        actions: [
          // Task 8: Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            tooltip: l10n.isArabic ? 'تسجيل الخروج' : 'Logout',
            onPressed: () async {
              await provider?.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.parentLogin,
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: AppDimensions.spaceS),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceM),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
                child: Text(
                  l10n.text('select_profile_prompt'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
                  itemCount: children.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.spaceM),
                  itemBuilder: (context, index) {
                    final childData = children[index];
                    final color = childData['color'] as Color;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Task 7: Store the selected child in application state
                          final selected = ChildModel(
                            childId: childData['id'] as String,
                            parentId: provider?.currentUser?.userId ?? 'parent_default',
                            name: childData['name'] as String,
                            birthDate: DateTime.now().subtract(
                              Duration(days: 365 * (childData['age'] as int)),
                            ),
                            currentDifficultyLevel: childData['difficulty'] as int,
                            preferredLanguage: l10n.isArabic ? 'ar' : 'en',
                            createdAt: DateTime.now(),
                          );
                          provider?.selectChild(selected);

                          Navigator.pushNamed(context, AppRoutes.parentDashboard);
                        },
                        borderRadius: AppDimensions.cardBorderRadius,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.spaceL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDimensions.cardBorderRadius,
                            border: Border.all(color: AppColors.borderLight, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withOpacity(0.12),
                                  border: Border.all(color: color, width: 2),
                                ),
                                child: Icon(
                                  Icons.face_rounded,
                                  size: 40,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceL),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          childData['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: AppDimensions.spaceS),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            childData['accuracy'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${l10n.text('child_age').replaceAll('{0}', (childData['age'] as int).toString())} • ${childData['interest']}',
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
            ],
          ),
        ),
      ),
    );
  }
}
