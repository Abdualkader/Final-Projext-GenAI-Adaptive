import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/vocabulary_item_model.dart';
import '../models/quiz_question_model.dart';
import '../models/progress_model.dart';

/// Explicit repository for Week 4 UI mocking.
/// Strictly separated from future production Firebase repositories.
class MockDataRepository {
  static List<CategoryModel> getCategories() {
    return const [
      CategoryModel(
        id: 'letters',
        nameEn: 'Letters',
        nameAr: 'الحروف',
        backgroundColor: AppColors.cardLetters,
        textColor: AppColors.textLetters,
        borderColor: AppColors.borderLetters,
        icon: Icons.spellcheck_rounded,
        illustrationKey: 'letters_abc',
      ),
      CategoryModel(
        id: 'numbers',
        nameEn: 'Numbers',
        nameAr: 'الأرقام',
        backgroundColor: AppColors.cardNumbers,
        textColor: AppColors.textNumbers,
        borderColor: AppColors.borderNumbers,
        icon: Icons.looks_one_rounded,
        illustrationKey: 'numbers_123',
      ),
      CategoryModel(
        id: 'colours',
        nameEn: 'Colors',
        nameAr: 'الألوان',
        backgroundColor: AppColors.cardColours,
        textColor: AppColors.textColours,
        borderColor: AppColors.borderColours,
        icon: Icons.palette_rounded,
        illustrationKey: 'rainbow',
      ),
      CategoryModel(
        id: 'animals',
        nameEn: 'Animals',
        nameAr: 'الحيوانات',
        backgroundColor: AppColors.cardAnimals,
        textColor: AppColors.textAnimals,
        borderColor: AppColors.borderAnimals,
        icon: Icons.pets,
        illustrationKey: 'dog',
      ),
    ];
  }

  static List<VocabularyItemModel> getVocabularyForCategory(String categoryId) {
    if (categoryId == 'all' || categoryId == 'mixed') {
      return [
        ...getVocabularyForCategory('letters'),
        ...getVocabularyForCategory('numbers'),
        ...getVocabularyForCategory('colours'),
        ...getVocabularyForCategory('animals'),
      ];
    }
    switch (categoryId) {
      case 'colours':
        return const [
          VocabularyItemModel(
            id: 'red',
            categoryId: 'colours',
            wordEn: 'Red',
            wordAr: 'أَحْمَر',
            transliteration: 'Ahmar',
            imagePath: 'assets/images/color_red.jpg',
            audioPathEn: '/vocabulary/audio/en/red.mp3',
            audioPathAr: '/vocabulary/audio/ar/red.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'blue',
            categoryId: 'colours',
            wordEn: 'Blue',
            wordAr: 'أَزْرَق',
            transliteration: 'Azraq',
            imagePath: 'assets/images/color_blue.jpg',
            audioPathEn: '/vocabulary/audio/en/blue.mp3',
            audioPathAr: '/vocabulary/audio/ar/blue.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'green',
            categoryId: 'colours',
            wordEn: 'Green',
            wordAr: 'أَخْضَر',
            transliteration: 'Akhdar',
            imagePath: 'assets/images/color_green.jpg',
            audioPathEn: '/vocabulary/audio/en/green.mp3',
            audioPathAr: '/vocabulary/audio/ar/green.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'yellow',
            categoryId: 'colours',
            wordEn: 'Yellow',
            wordAr: 'أَصْفَر',
            transliteration: 'Asfar',
            imagePath: 'assets/images/color_yellow.jpg',
            audioPathEn: '/vocabulary/audio/en/yellow.mp3',
            audioPathAr: '/vocabulary/audio/ar/yellow.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'orange',
            categoryId: 'colours',
            wordEn: 'Orange',
            wordAr: 'بُرْتُقَالِي',
            transliteration: 'Burtuqali',
            imagePath: 'assets/images/color_orange.jpg',
            audioPathEn: '/vocabulary/audio/en/orange.mp3',
            audioPathAr: '/vocabulary/audio/ar/orange.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'purple',
            categoryId: 'colours',
            wordEn: 'Purple',
            wordAr: 'بَنَفْسَجِي',
            transliteration: 'Banafsaji',
            imagePath: 'assets/images/color_purple.jpg',
            audioPathEn: '/vocabulary/audio/en/purple.mp3',
            audioPathAr: '/vocabulary/audio/ar/purple.mp3',
            difficultyLevel: 3,
          ),
        ];
      case 'numbers':
        return const [
          VocabularyItemModel(
            id: 'one',
            categoryId: 'numbers',
            wordEn: 'One',
            wordAr: 'وَاحِد',
            transliteration: 'Wahid',
            imagePath: 'assets/images/num_1.jpg',
            audioPathEn: '/vocabulary/audio/en/one.mp3',
            audioPathAr: '/vocabulary/audio/ar/one.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'two',
            categoryId: 'numbers',
            wordEn: 'Two',
            wordAr: 'اِثْنَان',
            transliteration: 'Ithnan',
            imagePath: 'assets/images/num_2.jpg',
            audioPathEn: '/vocabulary/audio/en/two.mp3',
            audioPathAr: '/vocabulary/audio/ar/two.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'three',
            categoryId: 'numbers',
            wordEn: 'Three',
            wordAr: 'ثَلَاثَة',
            transliteration: 'Thalatha',
            imagePath: 'assets/images/num_3.jpg',
            audioPathEn: '/vocabulary/audio/en/three.mp3',
            audioPathAr: '/vocabulary/audio/ar/three.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'four',
            categoryId: 'numbers',
            wordEn: 'Four',
            wordAr: 'أَرْبَعَة',
            transliteration: 'Arbaah',
            imagePath: 'assets/images/num_4.jpg',
            audioPathEn: '/vocabulary/audio/en/four.mp3',
            audioPathAr: '/vocabulary/audio/ar/four.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'five',
            categoryId: 'numbers',
            wordEn: 'Five',
            wordAr: 'خَمْسَة',
            transliteration: 'Khamsah',
            imagePath: 'assets/images/num_5.jpg',
            audioPathEn: '/vocabulary/audio/en/five.mp3',
            audioPathAr: '/vocabulary/audio/ar/five.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'six',
            categoryId: 'numbers',
            wordEn: 'Six',
            wordAr: 'سِتَّة',
            transliteration: 'Sittah',
            imagePath: 'assets/images/num_6.jpg',
            audioPathEn: '/vocabulary/audio/en/six.mp3',
            audioPathAr: '/vocabulary/audio/ar/six.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'seven',
            categoryId: 'numbers',
            wordEn: 'Seven',
            wordAr: 'سَبْعَة',
            transliteration: 'Sabah',
            imagePath: 'assets/images/num_7.jpg',
            audioPathEn: '/vocabulary/audio/en/seven.mp3',
            audioPathAr: '/vocabulary/audio/ar/seven.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'eight',
            categoryId: 'numbers',
            wordEn: 'Eight',
            wordAr: 'ثَمَانِيَة',
            transliteration: 'Thamaniyah',
            imagePath: 'assets/images/num_8.jpg',
            audioPathEn: '/vocabulary/audio/en/eight.mp3',
            audioPathAr: '/vocabulary/audio/ar/eight.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'nine',
            categoryId: 'numbers',
            wordEn: 'Nine',
            wordAr: 'تِسْعَة',
            transliteration: 'Tisaah',
            imagePath: 'assets/images/num_9.jpg',
            audioPathEn: '/vocabulary/audio/en/nine.mp3',
            audioPathAr: '/vocabulary/audio/ar/nine.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'ten',
            categoryId: 'numbers',
            wordEn: 'Ten',
            wordAr: 'عَشَرَة',
            transliteration: 'Asharah',
            imagePath: 'assets/images/num_10.jpg',
            audioPathEn: '/vocabulary/audio/en/ten.mp3',
            audioPathAr: '/vocabulary/audio/ar/ten.mp3',
            difficultyLevel: 3,
          ),
        ];
      case 'letters':
        return const [
          VocabularyItemModel(
            id: 'alif',
            categoryId: 'letters',
            wordEn: 'Letter A',
            wordAr: 'أَلِف',
            transliteration: 'Alif',
            imagePath: 'assets/images/letter_alif.jpg',
            audioPathEn: '/vocabulary/audio/en/a.mp3',
            audioPathAr: '/vocabulary/audio/ar/alif.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'baa',
            categoryId: 'letters',
            wordEn: 'Letter B',
            wordAr: 'بَاء',
            transliteration: 'Baa',
            imagePath: 'assets/images/letter_baa.jpg',
            audioPathEn: '/vocabulary/audio/en/b.mp3',
            audioPathAr: '/vocabulary/audio/ar/baa.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'taa',
            categoryId: 'letters',
            wordEn: 'Letter T',
            wordAr: 'تَاء',
            transliteration: 'Taa',
            imagePath: 'assets/images/letter_taa.jpg',
            audioPathEn: '/vocabulary/audio/en/t.mp3',
            audioPathAr: '/vocabulary/audio/ar/taa.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'thaa',
            categoryId: 'letters',
            wordEn: 'Letter Th',
            wordAr: 'ثَاء',
            transliteration: 'Thaa',
            imagePath: 'assets/images/letter_thaa.jpg',
            audioPathEn: '/vocabulary/audio/en/th.mp3',
            audioPathAr: '/vocabulary/audio/ar/thaa.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'jeem',
            categoryId: 'letters',
            wordEn: 'Letter J',
            wordAr: 'جِيم',
            transliteration: 'Jeem',
            imagePath: 'assets/images/letter_jeem.jpg',
            audioPathEn: '/vocabulary/audio/en/j.mp3',
            audioPathAr: '/vocabulary/audio/ar/jeem.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'haa',
            categoryId: 'letters',
            wordEn: 'Letter H',
            wordAr: 'حَاء',
            transliteration: 'Haa',
            imagePath: 'assets/images/letter_haa.jpg',
            audioPathEn: '/vocabulary/audio/en/h.mp3',
            audioPathAr: '/vocabulary/audio/ar/haa.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'khaa',
            categoryId: 'letters',
            wordEn: 'Letter Kh',
            wordAr: 'خَاء',
            transliteration: 'Khaa',
            imagePath: 'assets/images/letter_khaa.jpg',
            audioPathEn: '/vocabulary/audio/en/kh.mp3',
            audioPathAr: '/vocabulary/audio/ar/khaa.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'daal',
            categoryId: 'letters',
            wordEn: 'Letter D',
            wordAr: 'دَال',
            transliteration: 'Daal',
            imagePath: 'assets/images/letter_daal.jpg',
            audioPathEn: '/vocabulary/audio/en/d.mp3',
            audioPathAr: '/vocabulary/audio/ar/daal.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'thaal',
            categoryId: 'letters',
            wordEn: 'Letter Dh',
            wordAr: 'ذَال',
            transliteration: 'Thaal',
            imagePath: 'assets/images/letter_thaal.jpg',
            audioPathEn: '/vocabulary/audio/en/dh.mp3',
            audioPathAr: '/vocabulary/audio/ar/thaal.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'raa',
            categoryId: 'letters',
            wordEn: 'Letter R',
            wordAr: 'رَاء',
            transliteration: 'Raa',
            imagePath: 'assets/images/letter_raa.jpg',
            audioPathEn: '/vocabulary/audio/en/r.mp3',
            audioPathAr: '/vocabulary/audio/ar/raa.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'zaay',
            categoryId: 'letters',
            wordEn: 'Letter Z',
            wordAr: 'زَاي',
            transliteration: 'Zaay',
            imagePath: 'assets/images/letter_zaay.jpg',
            audioPathEn: '/vocabulary/audio/en/z.mp3',
            audioPathAr: '/vocabulary/audio/ar/zaay.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'seen',
            categoryId: 'letters',
            wordEn: 'Letter S',
            wordAr: 'سِين',
            transliteration: 'Seen',
            imagePath: 'assets/images/letter_seen.jpg',
            audioPathEn: '/vocabulary/audio/en/s.mp3',
            audioPathAr: '/vocabulary/audio/ar/seen.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'sheen',
            categoryId: 'letters',
            wordEn: 'Letter Sh',
            wordAr: 'شِين',
            transliteration: 'Sheen',
            imagePath: 'assets/images/letter_sheen.jpg',
            audioPathEn: '/vocabulary/audio/en/sh.mp3',
            audioPathAr: '/vocabulary/audio/ar/sheen.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'saad',
            categoryId: 'letters',
            wordEn: 'Letter S',
            wordAr: 'صَاد',
            transliteration: 'Saad',
            imagePath: 'assets/images/letter_saad.jpg',
            audioPathEn: '/vocabulary/audio/en/sad.mp3',
            audioPathAr: '/vocabulary/audio/ar/saad.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'daad',
            categoryId: 'letters',
            wordEn: 'Letter D',
            wordAr: 'ضَاد',
            transliteration: 'Daad',
            imagePath: 'assets/images/letter_daad.jpg',
            audioPathEn: '/vocabulary/audio/en/dad.mp3',
            audioPathAr: '/vocabulary/audio/ar/daad.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'ttaa',
            categoryId: 'letters',
            wordEn: 'Letter T',
            wordAr: 'طَاء',
            transliteration: 'Ttaa',
            imagePath: 'assets/images/letter_ttaa.jpg',
            audioPathEn: '/vocabulary/audio/en/t2.mp3',
            audioPathAr: '/vocabulary/audio/ar/ttaa.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'zhaa',
            categoryId: 'letters',
            wordEn: 'Letter Zh',
            wordAr: 'ظَاء',
            transliteration: 'Zhaa',
            imagePath: 'assets/images/letter_zhaa.jpg',
            audioPathEn: '/vocabulary/audio/en/zh.mp3',
            audioPathAr: '/vocabulary/audio/ar/zhaa.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'ayn',
            categoryId: 'letters',
            wordEn: 'Letter Ayn',
            wordAr: 'عَيْن',
            transliteration: 'Ayn',
            imagePath: 'assets/images/letter_ayn.jpg',
            audioPathEn: '/vocabulary/audio/en/ayn.mp3',
            audioPathAr: '/vocabulary/audio/ar/ayn.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'ghayn',
            categoryId: 'letters',
            wordEn: 'Letter Gh',
            wordAr: 'غَيْن',
            transliteration: 'Ghayn',
            imagePath: 'assets/images/letter_ghayn.jpg',
            audioPathEn: '/vocabulary/audio/en/gh.mp3',
            audioPathAr: '/vocabulary/audio/ar/ghayn.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'faa',
            categoryId: 'letters',
            wordEn: 'Letter F',
            wordAr: 'فَاء',
            transliteration: 'Faa',
            imagePath: 'assets/images/letter_faa.jpg',
            audioPathEn: '/vocabulary/audio/en/f.mp3',
            audioPathAr: '/vocabulary/audio/ar/faa.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'qaaf',
            categoryId: 'letters',
            wordEn: 'Letter Q',
            wordAr: 'قَاف',
            transliteration: 'Qaaf',
            imagePath: 'assets/images/letter_qaaf.jpg',
            audioPathEn: '/vocabulary/audio/en/q.mp3',
            audioPathAr: '/vocabulary/audio/ar/qaaf.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'kaaf',
            categoryId: 'letters',
            wordEn: 'Letter K',
            wordAr: 'كَاف',
            transliteration: 'Kaaf',
            imagePath: 'assets/images/letter_kaaf.jpg',
            audioPathEn: '/vocabulary/audio/en/k.mp3',
            audioPathAr: '/vocabulary/audio/ar/kaaf.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'laam',
            categoryId: 'letters',
            wordEn: 'Letter L',
            wordAr: 'لاَم',
            transliteration: 'Laam',
            imagePath: 'assets/images/letter_laam.jpg',
            audioPathEn: '/vocabulary/audio/en/l.mp3',
            audioPathAr: '/vocabulary/audio/ar/laam.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'meem',
            categoryId: 'letters',
            wordEn: 'Letter M',
            wordAr: 'مِيم',
            transliteration: 'Meem',
            imagePath: 'assets/images/letter_meem.jpg',
            audioPathEn: '/vocabulary/audio/en/m.mp3',
            audioPathAr: '/vocabulary/audio/ar/meem.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'noon',
            categoryId: 'letters',
            wordEn: 'Letter N',
            wordAr: 'نُون',
            transliteration: 'Noon',
            imagePath: 'assets/images/letter_noon.jpg',
            audioPathEn: '/vocabulary/audio/en/n.mp3',
            audioPathAr: '/vocabulary/audio/ar/noon.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'hhaa',
            categoryId: 'letters',
            wordEn: 'Letter H',
            wordAr: 'هَاء',
            transliteration: 'Haa',
            imagePath: 'assets/images/letter_hhaa.jpg',
            audioPathEn: '/vocabulary/audio/en/ha.mp3',
            audioPathAr: '/vocabulary/audio/ar/hhaa.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'waaw',
            categoryId: 'letters',
            wordEn: 'Letter W',
            wordAr: 'وَاو',
            transliteration: 'Waaw',
            imagePath: 'assets/images/letter_waaw.jpg',
            audioPathEn: '/vocabulary/audio/en/w.mp3',
            audioPathAr: '/vocabulary/audio/ar/waaw.mp3',
            difficultyLevel: 3,
          ),
          VocabularyItemModel(
            id: 'yaa',
            categoryId: 'letters',
            wordEn: 'Letter Y',
            wordAr: 'يَاء',
            transliteration: 'Yaa',
            imagePath: 'assets/images/letter_yaa.jpg',
            audioPathEn: '/vocabulary/audio/en/y.mp3',
            audioPathAr: '/vocabulary/audio/ar/yaa.mp3',
            difficultyLevel: 3,
          ),
        ];
      case 'animals':
      default:
        return const [
          VocabularyItemModel(
            id: 'cat',
            categoryId: 'animals',
            wordEn: 'Cat',
            wordAr: 'قِطَّة',
            transliteration: 'Qittah',
            imagePath: 'assets/images/cat.jpg',
            audioPathEn: '/vocabulary/audio/en/cat.mp3',
            audioPathAr: '/vocabulary/audio/ar/cat.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'dog',
            categoryId: 'animals',
            wordEn: 'Dog',
            wordAr: 'كَلْب',
            transliteration: 'Kalb',
            imagePath: 'assets/images/dog.jpg',
            audioPathEn: '/vocabulary/audio/en/dog.mp3',
            audioPathAr: '/vocabulary/audio/ar/dog.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'rabbit',
            categoryId: 'animals',
            wordEn: 'Rabbit',
            wordAr: 'أَرْنَب',
            transliteration: 'Arnab',
            imagePath: 'assets/images/rabbit.jpg',
            audioPathEn: '/vocabulary/audio/en/rabbit.mp3',
            audioPathAr: '/vocabulary/audio/ar/rabbit.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'bird',
            categoryId: 'animals',
            wordEn: 'Bird',
            wordAr: 'عُصْفُور',
            transliteration: 'Usfur',
            imagePath: 'assets/images/bird.jpg',
            audioPathEn: '/vocabulary/audio/en/bird.mp3',
            audioPathAr: '/vocabulary/audio/ar/bird.mp3',
            difficultyLevel: 1,
          ),
          VocabularyItemModel(
            id: 'cow',
            categoryId: 'animals',
            wordEn: 'Cow',
            wordAr: 'بَقَرَة',
            transliteration: 'Baqarah',
            imagePath: 'assets/images/cow.jpg',
            audioPathEn: '/vocabulary/audio/en/cow.mp3',
            audioPathAr: '/vocabulary/audio/ar/cow.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'lion',
            categoryId: 'animals',
            wordEn: 'Lion',
            wordAr: 'أَسَد',
            transliteration: 'Asad',
            imagePath: 'assets/images/lion.jpg',
            audioPathEn: '/vocabulary/audio/en/lion.mp3',
            audioPathAr: '/vocabulary/audio/ar/lion.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'elephant',
            categoryId: 'animals',
            wordEn: 'Elephant',
            wordAr: 'فِيل',
            transliteration: 'Feel',
            imagePath: 'assets/images/elephant.jpg',
            audioPathEn: '/vocabulary/audio/en/elephant.mp3',
            audioPathAr: '/vocabulary/audio/ar/elephant.mp3',
            difficultyLevel: 2,
          ),
          VocabularyItemModel(
            id: 'fish',
            categoryId: 'animals',
            wordEn: 'Fish',
            wordAr: 'سَمَكَة',
            transliteration: 'Samakah',
            imagePath: 'assets/images/fish.jpg',
            audioPathEn: '/vocabulary/audio/en/fish.mp3',
            audioPathAr: '/vocabulary/audio/ar/fish.mp3',
            difficultyLevel: 1,
          ),
        ];
    }
  }

  static QuizQuestionModel getQuizQuestionForCategory(String categoryId) {
    return getQuizQuestionsForCategory(categoryId).first;
  }

  /// Full 5-question multi-item quiz banks for all learning domains.
  static List<QuizQuestionModel> getQuizQuestionsForCategory(String categoryId, {int count = 5}) {
    final cat = (categoryId == 'colors' || categoryId == 'colours') ? 'colours' : categoryId;

    if (cat == 'all' || cat == 'mixed') {
      final combined = [
        ...getQuizQuestionsForCategory('letters', count: 5),
        ...getQuizQuestionsForCategory('numbers', count: 5),
        ...getQuizQuestionsForCategory('colours', count: 5),
        ...getQuizQuestionsForCategory('animals', count: 5),
      ];
      combined.shuffle();
      return combined.take(count).toList();
    }

    List<QuizQuestionModel> questions;

    switch (cat) {
      case 'colours':
        questions = const [
          QuizQuestionModel(
            id: 'quiz_colour_red',
            promptEn: 'Which one is Red?',
            promptAr: 'أين اللون الأحمر؟',
            correctChoiceId: 'red',
            choices: [
              QuizChoice(
                id: 'red',
                labelEn: 'Red',
                labelAr: 'أحمر',
                icon: Icons.circle,
                accentColor: Color(0xFFEF4444),
              ),
              QuizChoice(
                id: 'blue',
                labelEn: 'Blue',
                labelAr: 'أزرق',
                icon: Icons.circle,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'green',
                labelEn: 'Green',
                labelAr: 'أخضر',
                icon: Icons.circle,
                accentColor: Color(0xFF10B981),
              ),
            ],
            categoryId: 'colours',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_colour_blue',
            promptEn: 'Which one is Blue?',
            promptAr: 'أين اللون الأزرق؟',
            correctChoiceId: 'blue',
            choices: [
              QuizChoice(
                id: 'yellow',
                labelEn: 'Yellow',
                labelAr: 'أصفر',
                icon: Icons.circle,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'blue',
                labelEn: 'Blue',
                labelAr: 'أزرق',
                icon: Icons.circle,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'red',
                labelEn: 'Red',
                labelAr: 'أحمر',
                icon: Icons.circle,
                accentColor: Color(0xFFEF4444),
              ),
            ],
            categoryId: 'colours',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_colour_green',
            promptEn: 'Which one is Green?',
            promptAr: 'أين اللون الأخضر؟',
            correctChoiceId: 'green',
            choices: [
              QuizChoice(
                id: 'green',
                labelEn: 'Green',
                labelAr: 'أخضر',
                icon: Icons.circle,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'orange',
                labelEn: 'Orange',
                labelAr: 'برتقالي',
                icon: Icons.circle,
                accentColor: Color(0xFFF97316),
              ),
              QuizChoice(
                id: 'blue',
                labelEn: 'Blue',
                labelAr: 'أزرق',
                icon: Icons.circle,
                accentColor: Color(0xFF3B82F6),
              ),
            ],
            categoryId: 'colours',
            difficultyLevel: 2,
          ),
          QuizQuestionModel(
            id: 'quiz_colour_yellow',
            promptEn: 'Which one is Yellow?',
            promptAr: 'أين اللون الأصفر؟',
            correctChoiceId: 'yellow',
            choices: [
              QuizChoice(
                id: 'red',
                labelEn: 'Red',
                labelAr: 'أحمر',
                icon: Icons.circle,
                accentColor: Color(0xFFEF4444),
              ),
              QuizChoice(
                id: 'green',
                labelEn: 'Green',
                labelAr: 'أخضر',
                icon: Icons.circle,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'yellow',
                labelEn: 'Yellow',
                labelAr: 'أصفر',
                icon: Icons.circle,
                accentColor: Color(0xFFF59E0B),
              ),
            ],
            categoryId: 'colours',
            difficultyLevel: 2,
          ),
          QuizQuestionModel(
            id: 'quiz_colour_orange',
            promptEn: 'Which one is Orange?',
            promptAr: 'أين اللون البرتقالي؟',
            correctChoiceId: 'orange',
            choices: [
              QuizChoice(
                id: 'orange',
                labelEn: 'Orange',
                labelAr: 'برتقالي',
                icon: Icons.circle,
                accentColor: Color(0xFFF97316),
              ),
              QuizChoice(
                id: 'blue',
                labelEn: 'Blue',
                labelAr: 'أزرق',
                icon: Icons.circle,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'yellow',
                labelEn: 'Yellow',
                labelAr: 'أصفر',
                icon: Icons.circle,
                accentColor: Color(0xFFF59E0B),
              ),
            ],
            categoryId: 'colours',
            difficultyLevel: 2,
          ),
        ];
        break;

      case 'numbers':
        questions = const [
          QuizQuestionModel(
            id: 'quiz_number_one',
            promptEn: 'Where is Number 1?',
            promptAr: 'أين الرقم ١؟',
            correctChoiceId: 'one',
            choices: [
              QuizChoice(
                id: 'one',
                labelEn: 'One',
                labelAr: 'واحد',
                icon: Icons.looks_one_rounded,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'two',
                labelEn: 'Two',
                labelAr: 'اثنان',
                icon: Icons.looks_two_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'three',
                labelEn: 'Three',
                labelAr: 'ثلاثة',
                icon: Icons.looks_3_rounded,
                accentColor: Color(0xFF10B981),
              ),
            ],
            categoryId: 'numbers',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_number_two',
            promptEn: 'Where is Number 2?',
            promptAr: 'أين الرقم ٢؟',
            correctChoiceId: 'two',
            choices: [
              QuizChoice(
                id: 'three',
                labelEn: 'Three',
                labelAr: 'ثلاثة',
                icon: Icons.looks_3_rounded,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'two',
                labelEn: 'Two',
                labelAr: 'اثنان',
                icon: Icons.looks_two_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'four',
                labelEn: 'Four',
                labelAr: 'أربعة',
                icon: Icons.looks_4_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
            ],
            categoryId: 'numbers',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_number_three',
            promptEn: 'Where is Number 3?',
            promptAr: 'أين الرقم ٣؟',
            correctChoiceId: 'three',
            choices: [
              QuizChoice(
                id: 'one',
                labelEn: 'One',
                labelAr: 'واحد',
                icon: Icons.looks_one_rounded,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'five',
                labelEn: 'Five',
                labelAr: 'خمسة',
                icon: Icons.looks_5_rounded,
                accentColor: Color(0xFFEF4444),
              ),
              QuizChoice(
                id: 'three',
                labelEn: 'Three',
                labelAr: 'ثلاثة',
                icon: Icons.looks_3_rounded,
                accentColor: Color(0xFF10B981),
              ),
            ],
            categoryId: 'numbers',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_number_four',
            promptEn: 'Where is Number 4?',
            promptAr: 'أين الرقم ٤؟',
            correctChoiceId: 'four',
            choices: [
              QuizChoice(
                id: 'four',
                labelEn: 'Four',
                labelAr: 'أربعة',
                icon: Icons.looks_4_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
              QuizChoice(
                id: 'two',
                labelEn: 'Two',
                labelAr: 'اثنان',
                icon: Icons.looks_two_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'five',
                labelEn: 'Five',
                labelAr: 'خمسة',
                icon: Icons.looks_5_rounded,
                accentColor: Color(0xFFEF4444),
              ),
            ],
            categoryId: 'numbers',
            difficultyLevel: 2,
          ),
          QuizQuestionModel(
            id: 'quiz_number_five',
            promptEn: 'Where is Number 5?',
            promptAr: 'أين الرقم ٥؟',
            correctChoiceId: 'five',
            choices: [
              QuizChoice(
                id: 'two',
                labelEn: 'Two',
                labelAr: 'اثنان',
                icon: Icons.looks_two_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'four',
                labelEn: 'Four',
                labelAr: 'أربعة',
                icon: Icons.looks_4_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
              QuizChoice(
                id: 'five',
                labelEn: 'Five',
                labelAr: 'خمسة',
                icon: Icons.looks_5_rounded,
                accentColor: Color(0xFFEF4444),
              ),
            ],
            categoryId: 'numbers',
            difficultyLevel: 3,
          ),
        ];
        break;

      case 'letters':
        questions = const [
          QuizQuestionModel(
            id: 'quiz_letter_alif',
            promptEn: 'Where is Letter A?',
            promptAr: 'أين حرف الألف؟',
            correctChoiceId: 'alif',
            choices: [
              QuizChoice(
                id: 'alif',
                labelEn: 'Letter A',
                labelAr: 'ألف',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
              QuizChoice(
                id: 'baa',
                labelEn: 'Letter B',
                labelAr: 'باء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'taa',
                labelEn: 'Letter T',
                labelAr: 'تاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFFEF4444),
              ),
            ],
            categoryId: 'letters',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_letter_baa',
            promptEn: 'Where is Letter B?',
            promptAr: 'أين حرف الباء؟',
            correctChoiceId: 'baa',
            choices: [
              QuizChoice(
                id: 'thaa',
                labelEn: 'Letter Th',
                labelAr: 'ثاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'baa',
                labelEn: 'Letter B',
                labelAr: 'باء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'alif',
                labelEn: 'Letter A',
                labelAr: 'ألف',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
            ],
            categoryId: 'letters',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_letter_taa',
            promptEn: 'Where is Letter T?',
            promptAr: 'أين حرف التاء؟',
            correctChoiceId: 'taa',
            choices: [
              QuizChoice(
                id: 'taa',
                labelEn: 'Letter T',
                labelAr: 'تاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFFEF4444),
              ),
              QuizChoice(
                id: 'jeem',
                labelEn: 'Letter J',
                labelAr: 'جيم',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
              QuizChoice(
                id: 'baa',
                labelEn: 'Letter B',
                labelAr: 'باء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF0288D1),
              ),
            ],
            categoryId: 'letters',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_letter_thaa',
            promptEn: 'Where is Letter Th?',
            promptAr: 'أين حرف الثاء؟',
            correctChoiceId: 'thaa',
            choices: [
              QuizChoice(
                id: 'alif',
                labelEn: 'Letter A',
                labelAr: 'ألف',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF8E24AA),
              ),
              QuizChoice(
                id: 'thaa',
                labelEn: 'Letter Th',
                labelAr: 'ثاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'taa',
                labelEn: 'Letter T',
                labelAr: 'تاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFFEF4444),
              ),
            ],
            categoryId: 'letters',
            difficultyLevel: 2,
          ),
          QuizQuestionModel(
            id: 'quiz_letter_jeem',
            promptEn: 'Where is Letter J?',
            promptAr: 'أين حرف الجيم؟',
            correctChoiceId: 'jeem',
            choices: [
              QuizChoice(
                id: 'baa',
                labelEn: 'Letter B',
                labelAr: 'باء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'thaa',
                labelEn: 'Letter Th',
                labelAr: 'ثاء',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'jeem',
                labelEn: 'Letter J',
                labelAr: 'جيم',
                icon: Icons.text_fields_rounded,
                accentColor: Color(0xFFF59E0B),
              ),
            ],
            categoryId: 'letters',
            difficultyLevel: 3,
          ),
        ];
        break;

      case 'animals':
      default:
        questions = const [
          QuizQuestionModel(
            id: 'quiz_animal_dog',
            promptEn: 'Where is the dog?',
            promptAr: 'أين الكلب؟',
            correctChoiceId: 'dog',
            choices: [
              QuizChoice(
                id: 'dog',
                labelEn: 'Dog',
                labelAr: 'كلب',
                icon: Icons.pets,
                accentColor: Color(0xFF22C55E),
              ),
              QuizChoice(
                id: 'cat',
                labelEn: 'Cat',
                labelAr: 'قطة',
                icon: Icons.cruelty_free,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'fish',
                labelEn: 'Fish',
                labelAr: 'سمكة',
                icon: Icons.set_meal,
                accentColor: Color(0xFFA855F7),
              ),
            ],
            categoryId: 'animals',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_animal_cat',
            promptEn: 'Where is the cat?',
            promptAr: 'أين القطة؟',
            correctChoiceId: 'cat',
            choices: [
              QuizChoice(
                id: 'cat',
                labelEn: 'Cat',
                labelAr: 'قطة',
                icon: Icons.cruelty_free,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'dog',
                labelEn: 'Dog',
                labelAr: 'كلب',
                icon: Icons.pets,
                accentColor: Color(0xFF22C55E),
              ),
              QuizChoice(
                id: 'bird',
                labelEn: 'Bird',
                labelAr: 'عصفور',
                icon: Icons.flutter_dash,
                accentColor: Color(0xFF0288D1),
              ),
            ],
            categoryId: 'animals',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_animal_bird',
            promptEn: 'Where is the bird?',
            promptAr: 'أين العصفور؟',
            correctChoiceId: 'bird',
            choices: [
              QuizChoice(
                id: 'fish',
                labelEn: 'Fish',
                labelAr: 'سمكة',
                icon: Icons.set_meal,
                accentColor: Color(0xFFA855F7),
              ),
              QuizChoice(
                id: 'bird',
                labelEn: 'Bird',
                labelAr: 'عصفور',
                icon: Icons.flutter_dash,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'lion',
                labelEn: 'Lion',
                labelAr: 'أسد',
                icon: Icons.shield,
                accentColor: Color(0xFFF59E0B),
              ),
            ],
            categoryId: 'animals',
            difficultyLevel: 1,
          ),
          QuizQuestionModel(
            id: 'quiz_animal_cow',
            promptEn: 'Where is the cow?',
            promptAr: 'أين البقرة؟',
            correctChoiceId: 'cow',
            choices: [
              QuizChoice(
                id: 'cow',
                labelEn: 'Cow',
                labelAr: 'بقرة',
                icon: Icons.agriculture,
                accentColor: Color(0xFF10B981),
              ),
              QuizChoice(
                id: 'cat',
                labelEn: 'Cat',
                labelAr: 'قطة',
                icon: Icons.cruelty_free,
                accentColor: Color(0xFF3B82F6),
              ),
              QuizChoice(
                id: 'dog',
                labelEn: 'Dog',
                labelAr: 'كلب',
                icon: Icons.pets,
                accentColor: Color(0xFF22C55E),
              ),
            ],
            categoryId: 'animals',
            difficultyLevel: 2,
          ),
          QuizQuestionModel(
            id: 'quiz_animal_lion',
            promptEn: 'Where is the lion?',
            promptAr: 'أين الأسد؟',
            correctChoiceId: 'lion',
            choices: [
              QuizChoice(
                id: 'dog',
                labelEn: 'Dog',
                labelAr: 'كلب',
                icon: Icons.pets,
                accentColor: Color(0xFF22C55E),
              ),
              QuizChoice(
                id: 'bird',
                labelEn: 'Bird',
                labelAr: 'عصفور',
                icon: Icons.flutter_dash,
                accentColor: Color(0xFF0288D1),
              ),
              QuizChoice(
                id: 'lion',
                labelEn: 'Lion',
                labelAr: 'أسد',
                icon: Icons.shield,
                accentColor: Color(0xFFF59E0B),
              ),
            ],
            categoryId: 'animals',
            difficultyLevel: 2,
          ),
        ];
        break;
    }

    return questions.take(count).toList();
  }

  static StudentProgressModel getSampleProgress() {
    return const StudentProgressModel(
      studentName: 'Adam',
      studentAge: 5,
      interestBadgeEn: 'Loves Animals!',
      interestBadgeAr: 'يحب الحيوانات!',
      totalSessions: 24,
      overallAccuracy: 78,
      categoryAccuracies: [
        CategoryAccuracy(
          categoryEn: 'Letters',
          categoryAr: 'الحروف',
          accuracy: 88,
          color: Color(0xFF9C27B0),
          icon: Icons.sort_by_alpha,
        ),
        CategoryAccuracy(
          categoryEn: 'Numbers',
          categoryAr: 'الأرقام',
          accuracy: 68,
          color: Color(0xFF2196F3),
          icon: Icons.format_list_numbered,
        ),
        CategoryAccuracy(
          categoryEn: 'Colors',
          categoryAr: 'الألوان',
          accuracy: 72,
          color: Color(0xFFFFB300),
          icon: Icons.palette,
        ),
        CategoryAccuracy(
          categoryEn: 'Animals',
          categoryAr: 'الحيوانات',
          accuracy: 85,
          color: Color(0xFF4CAF50),
          icon: Icons.pets,
        ),
      ],
      recentSessions: [
        SessionRecord(
          id: 's1',
          date: 'May 31, 2025 • 10:30 AM',
          categoryEn: 'Animals',
          categoryAr: 'الحيوانات',
          score: '17 / 20',
          accuracyPercentage: 85,
          categoryIcon: Icons.pets,
          categoryColor: Color(0xFF4CAF50),
        ),
        SessionRecord(
          id: 's2',
          date: 'May 28, 2025 • 4:15 PM',
          categoryEn: 'Colors',
          categoryAr: 'الألوان',
          score: '13 / 20',
          accuracyPercentage: 65,
          categoryIcon: Icons.palette,
          categoryColor: Color(0xFFFFB300),
        ),
        SessionRecord(
          id: 's3',
          date: 'May 25, 2025 • 9:00 AM',
          categoryEn: 'Numbers',
          categoryAr: 'الأرقام',
          score: '14 / 20',
          accuracyPercentage: 70,
          categoryIcon: Icons.format_list_numbered,
          categoryColor: Color(0xFF2196F3),
        ),
        SessionRecord(
          id: 's4',
          date: 'May 22, 2025 • 3:45 PM',
          categoryEn: 'Letters',
          categoryAr: 'الحروف',
          score: '18 / 20',
          accuracyPercentage: 90,
          categoryIcon: Icons.sort_by_alpha,
          categoryColor: Color(0xFF9C27B0),
        ),
      ],
    );
  }

  static String getImagePathForId(String id) {
    final lower = id.toLowerCase();
    switch (lower) {
      // Animals
      case 'cat': return 'assets/images/cat.jpg';
      case 'dog': return 'assets/images/dog.jpg';
      case 'rabbit': return 'assets/images/rabbit.jpg';
      case 'bird': return 'assets/images/bird.jpg';
      case 'cow': return 'assets/images/cow.jpg';
      case 'lion': return 'assets/images/lion.jpg';
      case 'elephant': return 'assets/images/elephant.jpg';
      case 'fish': return 'assets/images/fish.jpg';

      // Colors
      case 'red': return 'assets/images/color_red.jpg';
      case 'blue': return 'assets/images/color_blue.jpg';
      case 'green': return 'assets/images/color_green.jpg';
      case 'yellow': return 'assets/images/color_yellow.jpg';
      case 'orange': return 'assets/images/color_orange.jpg';
      case 'purple': return 'assets/images/color_purple.jpg';

      // Numbers
      case 'one': return 'assets/images/num_1.jpg';
      case 'two': return 'assets/images/num_2.jpg';
      case 'three': return 'assets/images/num_3.jpg';
      case 'four': return 'assets/images/num_4.jpg';
      case 'five': return 'assets/images/num_5.jpg';
      case 'six': return 'assets/images/num_6.jpg';
      case 'seven': return 'assets/images/num_7.jpg';
      case 'eight': return 'assets/images/num_8.jpg';
      case 'nine': return 'assets/images/num_9.jpg';
      case 'ten': return 'assets/images/num_10.jpg';

      // Letters (Real-world associative objects)
      case 'alif': return 'assets/images/letter_alif.jpg';
      case 'baa': return 'assets/images/letter_baa.jpg';
      case 'taa': return 'assets/images/letter_taa.jpg';
      case 'thaa': return 'assets/images/letter_thaa.jpg';
      case 'jeem': return 'assets/images/letter_jeem.jpg';
      case 'haa': return 'assets/images/letter_haa.jpg';
      case 'khaa': return 'assets/images/letter_khaa.jpg';
      case 'daal': return 'assets/images/letter_daal.jpg';
      case 'thaal': return 'assets/images/letter_thaal.jpg';
      case 'raa': return 'assets/images/letter_raa.jpg';
      case 'zaay': return 'assets/images/letter_zaay.jpg';
      case 'seen': return 'assets/images/letter_seen.jpg';
      case 'sheen': return 'assets/images/letter_sheen.jpg';
      case 'saad': return 'assets/images/letter_saad.jpg';
      case 'daad': return 'assets/images/letter_daad.jpg';
      case 'ttaa': return 'assets/images/letter_ttaa.jpg';
      case 'zhaa': return 'assets/images/letter_zhaa.jpg';
      case 'ayn': return 'assets/images/letter_ayn.jpg';
      case 'ghayn': return 'assets/images/letter_ghayn.jpg';
      case 'faa': return 'assets/images/letter_faa.jpg';
      case 'qaaf': return 'assets/images/letter_qaaf.jpg';
      case 'kaaf': return 'assets/images/letter_kaaf.jpg';
      case 'laam': return 'assets/images/letter_laam.jpg';
      case 'meem': return 'assets/images/letter_meem.jpg';
      case 'noon': return 'assets/images/letter_noon.jpg';
      case 'hhaa': return 'assets/images/letter_hhaa.jpg';
      case 'waaw': return 'assets/images/letter_waaw.jpg';
      case 'yaa': return 'assets/images/letter_yaa.jpg';

      // Category Banners
      case 'animals': return 'assets/images/cat_animals.jpg';
      case 'colours':
      case 'colors': return 'assets/images/cat_colors.jpg';
      case 'numbers': return 'assets/images/cat_numbers.jpg';
      case 'letters': return 'assets/images/cat_letters.jpg';

      default: return '';
    }
  }
}
