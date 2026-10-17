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
      'btn_listen': 'Play Audio',
      'btn_previous': 'Previous',
      'btn_next': 'Next',
      'btn_complete_session': 'Complete Session 🌟',
      'session_completed_title': 'Session Complete! 🌟',
      'session_completed_subtitle': 'You learned all words in this category!',
      'btn_start_quiz': 'Start Quiz 🎯',
      'btn_return_home': 'Return Home 🏠',
      'inactivity_reminder': "Let's listen again! 🔊",
      'item_indicator': 'Item {0} of {1}',
      'words_learned': '{0} words learned!',
      'progress_label': '{0} / {1}',

      // Interactive Quiz Screen
      'quiz_title': 'Interactive Quiz',
      'quiz_question_dog': 'Where is the dog?',
      'quiz_question_cat': 'Where is the cat?',
      'quiz_question_fish': 'Where is the fish?',
      'quiz_question_red': 'Which one is Red?',
      'quiz_question_one': 'Where is Number 1?',
      'quiz_question_letter_a': 'Where is Letter A?',
      'feedback_great_job': 'Great job!',
      'feedback_you_can_do_it': 'You can do it!',
      'feedback_excellent': 'Excellent!',
      'feedback_found_item': 'You found the dog!',
      'feedback_correct_title': 'Great job! 🌟',
      'feedback_correct_subtitle': 'You got it right! Keep going!',
      'feedback_gentle_retry_title': "Good effort! 🌱",
      'feedback_gentle_retry_subtitle': "Let's try another one together!",
      'points_counter': 'Stars',
      'quiz_progress': 'Question {0} of {1}',
      'quiz_timer_seconds': '{0}s',
      'quiz_timeout_title': "Time's up! Let's keep going 🌱",
      'quiz_timeout_subtitle': 'Moving peacefully to the next question!',
      'quiz_completed_title': 'Quiz Complete! 🌟',
      'quiz_completed_subtitle': 'Amazing effort! You finished the quiz!',
      'quiz_score_summary': 'You got {0} out of {1} right!',
      'btn_play_again': 'Play Again 🔄',
      'btn_next_question': 'Next Question ➡️',
      'btn_finish_quiz': 'Finish Quiz 🏁',

      // Parent & Educator Portal (Login & Validation)
      'parent_portal': 'Parent & Educator Portal',
      'parent_login': 'Sign In',
      'email': 'Email Address',
      'password': 'Password',
      'login_btn': 'Enter Portal',
      'guest_child_btn': 'Continue as Child (No Login Required)',
      'email_required': 'Please enter your email address',
      'password_required': 'Please enter your password',
      'invalid_email': 'Please enter a valid email format',
      'login_success': 'Signed in successfully as Educator/Parent',

      // Child Selection
      'child_selection_title': 'Select Student Profile',
      'child_age': 'Age: {0} years',
      'child_interest': 'Loves Animals!',
      'select_profile_prompt': 'Choose a profile to monitor growth',

      // Progress Dashboard (Week 4 Extended)
      'dashboard_title': 'Progress Dashboard',
      'dashboard_subtitle': 'Monitor learning and growth',
      'export_data': 'Export',
      'total_sessions': 'Total Sessions',
      'total_sessions_desc': 'Across all time',
      'overall_accuracy': 'Overall Accuracy',
      'great_job_stat': 'Great job!',
      'mastered_vocabulary': 'Mastered Words',
      'mastered_desc': 'Consistent retention',
      'session_frequency': 'Weekly Frequency',
      'session_frequency_desc': '4 sessions / week',
      'quiz_accuracy_by_category': 'Quiz Accuracy by Category',
      'bar_chart': 'Bar Chart',
      'recent_sessions': 'Recent Sessions',
      'view_all_sessions': 'View All Sessions',
      'date_range': 'Date Range',
      'empty_progress_title': 'No learning activity yet.',
      'empty_progress_desc': 'Start a learning session to see progress.',
      'btn_start_learning': 'Start Learning Session',
      'filter_all_time': 'All Time',
      'filter_today': 'Today',
      'filter_this_week': 'This Week',
      'filter_this_month': 'This Month',
      'filter_date_label': 'Date Period',
      'filter_category_label': 'Category Filter',
      'unauthorized_child_access': 'You are not authorized to view progress for this child profile.',
      'mastered_items_dialog_title': 'Mastered Vocabulary Items',
      'no_mastered_items': 'No words mastered yet. Practice quizzes to master vocabulary!',

      // Settings & Preferences (Week 4 Extended)
      'settings_title': 'Settings & Accessibility',
      'language': 'Language / اللغة',
      'lang_en': 'English',
      'lang_ar': 'العربية (Arabic)',
      'calm_mode': 'Calm Sensory Mode',
      'calm_mode_desc': 'Reduces visual motions and high contrasts',
      'sound_effects': 'Pronunciation Audio',
      'volume_control': 'Volume Control',
      'session_duration': 'Session Duration',
      'duration_10_min': '10 mins',
      'duration_15_min': '15 mins',
      'duration_20_min': '20 mins',
      'duration_10': '10 Min',
      'duration_15': '15 Min',
      'duration_20': '20 Min',
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
      'btn_listen': 'استمع للنطق',
      'btn_previous': 'السابق',
      'btn_next': 'التالي',
      'btn_complete_session': 'إنهاء الجلسة 🌟',
      'session_completed_title': 'اكتملت الجلسة بنجاح! 🌟',
      'session_completed_subtitle': 'أحسنت يا بطل! لقد أتممت تعلم جميع الكلمات!',
      'btn_start_quiz': 'ابدأ الاختبار 🎯',
      'btn_return_home': 'العودة للرئيسية 🏠',
      'inactivity_reminder': 'هيا نستمع للنطق مرة أخرى! 🔊',
      'item_indicator': 'المفردة {0} من {1}',
      'words_learned': '{0} كلمات تم تعلمها!',
      'progress_label': '{0} / {1}',

      // Interactive Quiz Screen
      'quiz_title': 'الاختبار التفاعلي',
      'quiz_question_dog': 'أين الكلب؟',
      'quiz_question_cat': 'أين القطة؟',
      'quiz_question_fish': 'أين السمكة؟',
      'quiz_question_red': 'أين اللون الأحمر؟',
      'quiz_question_one': 'أين الرقم ١؟',
      'quiz_question_letter_a': 'أين حرف الألف؟',
      'feedback_great_job': 'عمل رائع!',
      'feedback_you_can_do_it': 'أنت قادر على فعلها!',
      'feedback_excellent': 'ممتاز جداً!',
      'feedback_found_item': 'لقد وجدت الكلب بنجاح!',
      'feedback_correct_title': 'ممتاز جداً! 🌟',
      'feedback_correct_subtitle': 'إجابة صحيحة ورائعة! أحسنت يا بطل!',
      'feedback_gentle_retry_title': 'محاولة جميلة! هيا نجرب معاً! 🌱',
      'feedback_gentle_retry_subtitle': 'انظر بهدوء للصورة، أنت قادر على معرفتها!',
      'points_counter': 'النجوم',
      'quiz_progress': 'السؤال {0} من {1}',
      'quiz_timer_seconds': '{0} ث',
      'quiz_timeout_title': 'انتهى الوقت! هيا نتابع بهدوء 🌱',
      'quiz_timeout_subtitle': 'ننتقل بلطف إلى السؤال التالي!',
      'quiz_completed_title': 'اكتمل الاختبار بنجاح! 🌟',
      'quiz_completed_subtitle': 'عمل رائع جداً! لقد أكملت الاختبار يا بطل!',
      'quiz_score_summary': 'أجبت عن {0} من {1} بشكل صحيح!',
      'btn_play_again': 'إعادة اللعب 🔄',
      'btn_next_question': 'السؤال التالي ➡️',
      'btn_finish_quiz': 'إنهاء الاختبار 🏁',

      // Parent & Educator Portal (Login & Validation)
      'parent_portal': 'بوابة الوالدين والمعلمين',
      'parent_login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login_btn': 'دخول البوابة',
      'guest_child_btn': 'المتابعة كطفل (دون تسجيل دخول)',
      'email_required': 'يرجى إدخال البريد الإلكتروني',
      'password_required': 'يرجى إدخال كلمة المرور',
      'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
      'login_success': 'تم تسجيل الدخول بنجاح كمعلم/ولي أمر',

      // Child Selection
      'child_selection_title': 'اختيار ملف الطفل',
      'child_age': 'العمر: {0} سنوات',
      'child_interest': 'يحب الحيوانات!',
      'select_profile_prompt': 'اختر ملف الطالب لمتابعة التقدم',

      // Progress Dashboard (Week 4 Extended)
      'dashboard_title': 'لوحة متابعة التقدم',
      'dashboard_subtitle': 'متابعة التطور والتعلم بهدوء',
      'export_data': 'تصدير',
      'total_sessions': 'إجمالي الجلسات',
      'total_sessions_desc': 'على مدار التعلم',
      'overall_accuracy': 'الدقة الإجمالية',
      'great_job_stat': 'مستوى متميز!',
      'mastered_vocabulary': 'الكلمات المتقنة',
      'mastered_desc': 'حفظ متقن وثابت',
      'session_frequency': 'المعدل الأسبوعي',
      'session_frequency_desc': '٤ جلسات / أسبوع',
      'quiz_accuracy_by_category': 'دقة الاختبارات حسب القسم',
      'bar_chart': 'مخطط بياني',
      'recent_sessions': 'الجلسات الأخيرة',
      'view_all_sessions': 'عرض كافة الجلسات',
      'date_range': 'النطاق الزمني',
      'empty_progress_title': 'لا يوجد نشاط تعليمي بعد.',
      'empty_progress_desc': 'ابدأ جلسة تعليمية لرؤية التقدم.',
      'btn_start_learning': 'بدء جلسة تعليمية',
      'filter_all_time': 'كل الأوقات',
      'filter_today': 'اليوم',
      'filter_this_week': 'هذا الأسبوع',
      'filter_this_month': 'هذا الشهر',
      'filter_date_label': 'الفترة الزمنية',
      'filter_category_label': 'تصفية حسب القسم',
      'unauthorized_child_access': 'غير مصرح لك بالاطلاع على تقرير هذا الطفل.',
      'mastered_items_dialog_title': 'المفردات المتقنة',
      'no_mastered_items': 'لم يتم إتقان كلمات بعد. استمر في التدرب والاختبارات لإتقان المفردات!',

      // Settings & Preferences (Week 4 Extended)
      'settings_title': 'الإعدادات وملاءمة الحواس',
      'language': 'Language / اللغة',
      'lang_en': 'English (الإنجليزية)',
      'lang_ar': 'العربية',
      'calm_mode': 'الوضع الحسي الهادئ',
      'calm_mode_desc': 'تقليل الحركات والمؤثرات البصرية المفاجئة',
      'sound_effects': 'الصوت والنطق الصوتي',
      'volume_control': 'مستوى الصوت',
      'session_duration': 'مدة الجلسة اليومية',
      'duration_10_min': '١٠ دقائق',
      'duration_15_min': '١٥ دقيقة',
      'duration_20_min': '٢٠ دقيقة',
      'duration_10': '١٠ دقائق',
      'duration_15': '١٥ دقيقة',
      'duration_20': '٢٠ دقيقة',
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

  String textWithArgs(String key, List<String> args) {
    String value = text(key);
    for (int i = 0; i < args.length; i++) {
      value = value.replaceAll('{$i}', args[i]);
    }
    return value;
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
