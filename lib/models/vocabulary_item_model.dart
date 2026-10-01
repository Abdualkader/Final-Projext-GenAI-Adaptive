/// Model representing an individual vocabulary flashcard item.
class VocabularyItemModel {
  final String id;
  final String categoryId;
  final String wordEn;
  final String wordAr;
  final String transliteration;
  final String imagePath;
  final String audioPathEn;
  final String audioPathAr;

  const VocabularyItemModel({
    required this.id,
    required this.categoryId,
    required this.wordEn,
    required this.wordAr,
    required this.transliteration,
    required this.imagePath,
    required this.audioPathEn,
    required this.audioPathAr,
  });

  String localizedWord(bool isArabic) => isArabic ? wordAr : wordEn;
}
