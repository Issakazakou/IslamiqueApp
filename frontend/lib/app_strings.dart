import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_models.dart';

/// Gère la langue choisie (fr / en / ar) et la mémorise sur le téléphone.
class LanguageController extends ChangeNotifier {
  LanguageController._();
  static final LanguageController instance = LanguageController._();

  static const List<String> supported = ['fr', 'en', 'ar'];
  static const String _prefKey = 'app_language';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  /// À appeler au démarrage (dans main) pour retrouver la langue sauvegardée.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && supported.contains(code)) {
        _locale = Locale(code);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (!supported.contains(code) || code == _locale.languageCode) return;
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }
}

/// Utilisation : context.tr('cle')  ou  context.tr('cle', {'param': 'valeur'})
extension AppTranslate on BuildContext {
  String tr(String key, [Map<String, String>? params]) {
    final code = Localizations.localeOf(this).languageCode;
    var text = _strings[key]?[code] ?? _strings[key]?['fr'] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}

const Map<String, Map<String, String>> _strings = {
  // ---- Général ----
  'language': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة'},
  'back': {'fr': 'Retour', 'en': 'Back', 'ar': 'رجوع'},
  'retry': {'fr': 'Réessayer', 'en': 'Retry', 'ar': 'إعادة المحاولة'},

  // ---- Quiz ----
  'quit_title': {
    'fr': 'Quitter le quiz ?',
    'en': 'Quit the quiz?',
    'ar': 'الخروج من الاختبار؟',
  },
  'quit_msg': {
    'fr': 'Votre progression sur ce quiz sera perdue.',
    'en': 'Your progress on this quiz will be lost.',
    'ar': 'سيتم فقدان تقدمك في هذا الاختبار.',
  },
  'continue': {'fr': 'Continuer', 'en': 'Continue', 'ar': 'متابعة'},
  'quit': {'fr': 'Quitter', 'en': 'Quit', 'ar': 'خروج'},
  'loading': {
    'fr': 'Chargement des questions...',
    'en': 'Loading questions...',
    'ar': 'جارٍ تحميل الأسئلة...',
  },
  'connecting_to': {
    'fr': 'Connexion à {url}',
    'en': 'Connecting to {url}',
    'ar': 'الاتصال بـ {url}',
  },
  'conn_error': {
    'fr': 'Erreur de connexion',
    'en': 'Connection error',
    'ar': 'خطأ في الاتصال',
  },
  'server_settings': {
    'fr': 'Réglages serveur',
    'en': 'Server settings',
    'ar': 'إعدادات الخادم',
  },
  'back_to_levels': {
    'fr': 'Retour aux niveaux',
    'en': 'Back to levels',
    'ar': 'العودة إلى المستويات',
  },
  'no_questions': {
    'fr': 'Aucune question trouvée pour ce niveau.',
    'en': 'No questions found for this level.',
    'ar': 'لم يتم العثور على أسئلة لهذا المستوى.',
  },
  'question_of': {
    'fr': 'Question {current} sur {total}',
    'en': 'Question {current} of {total}',
    'ar': 'السؤال {current} من {total}',
  },
  'great': {
    'fr': 'Excellente réponse !',
    'en': 'Great answer!',
    'ar': 'إجابة ممتازة!',
  },
  'wrong': {
    'fr': 'Mauvaise réponse.',
    'en': 'Wrong answer.',
    'ar': 'إجابة خاطئة.',
  },
  'correct_is': {
    'fr': 'La bonne réponse est : {answer}',
    'en': 'The correct answer is: {answer}',
    'ar': 'الإجابة الصحيحة هي: {answer}',
  },
  'previous': {'fr': 'Précédente', 'en': 'Previous', 'ar': 'السابق'},
  'next': {'fr': 'Suivante', 'en': 'Next', 'ar': 'التالي'},
  'finish': {
    'fr': 'Terminer le quiz',
    'en': 'Finish quiz',
    'ar': 'إنهاء الاختبار',
  },

  // ---- Accueil ----
  'app_title': {
    'fr': 'Quiz Islamique',
    'en': 'Islamic Quiz',
    'ar': 'الاختبار الإسلامي',
  },
  'home_subtitle': {
    'fr': 'Testez et améliorez vos connaissances\nislamiques.',
    'en': 'Test and improve your\nIslamic knowledge.',
    'ar': 'اختبر معلوماتك الإسلامية\nوطوّرها.',
  },
  'home_choose_category': {
    'fr': 'Choisissez une catégorie pour commencer.',
    'en': 'Choose a category to get started.',
    'ar': 'اختر فئة للبدء.',
  },
  'badge_counts': {
    'fr': '300 QUESTIONS • 4 CATÉGORIES',
    'en': '300 QUESTIONS • 4 CATEGORIES',
    'ar': '300 سؤال • 4 فئات',
  },
  'footer': {
    'fr': 'Apprendre avec intention, avancer avec constance',
    'en': 'Learn with intention, move forward with consistency',
    'ar': 'تعلّم بنيّة، وتقدّم بثبات',
  },
  'stat_questions': {'fr': 'Questions', 'en': 'Questions', 'ar': 'أسئلة'},
  'stat_categories': {'fr': 'Catégories', 'en': 'Categories', 'ar': 'فئات'},
  'stat_levels': {'fr': 'Niveaux', 'en': 'Levels', 'ar': 'مستويات'},
  'home_hero_cta': {
    'fr': 'Commencer maintenant',
    'en': 'Get started',
    'ar': 'ابدأ الآن',
  },

  // ---- Catégories ----
  'cat_coran_title': {
    'fr': 'Quiz Coran',
    'en': 'Quran Quiz',
    'ar': 'اختبار القرآن',
  },
  'cat_coran_desc': {
    'fr': 'Testez vos connaissances sur le Coran',
    'en': 'Test your knowledge of the Quran',
    'ar': 'اختبر معلوماتك عن القرآن الكريم',
  },
  'cat_hadith_title': {
    'fr': 'Quiz Hadith',
    'en': 'Hadith Quiz',
    'ar': 'اختبار الحديث',
  },
  'cat_hadith_desc': {
    'fr': 'Découvrez les enseignements des hadiths',
    'en': 'Discover the teachings of the hadiths',
    'ar': 'اكتشف تعاليم الأحاديث النبوية',
  },
  'cat_fiqh_title': {
    'fr': 'Quiz Fiqh',
    'en': 'Fiqh Quiz',
    'ar': 'اختبار الفقه',
  },
  'cat_fiqh_desc': {
    'fr': 'Testez vos connaissances en jurisprudence islamique',
    'en': 'Test your knowledge of Islamic jurisprudence',
    'ar': 'اختبر معلوماتك في الفقه الإسلامي',
  },
  'cat_sira_title': {
    'fr': 'Sira du Prophète ﷺ',
    'en': 'Sira of the Prophet ﷺ',
    'ar': 'سيرة النبي ﷺ',
  },
  'cat_sira_desc': {
    'fr': 'Découvrez la vie du Prophète ﷺ',
    'en': 'Discover the life of the Prophet ﷺ',
    'ar': 'اكتشف حياة النبي ﷺ',
  },

  // ---- Niveaux ----
  'choose_level': {
    'fr': 'Choisissez votre niveau',
    'en': 'Choose your level',
    'ar': 'اختر مستواك',
  },
  'select_difficulty': {
    'fr': 'Sélectionnez une difficulté pour démarrer.',
    'en': 'Select a difficulty to start.',
    'ar': 'اختر مستوى الصعوبة للبدء.',
  },
  'level_debutant_title': {'fr': 'Débutant', 'en': 'Beginner', 'ar': 'مبتدئ'},
  'level_debutant_desc': {
    'fr': 'Les bases pour bien commencer',
    'en': 'The basics to get started',
    'ar': 'الأساسيات لبداية جيدة',
  },
  'level_intermediaire_title': {
    'fr': 'Intermédiaire',
    'en': 'Intermediate',
    'ar': 'متوسط',
  },
  'level_intermediaire_desc': {
    'fr': 'Approfondissez vos connaissances',
    'en': 'Deepen your knowledge',
    'ar': 'عمّق معرفتك',
  },
  'level_avance_title': {'fr': 'Avancé', 'en': 'Advanced', 'ar': 'متقدم'},
  'level_avance_desc': {
    'fr': 'Des questions pour les plus exigeants',
    'en': 'Questions for the most demanding',
    'ar': 'أسئلة لأكثر المتمكنين',
  },

  // ---- Résultat ----
  'result_title': {
    'fr': 'Résultat du Quiz',
    'en': 'Quiz result',
    'ar': 'نتيجة الاختبار',
  },
  'level_label': {
    'fr': 'Niveau {level}',
    'en': 'Level: {level}',
    'ar': 'المستوى: {level}',
  },
  'your_score': {'fr': 'VOTRE SCORE', 'en': 'YOUR SCORE', 'ar': 'نتيجتك'},
  'success_rate': {
    'fr': '{pct} % de réussite',
    'en': '{pct}% success rate',
    'ar': 'نسبة النجاح {pct}%',
  },
  'appr_high': {
    'fr': "Mach'Allah ! Excellent score ! Vos connaissances sont solides.",
    'en': 'Mashallah! Excellent score! Your knowledge is solid.',
    'ar': 'ما شاء الله! نتيجة ممتازة! معرفتك قوية.',
  },
  'appr_mid': {
    'fr': 'Bien joué ! Bel effort, continuez à approfondir vos acquis.',
    'en': 'Well done! Nice effort, keep deepening what you have learned.',
    'ar': 'أحسنت! جهد جميل، واصل تعميق ما تعلمته.',
  },
  'appr_low': {
    'fr': 'Ne vous découragez pas, la persévérance est la clé de la science.',
    'en': 'Do not be discouraged, perseverance is the key to knowledge.',
    'ar': 'لا تيأس، فالمثابرة مفتاح العلم.',
  },
  'view_corrections': {
    'fr': 'Voir les corrections détaillées',
    'en': 'View detailed corrections',
    'ar': 'عرض التصحيح المفصل',
  },
  'restart_quiz': {
    'fr': 'Recommencer ce quiz',
    'en': 'Restart this quiz',
    'ar': 'إعادة هذا الاختبار',
  },
  'back_home': {
    'fr': "Retour à l'accueil",
    'en': 'Back to home',
    'ar': 'العودة إلى الرئيسية',
  },

  // ---- Réglages serveur ----
  'srv_title': {
    'fr': 'Configuration Backend',
    'en': 'Backend settings',
    'ar': 'إعدادات الخادم',
  },
  'srv_address': {
    'fr': 'Adresse du serveur PHP :',
    'en': 'PHP server address:',
    'ar': 'عنوان خادم PHP:',
  },
  'srv_hint': {
    'fr': 'Valeurs recommandées :\n• Émulateur Android : http://10.0.2.2:8000\n• PC / Web : http://127.0.0.1:8000\n• Téléphone physique : http://IP_DU_PC:8000',
    'en': 'Recommended values:\n• Android emulator: http://10.0.2.2:8000\n• PC / Web: http://127.0.0.1:8000\n• Physical phone: http://PC_IP:8000',
    'ar': 'القيم الموصى بها:\n• محاكي أندرويد: http://10.0.2.2:8000\n• الحاسوب / الويب: http://127.0.0.1:8000\n• هاتف حقيقي: http://PC_IP:8000',
  },
  'srv_ok': {
    'fr': 'Connexion réussie au backend PHP !',
    'en': 'Successfully connected to the PHP backend!',
    'ar': 'تم الاتصال بخادم PHP بنجاح!',
  },
  'srv_fail': {
    'fr': 'Impossible de joindre le serveur. Vérifiez que PHP est lancé.',
    'en': 'Cannot reach the server. Check that PHP is running.',
    'ar': 'تعذر الوصول إلى الخادم. تأكد من تشغيل PHP.',
  },
  'srv_saved': {
    'fr': 'Serveur configuré : {url}',
    'en': 'Server configured: {url}',
    'ar': 'تم ضبط الخادم: {url}',
  },
  'test': {'fr': 'Tester', 'en': 'Test', 'ar': 'اختبار'},
  'default': {'fr': 'Défaut', 'en': 'Default', 'ar': 'افتراضي'},
  'cancel': {'fr': 'Annuler', 'en': 'Cancel', 'ar': 'إلغاء'},
  'save': {'fr': 'Enregistrer', 'en': 'Save', 'ar': 'حفظ'},

  // ---- Parcours et Niveaux ----
  'journey_title': {
    'fr': 'Parcours par étapes (Niveaux 1 à 5)',
    'en': 'Stage Journey (Levels 1 to 5)',
    'ar': 'مسار المراحل (المستويات 1 إلى 5)',
  },
  'journey_desc': {
    'fr': 'Progressez étape par étape pour débloquer les 5 niveaux',
    'en': 'Progress stage by stage to unlock all 5 levels',
    'ar': 'تقدّم مرحلة بمرحلة لفتح المستويات الخمسة',
  },
  'quick_quiz': {
    'fr': 'Mode Quiz Rapide',
    'en': 'Quick Quiz Mode',
    'ar': 'نمط الاختبار السريع',
  },
  'quick_quiz_desc': {
    'fr': 'Questions aléatoires sur ce niveau de difficulté',
    'en': 'Random questions on this difficulty level',
    'ar': 'أسئلة عشوائية في هذا المستوى من الصعوبة',
  },
  'stage_label': {
    'fr': 'Étape {number}',
    'en': 'Stage {number}',
    'ar': 'المرحلة {number}',
  },
  'stage_locked_msg': {
    'fr': "Obtenez au moins 1 étoile à l'étape précédente pour débloquer celle-ci !",
    'en': 'Get at least 1 star in the previous stage to unlock this one!',
    'ar': 'احصل على نجمة واحدة على الأقل في المرحلة السابقة لفتح هذه المرحلة!',
  },
  'stage_1_title': {
    'fr': 'Niveau 1 : Fondations',
    'en': 'Level 1: Foundations',
    'ar': 'المستوى 1: الأساسيات',
  },
  'stage_1_desc': {
    'fr': 'Découverte et notions de base',
    'en': 'Discovery and basic concepts',
    'ar': 'اكتشاف ومفاهيم أساسية',
  },
  'stage_2_title': {
    'fr': 'Niveau 2 : Essentiels',
    'en': 'Level 2: Essentials',
    'ar': 'المستوى 2: الضروريات',
  },
  'stage_2_desc': {
    'fr': 'Les connaissances indispensables',
    'en': 'Essential knowledge to know',
    'ar': 'المعارف التي لا غنى عنها',
  },
  'stage_3_title': {
    'fr': 'Niveau 3 : Approfondissement',
    'en': 'Level 3: Deepening',
    'ar': 'المستوى 3: التعمق',
  },
  'stage_3_desc': {
    'fr': 'Consolidation et précision',
    'en': 'Consolidation and precision',
    'ar': 'ترسيخ المعارف والدقة',
  },
  'stage_4_title': {
    'fr': 'Niveau 4 : Maîtrise',
    'en': 'Level 4: Mastery',
    'ar': 'المستوى 4: التمكن',
  },
  'stage_4_desc': {
    'fr': 'Questions détaillées et subtilités',
    'en': 'Detailed and nuanced questions',
    'ar': 'أسئلة تفصيلية ودقيقة',
  },
  'stage_5_title': {
    'fr': 'Niveau 5 : Défi Ultime',
    'en': 'Level 5: Ultimate Challenge',
    'ar': 'المستوى 5: التحدي النهائي',
  },
  'stage_5_desc': {
    'fr': 'Le grand test final pour couronner le niveau',
    'en': 'The ultimate test to crown the level',
    'ar': 'التحدي الأكبر لتتويج هذا المستوى',
  },
  'stars_count': {
    'fr': '{stars} / 15 ⭐',
    'en': '{stars} / 15 ⭐',
    'ar': '{stars} / 15 ⭐',
  },
  'stages_completed': {
    'fr': '{count} / 5 étapes réussies',
    'en': '{count} / 5 stages completed',
    'ar': '{count} / 5 مراحل مكتملة',
  },
  'play_stage': {'fr': 'Jouer', 'en': 'Play', 'ar': 'بدء'},
  'replay': {'fr': 'Rejouer', 'en': 'Replay', 'ar': 'إعادة'},
  'next_stage': {'fr': 'Étape suivante', 'en': 'Next Stage', 'ar': 'المرحلة التالية'},
  'stage_unlocked_congrats': {
    'fr': '🎉 Bravo ! Étape {number} débloquée !',
    'en': '🎉 Well done! Stage {number} unlocked!',
    'ar': '🎉 أحسنت! تم فتح المرحلة {number}!',
  },
  'time_out': {'fr': 'Temps écoulé !', 'en': "Time's up!", 'ar': 'انتهى الوقت!'},
  'game_over': {'fr': 'Session terminée', 'en': 'Session Over', 'ar': 'انتهت الجلسة'},
  'game_over_desc': {
    'fr': 'Vous avez épuisé vos 3 cœurs. Relevez le défi à nouveau !',
    'en': 'You ran out of hearts. Take on the challenge again!',
    'ar': 'نفدت قلوبك الثلاثة. خض التحدي مرة أخرى!',
  },

  // ---- Options du Quiz ----
  'options_title': {'fr': 'Options du Quiz', 'en': 'Quiz Options', 'ar': 'خيارات الاختبار'},
  'opt_timer': {'fr': 'Chronomètre', 'en': 'Timer', 'ar': 'المؤقت'},
  'opt_timer_desc': {
    'fr': '20 secondes par question avec décompte visuel',
    'en': '20 seconds per question with visual countdown',
    'ar': '20 ثانية لكل سؤال مع عد تنازلي مرئي',
  },
  'opt_question_count': {
    'fr': 'Questions par session (Mode Rapide)',
    'en': 'Questions per session (Quick Mode)',
    'ar': 'عدد الأسئلة (النمط السريع)',
  },
  'opt_instant_feedback': {
    'fr': 'Correction directe',
    'en': 'Instant feedback',
    'ar': 'التصحيح المباشر',
  },
  'opt_instant_feedback_desc': {
    'fr': 'Affiche la bonne réponse immédiatement après votre clic',
    'en': 'Displays the correct answer immediately after your choice',
    'ar': 'إظهار الإجابة الصحيحة فور اختيارك',
  },
  'opt_lives': {'fr': 'Mode 3 Vies (Cœurs)', 'en': '3 Lives Mode (Hearts)', 'ar': 'نمط 3 قلوب'},
  'opt_lives_desc': {
    'fr': 'Perdez un cœur à chaque erreur. Défi stimulant !',
    'en': 'Lose a heart on every mistake. Exciting challenge!',
    'ar': 'تفقد قلباً عند كل خطأ. تحدٍ مثير!',
  },
  'options': {'fr': 'Options', 'en': 'Options', 'ar': 'خيارات'},
  'apply': {'fr': 'Valider', 'en': 'Apply', 'ar': 'تطبيق'},

  // ---- Thème ----
  'theme_light': {'fr': 'Mode Clair', 'en': 'Light Mode', 'ar': 'الوضع الفاتح'},
  'theme_dark': {'fr': 'Mode Sombre', 'en': 'Dark Mode', 'ar': 'الوضع الداكن'},
  'theme_system': {'fr': 'Mode Système', 'en': 'System Mode', 'ar': 'وضع النظام'},

  // ---- Corrections ----
  'corrections_title': {'fr': 'Corrections détaillées', 'en': 'Detailed Corrections', 'ar': 'التصحيح المفصل'},
  'correct': {'fr': 'Correct', 'en': 'Correct', 'ar': 'صحيح'},
  'incorrect': {'fr': 'Incorrect', 'en': 'Incorrect', 'ar': 'غير صحيح'},
  'your_answer': {'fr': 'Votre réponse :', 'en': 'Your answer:', 'ar': 'إجابتك:'},
  'no_answer': {'fr': 'Aucune réponse', 'en': 'No answer', 'ar': 'لا توجد إجابة'},
  'correct_answer_label': {'fr': 'Bonne réponse :', 'en': 'Correct answer:', 'ar': 'الإجابة الصحيحة:'},
};

/// Titres et descriptions traduits des catégories et des niveaux.
extension QuizCategoryL10n on QuizCategory {
  String titleOf(BuildContext c) => c.tr('cat_${id}_title');
  String descriptionOf(BuildContext c) => c.tr('cat_${id}_desc');
}

extension QuizLevelL10n on QuizLevel {
  String titleOf(BuildContext c) => c.tr('level_${apiValue}_title');
  String descriptionOf(BuildContext c) => c.tr('level_${apiValue}_desc');
}
