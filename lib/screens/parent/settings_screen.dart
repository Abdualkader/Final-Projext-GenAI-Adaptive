import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/settings_provider.dart';
import '../../services/audio_service.dart';
import '../../services/openrouter_service.dart';
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

  // OpenRouter GenAI Integration
  late final TextEditingController _apiKeyController;
  bool _isTestingOpenRouter = false;
  String? _openRouterTestMessage;
  bool? _openRouterSuccess;
  String _selectedModel = OpenRouterService().model;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: OpenRouterService().apiKey ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        if (mounted) {
          setState(() {
            _volume = settings.volume;
            _sessionDurationMinutes = settings.sessionDurationMinutes;
            _audioPronunciation = settings.soundEffectsEnabled;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testOpenRouterConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _openRouterSuccess = false;
        _openRouterTestMessage = 'Please enter an OpenRouter API key.';
      });
      return;
    }

    setState(() {
      _isTestingOpenRouter = true;
      _openRouterTestMessage = null;
      _openRouterSuccess = null;
    });

    OpenRouterService().configure(apiKey: key, model: _selectedModel);
    final result = await OpenRouterService().testConnection();

    if (mounted) {
      setState(() {
        _isTestingOpenRouter = false;
        _openRouterSuccess = result.isSuccess;
        _openRouterTestMessage = result.message;
      });
    }
  }

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
                          try {
                            Provider.of<SettingsProvider>(context, listen: false).setVolume(val);
                          } catch (_) {
                            AudioService().setVolume(val);
                          }
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
                    try {
                      Provider.of<SettingsProvider>(context, listen: false).toggleSoundEffects(val);
                    } catch (_) {}
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // OpenRouter GenAI Integration Card
              _buildOpenRouterCard(l10n),
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
          try {
            Provider.of<SettingsProvider>(context, listen: false).setSessionDuration(minutes);
          } catch (_) {}
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

  Widget _buildOpenRouterCard(AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF0D9488),
                  size: 26,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.text('openrouter_config_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.text('openrouter_config_subtitle'),
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

          // Active Model Selector
          Text(
            l10n.text('openrouter_model'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModel,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: OpenRouterService.availableFreeModels.map((m) {
                  return DropdownMenuItem<String>(
                    value: m,
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF0D9488)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            m,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedModel = val);
                    OpenRouterService().configure(model: val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // API Key Input Field
          Text(
            l10n.text('openrouter_api_key'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter OpenRouter API Key',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
              ),
            ),
            onChanged: (val) {
              OpenRouterService().configure(apiKey: val);
            },
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Test Connection Button & Status
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isTestingOpenRouter ? null : _testOpenRouterConnection,
                icon: _isTestingOpenRouter
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.wifi_rounded, size: 18),
                label: Text(l10n.text('openrouter_test_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          if (_openRouterTestMessage != null) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (_openRouterSuccess ?? false)
                    ? Colors.green.shade50
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_openRouterSuccess ?? false)
                      ? Colors.green.shade200
                      : Colors.amber.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    (_openRouterSuccess ?? false)
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: (_openRouterSuccess ?? false)
                        ? Colors.green.shade700
                        : Colors.amber.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _openRouterTestMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: (_openRouterSuccess ?? false)
                            ? Colors.green.shade900
                            : Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
