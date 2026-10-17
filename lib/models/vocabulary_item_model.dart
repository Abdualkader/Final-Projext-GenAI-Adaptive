import '../core/utils/content_validator.dart';

/// Model representing an individual vocabulary flashcard item.
/// Fully aligns with the Firestore database schema (Collection: 'vocabularyItems')
/// while preserving backward compatibility with Week 4 UI widgets.
class VocabularyItemModel {
  final String id;
  final String categoryId;
  final String labelEn;
  final String labelAr;
  final String transliteration;
  final String imageUrl;
  final String audioUrlEn;
  final String audioUrlAr;
  final int difficultyLevel;

  const VocabularyItemModel({
    required this.id,
    required this.categoryId,
    String? labelEn,
    String? labelAr,
    String? wordEn,
    String? wordAr,
    this.transliteration = '',
    String? imageUrl,
    String? imagePath,
    String? audioUrlEn,
    String? audioPathEn,
    String? audioUrlAr,
    String? audioPathAr,
    this.difficultyLevel = 1,
  })  : labelEn = labelEn ?? wordEn ?? '',
        labelAr = labelAr ?? wordAr ?? '',
        imageUrl = imageUrl ?? imagePath ?? '',
        audioUrlEn = audioUrlEn ?? audioPathEn ?? '',
        audioUrlAr = audioUrlAr ?? audioPathAr ?? '';

  // Aliases for Firestore schema and Week 4 compatibility
  String get itemId => id;
  String get wordEn => labelEn;
  String get wordAr => labelAr;
  String get imagePath => imageUrl;
  String get audioPathEn => audioUrlEn;
  String get audioPathAr => audioUrlAr;

  /// Content validation conforming to Week 8 specifications.
  bool get isValid => ContentValidator.isValidVocabularyItem(this);

  String localizedWord(bool isArabic) => isArabic ? labelAr : labelEn;

  Map<String, dynamic> toMap() {
    return {
      'itemId': id,
      'categoryId': categoryId,
      'labelEn': labelEn,
      'labelAr': labelAr,
      'transliteration': transliteration,
      'imageUrl': imageUrl,
      'audioUrlEn': audioUrlEn,
      'audioUrlAr': audioUrlAr,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory VocabularyItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final itemId = id ?? map['itemId'] as String? ?? map['id'] as String? ?? '';
    return VocabularyItemModel(
      id: itemId,
      categoryId: map['categoryId'] as String? ?? '',
      labelEn: map['labelEn'] as String? ?? map['wordEn'] as String? ?? '',
      labelAr: map['labelAr'] as String? ?? map['wordAr'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? map['imagePath'] as String? ?? '',
      audioUrlEn: map['audioUrlEn'] as String? ?? map['audioPathEn'] as String? ?? '',
      audioUrlAr: map['audioUrlAr'] as String? ?? map['audioPathAr'] as String? ?? '',
      difficultyLevel: (map['difficultyLevel'] as num?)?.toInt() ?? 1,
    );
  }
}
