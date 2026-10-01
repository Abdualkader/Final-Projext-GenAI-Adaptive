import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Central bilingual localization dictionary for English (LTR) and Arabic (RTL).
/// Prevents screen duplication while maintaining strict type-safety and accessibility.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Screen (Child)
      'app_title': 'ASD Learning Assistant',
      'greeting_child': 'Hello, Adam! 👋',
      'greeting_subtitle': "Let's learn and have fun!",
      'home_prompt': 'What would you like to learn today?',
      
      // Categories
      'category_animals': 'Animals',
      'category_colours': 'Colours',
      'category_numbers': 'Numbers',
      'category_letters': 'Letters',
      'category_all': 'All Categories',
      'category_selection_title': 'Choose a Category',

      // Vocabulary Learning Screen
      'learning_title': 'Vocabulary Learning',
      'word_cat_en': 'Cat',
      'word_cat_ar': 'قِطَّة',
      'word_dog_en': 'Dog',
      'word_dog_ar': 'كَلْب',
      'word_fish_en': 'Fish',
      'word_fish_ar': 'سَمَكَة',
      'word_apple_en': 'Apple',
      'word_apple_ar': 'تُفَّاحَة',
      'btn_listen': 'Listen Audio',
      'btn_previous': 'Previous',
      'btn_next': 'Next',
      'progress_label': '{0} / {1}',

      // Interactive Quiz Screen
      'quiz_title': 'Interactive Quiz',
      'quiz_question_dog': 'Where is the dog?',
      'quiz_question_cat': 'Where is the cat?',
      'quiz_question_fish': 'Where is the fish?',
      'feedback_great_job': 'Great job!',
      'feedback_you_can_do_it': 'You can do it!',
      'feedback_excellent': 'Excellent!',
      'feedback_found_item': 'You found the dog!',
      'feedback_try_again': 'Let us try one more time!',
      'points_counter': 'Stars',

      // Parent & Educator Portal
      'parent_portal': 'Parent & Educator Portal',
      'parent_login': 'Sign In',
      'email': 'Email Address',
      'password': 'Password',
      'login_btn': 'Enter Portal',
      'guest_child_btn': 'Continue as Child (No Login Required)',
      'child_selection_title': 'Select Student Profile',
      'child_age': 'Age: {0} years',
      'child_interest': 'Loves Animals!',
      'dashboard_title': 'Progress Dashboard',
      'dashboard_subtitle': 'Monitor learning and growth',
      'export_data': 'Export',
      'total_sessions': 'Total Sessions',
      'total_sessions_desc': 'Across all time',
      'overall_accuracy': 'Overall Accuracy',
      'great_job_stat': 'Great job!',
      'quiz_accuracy_by_category': 'Quiz Accuracy by Category',
      'bar_chart': 'Bar Chart',
      'recent_sessions': 'Recent Sessions',
      'view_all_sessions': 'View All Sessions',
      'date_range': 'Date Range',

      // Settings & Preferences
      'settings_title': 'Settings & Accessibility',
      'language': 'Language / اللغة',
      'lang_en': 'English',
      'lang_ar': 'العربية (Arabic)',
      'calm_mode': 'Calm Sensory Mode',
      'calm_mode_desc': 'Reduces visual motions and loud sound effects',
      'sound_effects': 'Pronunciation Audio',
      'developer_backend': 'Developer: Backend Verification (Week 2)',

      // Bottom Navigation
      'nav_home': 'Home',
      'nav_games': 'Games',
      'nav_progress': 'Progress',
      'nav_profile': 'Profile',
      'nav_settings': 'Settings',
      'nav_activities': 'Activities',
    },
    'ar': {
      // Home Screen (Child)
      'app_title': 'المساعد التعليمي التكيفي',
      'greeting_child': 'أهلاً يا آدم! 👋',
      'greeting_subtitle': 'هيا نتعلم ونمرح معاً!',
      'home_prompt': 'ماذا تود أن تتعلم اليوم؟',

      // Categories
      'category_animals': 'الحيوانات',
      'category_colours': 'الألوان',
      'category_numbers': 'الأرقام',
      'category_letters': 'الحروف',
      'category_all': 'جميع الأقسام',
      'category_selection_title': 'اختر قسماً للتعلم',

      // Vocabulary Learning Screen
      'learning_title': 'تعلم المفردات',
      'word_cat_en': 'Cat',
      'word_cat_ar': 'قِطَّة',
      'word_dog_en': 'Dog',
      'word_dog_ar': 'كَلْب',
      'word_fish_en': 'Fish',
      'word_fish_ar': 'سَمَكَة',
      'word_apple_en': 'Apple',
      'word_apple_ar': 'تُفَّاحَة',
      'btn_listen': 'استمع للنطق',
      'btn_previous': 'السابق',
      'btn_next': 'التالي',
      'progress_label': '{0} / {1}',

      // Interactive Quiz Screen
      'quiz_title': 'الاختبار التفاعلي',
      'quiz_question_dog': 'أين الكلب؟',
      'quiz_question_cat': 'أين القطة؟',
      'quiz_question_fish': 'أين السمكة؟',
      'feedback_great_job': 'عمل رائع!',
      'feedback_you_can_do_it': 'أنت قادر على فعلها!',
      'feedback_excellent': 'ممتاز جداً!',
      'feedback_found_item': 'لقد وجدت الكلب بنجاح!',
      'feedback_try_again': 'هيا نجرب مرة أخرى بهدوء!',
      'points_counter': 'النجوم',

      // Parent & Educator Portal
      'parent_portal': 'بوابة الوالدين والمعلمين',
      'parent_login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login_btn': 'دخول البوابة',
      'guest_child_btn': 'المتابعة كطفل (دون تسجيل دخول)',
      'child_selection_title': 'اختيار ملف الطفل',
      'child_age': 'العمر: {0} سنوات',
      'child_interest': 'يحب الحيوانات!',
      'dashboard_title': 'لوحة متابعة التقدم',
      'dashboard_subtitle': 'متابعة التطور والتعلم بهدوء',
      'export_data': 'تصدير',
      'total_sessions': 'إجمالي الجلسات',
      'total_sessions_desc': 'على مدار التعلم',
      'overall_accuracy': 'الدقة الإجمالية',
      'great_job_stat': 'مستوى متميز!',
      'quiz_accuracy_by_category': 'دقة الاختبارات حسب القسم',
      'bar_chart': 'مخطط بياني',
      'recent_sessions': 'الجلسات الأخيرة',
      'view_all_sessions': 'عرض كافة الجلسات',
      'date_range': 'النطاق الزمني',

      // Settings & Preferences
      'settings_title': 'الإعدادات وملاءمة الحواس',
      'language': 'Language / اللغة',
      'lang_en': 'English (الإنجليزية)',
      'lang_ar': 'العربية',
      'calm_mode': 'الوضع الحسي الهادئ',
      'calm_mode_desc': 'تقليل الحركات والمؤثرات البصرية المفاجئة',
      'sound_effects': 'الصوت والنطق الصوتي',
      'developer_backend': 'المطور: فحص الاتصال بالخادم (Week 2)',

      // Bottom Navigation
      'nav_home': 'الرئيسية',
      'nav_games': 'الألعاب',
      'nav_progress': 'التقدم',
      'nav_profile': 'الملف',
      'nav_settings': 'الإعدادات',
      'nav_activities': 'الأنشطة',
    },
  };

  String text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
