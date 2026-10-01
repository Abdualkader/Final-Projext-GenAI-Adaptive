import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../models/quiz_question_model.dart';
import '../../repositories/mock_data_repository.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/large_icon_button.dart';
import '../../widgets/quiz_choice_card.dart';

/// Interactive Quiz Screen faithfully matching Wireframe 2:
/// Calm sensory layout, 3 clear choices, positive feedback star mascot, and prompt audio replay.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizQuestionModel _question = MockDataRepository.getSampleQuizQuestion();
  String? _selectedChoiceId;
  int _starsCount = 12;

  bool get _isAnswered => _selectedChoiceId != null;
  bool get _isCorrect => _selectedChoiceId == _question.correctChoiceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceS),
              // Top Bar matching Wireframe 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Progress Counter (3 / 10)
                  Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '3 / 10',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          child: const LinearProgressIndicator(
                            value: 0.3,
                            minHeight: 6,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Star Points Counter (⭐ 12)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 24,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          '$_starsCount',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Question Card with Speaker Prompt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    LargeIconButton(
                      icon: Icons.volume_up_rounded,
                      size: 52,
                      iconSize: 28,
                      backgroundColor: AppColors.primaryBlue,
                      iconColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryBlue,
                            content: Text(
                              '🔊 ${_question.localizedPrompt(l10n.isArabic)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        _question.localizedPrompt(l10n.isArabic),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // 3 Choices Row matching Wireframe 2
              Expanded(
                child: Row(
                  children: _question.choices.map((choice) {
                    final isSelected = _selectedChoiceId == choice.id;
                    final isCorrect = choice.id == _question.correctChoiceId;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceXS,
                        ),
                        child: QuizChoiceCard(
                          choice: choice,
                          isSelected: isSelected,
                          isCorrect: isCorrect,
                          isArabic: l10n.isArabic,
                          onTap: () {
                            setState(() {
                              _selectedChoiceId = choice.id;
                              if (isCorrect && _starsCount == 12) {
                                _starsCount += 3;
                              }
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Positive Reinforcement Feedback Banner
              FeedbackBanner(
                isSuccess: _isAnswered && _isCorrect,
                title: (_isAnswered && _isCorrect)
                    ? l10n.text('feedback_excellent')
                    : l10n.text('feedback_great_job'),
                subtitle: (_isAnswered && _isCorrect)
                    ? l10n.text('feedback_found_item')
                    : l10n.text('feedback_you_can_do_it'),
                earnedStars: (_isAnswered && _isCorrect) ? 3 : 0,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // Bottom Action Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LargeIconButton(
                    icon: Icons.arrow_back_rounded,
                    size: 52,
                    onPressed: () => Navigator.pop(context),
                  ),
                  LargeIconButton(
                    icon: Icons.refresh_rounded,
                    size: 52,
                    backgroundColor: AppColors.background,
                    onPressed: () {
                      setState(() {
                        _selectedChoiceId = null;
                      });
                    },
                    tooltip: 'Repeat Question',
                  ),
                  LargeIconButton(
                    icon: Icons.arrow_forward_rounded,
                    size: 52,
                    iconColor: _isCorrect ? Colors.white : AppColors.primaryBlue,
                    backgroundColor: _isCorrect ? AppColors.primaryBlue : Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.parentDashboard);
                    },
                    tooltip: 'Next Question',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceS),
            ],
          ),
        ),
      ),
    );
  }
}
