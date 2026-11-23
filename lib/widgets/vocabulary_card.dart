import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../models/vocabulary_item_model.dart';
import '../repositories/mock_data_repository.dart';
import '../services/storage_service.dart';
import 'app_button.dart';
import 'large_icon_button.dart';
import 'loading_widget.dart';

/// Vocabulary flashcard matching Wireframe 4 & Week 8 requirements:
/// - Sensory-calm visual layout with image fallback UI (Task 5)
/// - Prominent bilingual typography with active language emphasis (Task 7)
/// - Single and dual audio pronunciation buttons (Task 10 & 11)
/// - Difficulty level pill (Task 4)
/// - Explicit, predictable navigation controls
class VocabularyCard extends StatelessWidget {
  final VocabularyItemModel item;
  final VoidCallback onPlayAudio;
  final VoidCallback? onPlayAudioAr;
  final VoidCallback? onPlayAudioEn;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool hasPrevious;
  final bool hasNext;
  final String nextButtonLabel;
  final IconData? nextButtonIcon;
  final String audioButtonLabel;
  final bool isArabic;
  final bool isPlayingAudio;
  final Widget? reminderWidget;
  final VoidCallback? onCardTap;

  const VocabularyCard({
    super.key,
    required this.item,
    required this.onPlayAudio,
    this.onPlayAudioAr,
    this.onPlayAudioEn,
    required this.onPrevious,
    required this.onNext,
    this.hasPrevious = true,
    this.hasNext = true,
    this.nextButtonLabel = 'Next',
    this.nextButtonIcon,
    this.audioButtonLabel = 'Play Audio',
    this.isArabic = false,
    this.isPlayingAudio = false,
    this.reminderWidget,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (reminderWidget != null) ...[
          reminderWidget!,
          const SizedBox(height: AppDimensions.spaceS),
        ],
        // Main Flashcard Frame
        Expanded(
          child: GestureDetector(
            onTap: onCardTap,
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDimensions.largeCardBorderRadius,
              border: Border.all(color: AppColors.borderLight, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppDimensions.largeCardBorderRadius,
              child: Column(
                children: [
                  // Top info strip (Clean sensory layout without arbitrary difficulty levels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceXS,
                    ),
                    color: AppColors.background.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isArabic ? 'بطاقة تعلّم' : 'Learning Card',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        if (item.transliteration.isNotEmpty)
                          Text(
                            item.transliteration,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Image Presentation Area (Task 5: With fallback UI & safe sizing)
                  Expanded(
                    flex: 7,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.spaceM),
                      color: AppColors.background,
                      child: Center(
                        child: _buildImageArea(context, item),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),

                  // Bilingual Labels Area (Task 7 & 10)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceXL,
                        vertical: AppDimensions.spaceS,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // English Label
                          Expanded(
                            child: Text(
                              item.wordEn,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: isArabic ? 28 : 36,
                                fontWeight: isArabic ? FontWeight.w700 : FontWeight.w800,
                                color: isArabic ? AppColors.textSecondary : AppColors.primaryBlue,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceM),
                          // Arabic Label
                          Expanded(
                            child: Text(
                              item.wordAr,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: isArabic ? 38 : 30,
                                fontWeight: isArabic ? FontWeight.w800 : FontWeight.w700,
                                color: isArabic ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // Central Audio Action Button (Task 10 & 11)
        AppButton(
          label: '🔊  $audioButtonLabel',
          height: 52,
          backgroundColor: AppColors.primaryBlue,
          onPressed: onPlayAudio,
        ),
        const SizedBox(height: AppDimensions.spaceXS),

        // Optional bilingual dual-audio preview row (Task 11)
        if (onPlayAudioAr != null || onPlayAudioEn != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
            child: Row(
              children: [
                if (onPlayAudioAr != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primaryBlue),
                      label: Text(
                        isArabic ? 'عربي 🔊' : 'Arabic 🔊',
                        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: onPlayAudioAr,
                    ),
                  ),
                if (onPlayAudioAr != null && onPlayAudioEn != null)
                  const SizedBox(width: AppDimensions.spaceS),
                if (onPlayAudioEn != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primaryBlue),
                      label: Text(
                        isArabic ? 'إنجليزي 🔊' : 'English 🔊',
                        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: onPlayAudioEn,
                    ),
                  ),
              ],
            ),
          ),

        // Pagination & Navigation Row
        Row(
          children: [
            if (hasPrevious)
              LargeIconButton(
                icon: Icons.arrow_back_rounded,
                size: 52,
                onPressed: onPrevious,
                iconColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
              ),
            if (hasPrevious) const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: AppButton(
                label: nextButtonLabel,
                icon: nextButtonIcon ?? Icons.arrow_forward_rounded,
                height: 52,
                backgroundColor: const Color(0xFF10B981),
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Level pill removed per pedagogical review (levels are not based on scientific ASD studies)
  Widget _buildDifficultyPill(int level) {
    return const SizedBox.shrink();
  }

  /// Image resolver supporting network URLs, local asset paths,
  /// Firebase Storage paths, and friendly fallback illustrations (Task 5).
  Widget _buildImageArea(BuildContext context, VocabularyItemModel item) {
    String rawUrl = item.imageUrl.trim();

    // If imageUrl is a mock Firestore path or empty, resolve real local asset
    if (rawUrl.isEmpty || rawUrl.startsWith('vocabulary/')) {
      final repoAsset = MockDataRepository.getImagePathForId(item.id);
      if (repoAsset.isNotEmpty) {
        rawUrl = repoAsset;
      }
    }

    if (rawUrl.isEmpty || rawUrl.startsWith('invalid://')) {
      return _buildVocabularyIllustration(item);
    }

    // Direct HTTP/HTTPS Network URL
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Image.network(
          rawUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const LoadingWidget(isCompact: true);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildVocabularyIllustration(item);
          },
        ),
      );
    }

    // Local Asset Image (registered in pubspec.yaml)
    if (rawUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Image.asset(
          rawUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildVocabularyIllustration(item);
          },
        ),
      );
    }

    // Cloud Storage Bucket Path (resolve via StorageService)
    return FutureBuilder<String>(
      future: StorageService().getDownloadUrl(rawUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(isCompact: true);
        }

        final resolved = snapshot.data;
        if (resolved != null &&
            (resolved.startsWith('http://') || resolved.startsWith('https://'))) {
          return Image.network(
            resolved,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const LoadingWidget(isCompact: true);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildVocabularyIllustration(item);
            },
          );
        }

        // Offline or storage path fallback
        return _buildVocabularyIllustration(item);
      },
    );
  }

  /// Friendly fallback illustration for broken images, offline state, or symbol display (Task 5).
  Widget _buildVocabularyIllustration(VocabularyItemModel item) {
    final id = item.id.toLowerCase();
    IconData icon;
    Color iconColor;
    String label;

    switch (id) {
      // Animals
      case 'cat':
        icon = Icons.cruelty_free_rounded;
        iconColor = const Color(0xFFF59E0B);
        label = '🐱 Cat / قطة';
        break;
      case 'dog':
        icon = Icons.pets_rounded;
        iconColor = const Color(0xFF10B981);
        label = '🐶 Dog / كلب';
        break;
      case 'rabbit':
        icon = Icons.cruelty_free_rounded;
        iconColor = const Color(0xFFF97316);
        label = '🐰 Rabbit / أرنب';
        break;
      case 'bird':
        icon = Icons.flutter_dash_rounded;
        iconColor = const Color(0xFF0288D1);
        label = '🐦 Bird / عصفور';
        break;
      case 'lion':
        icon = Icons.pets_rounded;
        iconColor = const Color(0xFFD97706);
        label = '🦁 Lion / أسد';
        break;
      case 'fish':
        icon = Icons.set_meal_rounded;
        iconColor = const Color(0xFF3B82F6);
        label = '🐟 Fish / سمكة';
        break;

      // Colors
      case 'red':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFFEF4444);
        label = '🔴 Red / أحمر';
        break;
      case 'blue':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFF3B82F6);
        label = '🔵 Blue / أزرق';
        break;
      case 'green':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFF10B981);
        label = '🟢 Green / أخضر';
        break;
      case 'yellow':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFFF59E0B);
        label = '🟡 Yellow / أصفر';
        break;
      case 'orange':
        icon = Icons.palette_rounded;
        iconColor = const Color(0xFFEA580C);
        label = '🟠 Orange / برتقالي';
        break;

      // Numbers
      case 'one':
        icon = Icons.looks_one_rounded;
        iconColor = const Color(0xFF0288D1);
        label = '1️⃣ One / واحد';
        break;
      case 'two':
        icon = Icons.looks_two_rounded;
        iconColor = const Color(0xFFF59E0B);
        label = '2️⃣ Two / اثنان';
        break;
      case 'three':
        icon = Icons.looks_3_rounded;
        iconColor = const Color(0xFF10B981);
        label = '3️⃣ Three / ثلاثة';
        break;
      case 'four':
        icon = Icons.looks_4_rounded;
        iconColor = const Color(0xFF6366F1);
        label = '4️⃣ Four / أربعة';
        break;
      case 'five':
        icon = Icons.looks_5_rounded;
        iconColor = const Color(0xFF059669);
        label = '5️⃣ Five / خمسة';
        break;
      case 'six':
        icon = Icons.looks_6_rounded;
        iconColor = const Color(0xFFEC4899);
        label = '6️⃣ Six / ستة';
        break;
      case 'seven':
        icon = Icons.filter_7_rounded;
        iconColor = const Color(0xFF8B5CF6);
        label = '7️⃣ Seven / سبعة';
        break;
      case 'eight':
        icon = Icons.filter_8_rounded;
        iconColor = const Color(0xFF0EA5E9);
        label = '8️⃣ Eight / ثمانية';
        break;
      case 'nine':
        icon = Icons.filter_9_rounded;
        iconColor = const Color(0xFFF97316);
        label = '9️⃣ Nine / تسعة';
        break;
      case 'ten':
        icon = Icons.filter_9_plus_rounded;
        iconColor = const Color(0xFF14B8A6);
        label = '🔟 Ten / عشرة';
        break;

      default:
        // Letters category: render prominent Arabic typography badge
        if (item.categoryId == 'letters') {
          final letterGlyph = _getArabicLetterGlyph(item.id, item.wordAr);
          final letterColor = _getLetterColor(item.id);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: letterColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: letterColor.withOpacity(0.4), width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: letterColor.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letterGlyph,
                    style: TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      color: letterColor,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                '🔤 ${item.wordEn} • ${item.wordAr}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary.withOpacity(0.9),
                ),
              ),
            ],
          );
        }

        icon = Icons.auto_awesome_rounded;
        iconColor = AppColors.primaryBlue;
        label = '${item.wordEn} / ${item.wordAr}';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.3), width: 3),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 72,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  static String _getArabicLetterGlyph(String id, String wordAr) {
    const glyphMap = {
      'alif': 'أ', 'baa': 'ب', 'taa': 'ت', 'thaa': 'ث', 'jeem': 'ج',
      'haa': 'ح', 'khaa': 'خ', 'daal': 'د', 'thaal': 'ذ', 'raa': 'ر',
      'zaay': 'ز', 'seen': 'س', 'sheen': 'ش', 'saad': 'ص', 'daad': 'ض',
      'ttaa': 'ط', 'zhaa': 'ظ', 'ayn': 'ع', 'ghayn': 'غ', 'faa': 'ف',
      'qaaf': 'ق', 'kaaf': 'ك', 'laam': 'ل', 'meem': 'م', 'noon': 'ن',
      'hhaa': 'هـ', 'waaw': 'و', 'yaa': 'ي',
    };
    return glyphMap[id.toLowerCase()] ??
        (wordAr.isNotEmpty ? wordAr.substring(0, 1) : '🔤');
  }

  static Color _getLetterColor(String id) {
    const palette = [
      Color(0xFF8E24AA), Color(0xFF0288D1), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF6366F1),
      Color(0xFF0D9488), Color(0xFFEA580C),
    ];
    final hash = id.hashCode.abs();
    return palette[hash % palette.length];
  }
}
