import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/quiz_question_model.dart';
import '../repositories/mock_data_repository.dart';

/// Single interactive option card matching Wireframe 2:
/// Rounded frame with colored border and bottom selection ring or checkmark badge.
class QuizChoiceCard extends StatelessWidget {
  final QuizChoice choice;
  final bool isSelected;
  final bool isCorrect;
  final bool isArabic;
  final VoidCallback onTap;
  final VoidCallback? onListen;

  const QuizChoiceCard({
    super.key,
    required this.choice,
    required this.isSelected,
    this.isCorrect = false,
    required this.isArabic,
    required this.onTap,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _resolveAccentColor();
    final borderColor = isSelected
        ? (isCorrect ? AppColors.success : AppColors.primaryBlue)
        : effectiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.cardBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? effectiveColor.withOpacity(0.08) : Colors.white,
            borderRadius: AppDimensions.cardBorderRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(isSelected ? 0.22 : 0.08),
                blurRadius: isSelected ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 6),
                  // Image, calligraphy glyph, or illustration area (Week 10 Task 4)
                  Expanded(
                    child: Center(
                      child: _buildChoiceVisual(choice, effectiveColor),
                    ),
                  ),
                  // Option Label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      choice.localizedLabel(isArabic),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  // Bottom status indicator (Checkmark or selection ring)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected && isCorrect
                            ? AppColors.success
                            : Colors.white,
                        border: Border.all(
                          color: isSelected && isCorrect
                              ? AppColors.success
                              : borderColor,
                          width: 3,
                        ),
                      ),
                      child: isSelected && isCorrect
                          ? const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              // Audio preview icon in top corner
              if (onListen != null)
                Positioned(
                  top: 6,
                  right: isArabic ? null : 6,
                  left: isArabic ? 6 : null,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onListen,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: effectiveColor.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volume_down_rounded,
                          size: 18,
                          color: effectiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveAccentColor() {
    final id = choice.id.toLowerCase();
    if (_isLetter(id)) {
      return _getLetterColor(id);
    }
    final numberColor = _getNumberColor(id);
    if (numberColor != null) {
      return numberColor;
    }
    return choice.accentColor;
  }

  Widget _buildChoiceVisual(QuizChoice choice, Color color) {
    final id = choice.id.toLowerCase();
    final explicitUrl = choice.imageUrl.trim();

    // 1. If choice specifies an explicit image URL, render it
    if (explicitUrl.isNotEmpty && (explicitUrl.startsWith('assets/') || explicitUrl.startsWith('http://') || explicitUrl.startsWith('https://'))) {
      return _renderImage(explicitUrl, () => _buildFallbackVisual(choice, color, id));
    }

    // 2. Letters and Numbers without explicit image: show Arabic calligraphy badge or number digit badge
    if (_isLetter(id) || _getNumberDigit(id) != null) {
      return _buildFallbackVisual(choice, color, id);
    }

    // 3. Animals, colors, and objects: check if real photo asset is available
    final repoImagePath = MockDataRepository.getImagePathForId(id);
    if (repoImagePath.isNotEmpty) {
      return _renderImage(repoImagePath, () => _buildFallbackVisual(choice, color, id));
    }

    return _buildFallbackVisual(choice, color, id);
  }

  Widget _renderImage(String path, Widget Function() onFallback) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Image.network(
          path,
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => onFallback(),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Image.asset(
          path,
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => onFallback(),
        ),
      );
    }
    return onFallback();
  }

  Widget _buildFallbackVisual(QuizChoice choice, Color color, String id) {
    // 1. Letters: render large colorful calligraphy badge
    if (_isLetter(id)) {
      final glyph = _getArabicLetterGlyph(id, choice.labelAr);
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4), width: 2.5),
        ),
        child: Center(
          child: Text(
            glyph,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.1,
            ),
          ),
        ),
      );
    }

    // 2. Numbers: render large number badge with numeral
    final digit = _getNumberDigit(id);
    if (digit != null) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4), width: 2.5),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      );
    }

    return _buildIconFallback(choice, color);
  }

  Widget _buildIconFallback(QuizChoice choice, Color color) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          choice.icon,
          size: 44,
          color: color,
        ),
      ),
    );
  }

  static bool _isLetter(String id) {
    const letters = {
      'alif', 'alef', 'baa', 'taa', 'thaa', 'jeem', 'haa', 'khaa',
      'daal', 'thaal', 'raa', 'zaay', 'seen', 'sheen', 'saad', 'daad',
      'ttaa', 'zhaa', 'ayn', 'ghayn', 'faa', 'qaaf', 'kaaf', 'laam',
      'meem', 'noon', 'hhaa', 'waaw', 'yaa',
    };
    return letters.contains(id.toLowerCase());
  }

  static String _getArabicLetterGlyph(String id, String labelAr) {
    const glyphMap = {
      'alif': 'أ', 'alef': 'أ', 'baa': 'ب', 'taa': 'ت', 'thaa': 'ث',
      'jeem': 'ج', 'haa': 'ح', 'khaa': 'خ', 'daal': 'د', 'thaal': 'ذ',
      'raa': 'ر', 'zaay': 'ز', 'seen': 'س', 'sheen': 'ش', 'saad': 'ص',
      'daad': 'ض', 'ttaa': 'ط', 'zhaa': 'ظ', 'ayn': 'ع', 'ghayn': 'غ',
      'faa': 'ف', 'qaaf': 'ق', 'kaaf': 'ك', 'laam': 'ل', 'meem': 'م',
      'noon': 'ن', 'hhaa': 'هـ', 'waaw': 'و', 'yaa': 'ي',
    };
    return glyphMap[id.toLowerCase()] ??
        (labelAr.isNotEmpty ? labelAr.substring(0, 1) : '🔤');
  }

  static Color _getLetterColor(String id) {
    const palette = [
      Color(0xFF8E24AA), Color(0xFF0288D1), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF6366F1),
      Color(0xFF0D9488), Color(0xFFEA580C),
    ];
    return palette[id.hashCode.abs() % palette.length];
  }

  static String? _getNumberDigit(String id) {
    const map = {
      'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
      'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    };
    return map[id.toLowerCase()];
  }

  static Color? _getNumberColor(String id) {
    const map = {
      'one': Color(0xFF3B82F6),
      'two': Color(0xFF10B981),
      'three': Color(0xFFF59E0B),
      'four': Color(0xFF8B5CF6),
      'five': Color(0xFFEF4444),
      'six': Color(0xFFEC4899),
      'seven': Color(0xFF8B5CF6),
      'eight': Color(0xFF0EA5E9),
      'nine': Color(0xFFF97316),
      'ten': Color(0xFF14B8A6),
    };
    return map[id.toLowerCase()];
  }
}
