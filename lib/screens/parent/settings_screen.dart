import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../widgets/large_icon_button.dart';

/// Settings & Accessibility screen allowing language switching, sensory adjustments,
/// and access to the developer backend diagnostics dashboard.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleLocale;

  const SettingsScreen({
    super.key,
    required this.onToggleLocale,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _calmSensoryMode = true;
  bool _audioPronunciation = true;
  double _volume = 0.8;
  int _sessionDurationMinutes = 15;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        title: Text(l10n.text('settings_title')),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceL),
            children: [
              // Language Switch Card
              _buildSettingCard(
                icon: Icons.language_rounded,
                iconColor: AppColors.primaryBlue,
                title: l10n.text('language'),
                subtitle: l10n.isArabic ? l10n.text('lang_ar') : l10n.text('lang_en'),
                trailing: ElevatedButton.icon(
                  onPressed: widget.onToggleLocale,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                  label: Text(l10n.isArabic ? 'English' : 'العربية'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Volume Control Card (Task 9)
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
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _volume == 0
                                ? Icons.volume_off_rounded
                                : _volume < 0.5
                                    ? Icons.volume_down_rounded
                                    : Icons.volume_up_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.text('volume_control'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(_volume * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryBlue,
                        inactiveTrackColor: AppColors.borderLight,
                        thumbColor: AppColors.primaryBlue,
                        overlayColor: AppColors.primaryBlue.withOpacity(0.15),
                        trackHeight: 8.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      ),
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (val) {
                          setState(() => _volume = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Session Duration Setting Card (Task 9)
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
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: AppColors.primaryBlue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.text('session_duration'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$_sessionDurationMinutes ${l10n.isArabic ? "دقيقة" : "minutes"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDurationChip(
                            label: l10n.text('duration_10_min'),
                            minutes: 10,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Expanded(
                          child: _buildDurationChip(
                            label: l10n.text('duration_15_min'),
                            minutes: 15,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Expanded(
                          child: _buildDurationChip(
                            label: l10n.text('duration_20_min'),
                            minutes: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Calm Sensory Mode Switch
              _buildSettingCard(
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFF10B981),
                title: l10n.text('calm_mode'),
                subtitle: l10n.text('calm_mode_desc'),
                trailing: Switch(
                  value: _calmSensoryMode,
                  activeColor: AppColors.success,
                  onChanged: (val) {
                    setState(() => _calmSensoryMode = val);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // Audio Pronunciation Switch
              _buildSettingCard(
                icon: Icons.volume_up_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: l10n.text('sound_effects'),
                subtitle: l10n.isArabic ? 'تشغيل تلقائي للصوتيات' : 'Automatic phonics audio playback',
                trailing: Switch(
                  value: _audioPronunciation,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => _audioPronunciation = val);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),

              // Developer Backend Diagnostics (Week 2 Preserved)
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: AppDimensions.spaceM),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.cardBorderRadius,
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                tileColor: Colors.white,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE7F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.terminal_rounded,
                    color: Color(0xFF7E57C2),
                  ),
                ),
                title: Text(
                  l10n.text('developer_backend'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text('Live Firebase & Cloud Function health tests'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.systemVerification);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip({
    required String label,
    required int minutes,
  }) {
    final isSelected = _sessionDurationMinutes == minutes;
    return ChoiceChip(
      label: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Colors.grey.shade100,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(vertical: 10),
      onSelected: (selected) {
        if (selected) {
          setState(() => _sessionDurationMinutes = minutes);
        }
      },
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: AppDimensions.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          trailing,
        ],
      ),
    );
  }
}
