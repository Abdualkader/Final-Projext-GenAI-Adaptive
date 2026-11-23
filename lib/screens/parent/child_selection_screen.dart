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
  final VoidCallback? onToggleLocale;

  const ChildSelectionScreen({
    super.key,
    this.authProvider,
    this.onToggleLocale,
  });

  AuthProvider? _resolveAuthProvider(BuildContext context, {bool listen = false}) {
    if (authProvider != null) return authProvider;
    try {
      return Provider.of<AuthProvider>(context, listen: listen);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = _resolveAuthProvider(context, listen: true);

    // Initial linked children profiles with ASD sensory badges
    final children = <Map<String, dynamic>>[
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

    // Merge any dynamically created child profiles
    final defaultIds = {'child_adam', 'child_sara', 'child_omar'};
    final customChildren = (provider?.linkedChildren ?? [])
        .where((c) => !defaultIds.contains(c.childId))
        .toList();

    for (final c in customChildren) {
      children.add({
        'id': c.childId,
        'name': c.name,
        'age': c.birthDate != null
            ? (DateTime.now().difference(c.birthDate!).inDays / 365).round().clamp(3, 12)
            : 5,
        'interest': l10n.isArabic ? 'حساب متعلّم 🌱' : 'Learner Account 🌱',
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.face_rounded,
        'accuracy': '85%',
        'difficulty': c.currentDifficultyLevel,
      });
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
        title: Text(l10n.text('child_selection_title')),
        actions: [
          // Language toggle button
          if (onToggleLocale != null)
            IconButton(
              icon: const Icon(Icons.language_rounded, color: AppColors.primaryBlue),
              tooltip: l10n.isArabic ? 'English' : 'العربية',
              onPressed: onToggleLocale,
            ),
          // Add Child Profile Button
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primaryBlue),
            tooltip: l10n.isArabic ? 'إضافة طفل جديد' : 'Add Child Profile',
            onPressed: () => _showAddChildDialog(context, provider, l10n),
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
                      child: Text(
                        l10n.text('select_profile_prompt'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddChildDialog(context, provider, l10n),
                    icon: const Icon(Icons.add_circle_rounded, size: 20),
                    label: Text(l10n.isArabic ? '+ طفل جديد' : '+ New Child'),
                  ),
                ],
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
                          final childId = childData['id'] as String;
                          final existing = provider?.linkedChildren
                              .where((c) => c.childId == childId)
                              .firstOrNull;
                          final selected = existing ?? ChildModel(
                            childId: childId,
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
              const SizedBox(height: AppDimensions.spaceS),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (provider?.selectedChild == null && children.isNotEmpty) {
                      final first = children.first;
                      final selected = ChildModel(
                        childId: first['id'] as String,
                        parentId: provider?.currentUser?.userId ?? 'parent_default',
                        name: first['name'] as String,
                        birthDate: DateTime.now().subtract(
                          Duration(days: 365 * (first['age'] as int)),
                        ),
                        currentDifficultyLevel: first['difficulty'] as int,
                        preferredLanguage: l10n.isArabic ? 'ar' : 'en',
                        createdAt: DateTime.now(),
                      );
                      provider?.selectChild(selected);
                    }
                    Navigator.pushNamed(context, AppRoutes.childHome);
                  },
                  icon: const Icon(Icons.play_circle_filled_rounded),
                  label: Text(
                    l10n.text('btn_start_learning'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog(
    BuildContext context,
    AuthProvider? provider,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    int selectedAge = 5;
    int selectedDifficulty = 1;
    // Default to Arabic as requested by user, while allowing dynamic toggle
    bool isDialogAr = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isAr = isDialogAr;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Text(
                      isAr ? 'إضافة حساب طفل جديد' : 'Add Child Profile',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setDialogState(() {
                        isDialogAr = !isDialogAr;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 14, color: AppColors.primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'اسم الطفل (Child\'s Name)' : "Child's Name",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: isAr ? 'مثال: سارة، فهد، أحمد' : 'e.g. Liam, Emma',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceM,
                          vertical: AppDimensions.spaceS,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(
                      isAr ? 'العمر: $selectedAge سنوات' : 'Age: $selectedAge years',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [4, 5, 6, 7, 8, 9, 10].map((age) {
                        final isSelected = selectedAge == age;
                        return ChoiceChip(
                          label: Text('$age'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            setDialogState(() => selectedAge = age);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final enteredName = nameController.text.trim();
                    if (enteredName.isEmpty) return;

                    Navigator.pop(dialogContext);

                    if (provider != null) {
                      await provider.addChildProfile(
                        name: enteredName,
                        age: selectedAge,
                        initialDifficulty: selectedDifficulty,
                        preferredLanguage: isAr ? 'ar' : 'en',
                      );
                    }

                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.childHome);
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(isAr ? 'حفظ وبدء التعلم' : 'Save & Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
