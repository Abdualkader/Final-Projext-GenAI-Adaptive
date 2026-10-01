import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/category_bar_chart.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/stat_card.dart';

/// Progress Dashboard Screen matching Task 8 & Wireframe 3:
/// Sections for Mastered Vocabulary, Quiz Accuracy, Session Frequency, Progress Trend,
/// Date Filter, and Category Filter.
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = MockDataRepository.getSampleProgress();

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
        title: Column(
          children: [
            Text(
              l10n.text('dashboard_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              l10n.text('dashboard_subtitle'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exporting student progress report...'),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(l10n.text('export_data')),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          maxWidth: AppDimensions.maxTabletWidth,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Student Summary Card matching Wireframe 3
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDimensions.cardBorderRadius,
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Avatar & Student Info
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(color: AppColors.primaryBlue, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.face_rounded,
                            size: 46,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              progress.studentName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.text('child_age').replaceAll('{0}', progress.studentAge.toString()),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceM,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.primaryBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.isArabic ? progress.interestBadgeAr : progress.interestBadgeEn,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceM),

                // Core Progress Metrics Grid (Mastered Vocabulary, Quiz Accuracy, Frequency, Total Sessions)
                Row(
                  children: [
                    // Stat 1: Mastered Words
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: const Color(0xFF10B981),
                        value: '18',
                        label: l10n.text('mastered_vocabulary'),
                        subtitle: l10n.text('mastered_desc'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    // Stat 2: Overall Accuracy
                    Expanded(
                      child: StatCard(
                        icon: Icons.track_changes_rounded,
                        accentColor: AppColors.primaryBlue,
                        value: '${progress.overallAccuracy}%',
                        label: l10n.text('overall_accuracy'),
                        subtitle: l10n.text('great_job_stat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceM),
                Row(
                  children: [
                    // Stat 3: Total Sessions
                    Expanded(
                      child: StatCard(
                        icon: Icons.menu_book_rounded,
                        accentColor: const Color(0xFF8B5CF6),
                        value: '${progress.totalSessions}',
                        label: l10n.text('total_sessions'),
                        subtitle: l10n.text('total_sessions_desc'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    // Stat 4: Session Frequency
                    Expanded(
                      child: StatCard(
                        icon: Icons.repeat_rounded,
                        accentColor: const Color(0xFFF59E0B),
                        value: '4/wk',
                        label: l10n.text('session_frequency'),
                        subtitle: l10n.text('session_frequency_desc'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceM),

                // Filter Row matching Wireframe 3 (Date Filter & Category Filter)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceM,
                          vertical: AppDimensions.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range_rounded, size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            const Text(
                              'May 1 – May 31, 2025',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceM,
                          vertical: AppDimensions.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              l10n.text('category_all'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceM),

                // Category Bar Chart Card (Progress Trend)
                CategoryBarChart(
                  items: progress.categoryAccuracies,
                  isArabic: l10n.isArabic,
                ),
                const SizedBox(height: AppDimensions.spaceM),

                // Recent Sessions Card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDimensions.cardBorderRadius,
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.primaryBlue),
                          const SizedBox(width: AppDimensions.spaceS),
                          Text(
                            l10n.text('recent_sessions'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                      // Sessions List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: progress.recentSessions.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.borderLight,
                          height: 20,
                        ),
                        itemBuilder: (context, index) {
                          final session = progress.recentSessions[index];
                          final isHigh = session.accuracyPercentage >= 80;

                          return Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceM),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.date,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          session.categoryIcon,
                                          size: 14,
                                          color: session.categoryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          session.localizedCategory(l10n.isArabic),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: session.categoryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  session.score,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spaceM,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isHigh
                                      ? AppColors.successLight
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${session.accuracyPercentage}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isHigh
                                            ? AppColors.success
                                            : const Color(0xFFD97706),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      isHigh
                                          ? Icons.sentiment_very_satisfied_rounded
                                          : Icons.sentiment_neutral_rounded,
                                      size: 16,
                                      color: isHigh
                                          ? AppColors.success
                                          : const Color(0xFFD97706),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(l10n.text('view_all_sessions')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceS,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: l10n.text('nav_home'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.childHome,
                (route) => false,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.insights_rounded, color: AppColors.primaryBlue),
              tooltip: l10n.text('nav_progress'),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.text('nav_settings'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.parentSettings),
            ),
          ],
        ),
      ),
    );
  }
}
