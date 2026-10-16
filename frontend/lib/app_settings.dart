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
    'fr': '360 QUESTIONS • 4 CATÉGORIES',
    'en': '360 QUESTIONS • 4 CATEGORIES',
    'ar': '360 سؤال • 4 فئات',
  },
  'footer': {
    'fr': 'Apprendre avec intention, avancer avec constance',
    'en': 'Learn with intention, move forward with consistency',
    'ar': 'تعلّم بنيّة، وتقدّم بثبات',
  },

  // ---- Catégories ----
  'cat_coran_title': {'fr': 'Coran', 'en': 'Quran', 'ar': 'القرآن'},
  'cat_coran_desc': {
    'fr': 'Méditer, Tajwid et culture coranique',
    'en': 'Reflect, Tajweed and Quranic knowledge',
    'ar': 'التدبر والتجويد والثقافة القرآنية',
  },
  'cat_coran_mediter_title': {'fr': 'Méditer', 'en': 'Reflect', 'ar': 'تدبّر'},
  'cat_coran_mediter_desc': {
    'fr': 'Réfléchir au sens des versets (tadabbur)',
    'en': 'Reflect on the meaning of the verses (tadabbur)',
    'ar': 'التفكّر في معاني الآيات',
  },
  'cat_coran_tajwid_title': {'fr': 'Tajwid', 'en': 'Tajweed', 'ar': 'التجويد'},
  'cat_coran_tajwid_desc': {
    'fr': 'Les règles de la récitation',
    'en': 'The rules of recitation',
    'ar': 'أحكام التلاوة',
  },
  'cat_coran_culture_title': {
    'fr': 'Culture coranique',
    'en': 'Quranic knowledge',
    'ar': 'الثقافة القرآنية',
  },
  'cat_coran_culture_desc': {
    'fr': 'Sourates, versets, prophètes et histoire',
    'en': 'Surahs, verses, prophets and history',
    'ar': 'السور والآيات والأنبياء والتاريخ',
  },
  'group_choose': {
    'fr': 'Choisir un thème',
    'en': 'Choose a topic',
    'ar': 'اختر موضوعًا',
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
