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
  'home_progress': {
    'fr': 'Votre progression',
    'en': 'Your progress',
    'ar': 'تقدّمك',
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


  // ---- Explications, série et défi du jour ----
  'explanation_title': {'fr': 'Explication', 'en': 'Explanation', 'ar': 'الشرح'},
  'source_label': {'fr': 'Source', 'en': 'Source', 'ar': 'المصدر'},
  'daily_title': {'fr': 'Défi du jour', 'en': 'Daily challenge', 'ar': 'تحدي اليوم'},
  'daily_start': {'fr': 'Commencer', 'en': 'Start', 'ar': 'ابدأ'},
  'daily_again': {'fr': 'Rejouer', 'en': 'Play again', 'ar': 'العب مجددًا'},
  'daily_done': {
    'fr': 'Fait aujourd\'hui ✓',
    'en': 'Done today ✓',
    'ar': 'تم اليوم ✓',
  },
  'streak_label': {
    'fr': 'Série : {n} j',
    'en': 'Streak: {n} d',
    'ar': 'السلسلة: {n} يوم',
  },

  // ---- Profil ----
  'profile_title': {'fr': 'Mon profil', 'en': 'My profile', 'ar': 'ملفي الشخصي'},
  'profile_stats': {'fr': 'Statistiques', 'en': 'Statistics', 'ar': 'الإحصائيات'},
  'profile_quizzes': {'fr': 'Quiz terminés', 'en': 'Quizzes completed', 'ar': 'الاختبارات المنجزة'},
  'profile_questions': {'fr': 'Questions répondues', 'en': 'Questions answered', 'ar': 'الأسئلة المجاب عنها'},
  'profile_accuracy': {'fr': 'Précision', 'en': 'Accuracy', 'ar': 'نسبة الصواب'},
  'profile_streak': {'fr': 'Série en cours', 'en': 'Current streak', 'ar': 'السلسلة الحالية'},
  'profile_best_streak': {'fr': 'Meilleure série', 'en': 'Best streak', 'ar': 'أفضل سلسلة'},
  'profile_stars': {'fr': 'Étoiles', 'en': 'Stars', 'ar': 'النجوم'},
  'profile_days': {'fr': '{n} j', 'en': '{n} d', 'ar': '{n} يوم'},
  'profile_badges': {'fr': 'Badges', 'en': 'Badges', 'ar': 'الأوسمة'},
  'profile_no_badges': {
    'fr': 'Aucun badge pour l\'instant : terminez des quiz pour en gagner.',
    'en': 'No badges yet: complete quizzes to earn some.',
    'ar': 'لا توجد أوسمة بعد: أنهِ اختبارات لتكسبها.',
  },
  'profile_certificates': {'fr': 'Certificats', 'en': 'Certificates', 'ar': 'الشهادات'},
  'profile_no_certificates': {
    'fr': 'Aucun certificat pour l\'instant : réussissez toutes les étapes d\'une catégorie.',
    'en': 'No certificates yet: pass every stage of a category.',
    'ar': 'لا توجد شهادات بعد: اجتز جميع مراحل فئة ما.',
  },
  'profile_last_sync': {
    'fr': 'Dernière synchronisation : {time}',
    'en': 'Last sync: {time}',
    'ar': 'آخر مزامنة: {time}',
  },
  'profile_never_synced': {
    'fr': 'Pas encore synchronisé dans cette session.',
    'en': 'Not synced yet in this session.',
    'ar': 'لم تتم المزامنة بعد في هذه الجلسة.',
  },
  'profile_saved_note': {
    'fr': 'Votre progression, vos statistiques et vos certificats sont enregistrés sur votre compte.',
    'en': 'Your progress, statistics and certificates are saved to your account.',
    'ar': 'يتم حفظ تقدمك وإحصائياتك وشهاداتك في حسابك.',
  },
  'profile_edit_name': {'fr': 'Modifier le nom', 'en': 'Edit name', 'ar': 'تعديل الاسم'},
  'profile_name_saved': {'fr': 'Nom mis à jour.', 'en': 'Name updated.', 'ar': 'تم تحديث الاسم.'},
  'cert_code': {
    'fr': 'Code de vérification : {code}',
    'en': 'Verification code: {code}',
    'ar': 'رمز التحقق: {code}',
  },
  'badge_first_quiz': {'fr': 'Premier quiz', 'en': 'First quiz', 'ar': 'أول اختبار'},
  'badge_ten_quizzes': {'fr': '10 quiz', 'en': '10 quizzes', 'ar': '10 اختبارات'},
  'badge_fifty_quizzes': {'fr': '50 quiz', 'en': '50 quizzes', 'ar': '50 اختبارًا'},
  'badge_streak_3': {'fr': 'Série de 3 jours', 'en': '3-day streak', 'ar': 'سلسلة 3 أيام'},
  'badge_streak_7': {'fr': 'Série de 7 jours', 'en': '7-day streak', 'ar': 'سلسلة 7 أيام'},
  'badge_streak_30': {'fr': 'Série de 30 jours', 'en': '30-day streak', 'ar': 'سلسلة 30 يومًا'},
  'badge_ace': {'fr': 'As (80 % de réussite)', 'en': 'Ace (80% correct)', 'ar': 'متفوق (80٪ صحيح)'},
  'badge_master': {'fr': 'Maître (90 % de réussite)', 'en': 'Master (90% correct)', 'ar': 'خبير (90٪ صحيح)'},
  'badge_coran_explorer': {'fr': 'Explorateur du Coran', 'en': 'Quran explorer', 'ar': 'مستكشف القرآن'},

  // ---- Certificats ----
  'app_name': {'fr': 'Quiz Islamique', 'en': 'Islamic Quiz', 'ar': 'الاختبار الإسلامي'},
  'cert_my': {'fr': 'Mes certificats', 'en': 'My certificates', 'ar': 'شهاداتي'},
  'cert_count': {
    'fr': '{n}/{total} obtenus',
    'en': '{n}/{total} earned',
    'ar': 'تم الحصول على {n} من {total}',
  },
  'cert_title': {
    'fr': 'Certificat de réussite',
    'en': 'Certificate of Achievement',
    'ar': 'شهادة إنجاز',
  },
  'cert_awarded_to': {'fr': 'décerné à', 'en': 'awarded to', 'ar': 'تُمنح إلى'},
  'cert_for': {
    'fr': 'pour avoir terminé tous les quiz de',
    'en': 'for completing all the quizzes of',
    'ar': 'لإتمامه جميع اختبارات',
  },
  'cert_stars': {
    'fr': 'Étoiles : {stars}/{max}',
    'en': 'Stars: {stars}/{max}',
    'ar': 'النجوم: {stars}/{max}',
  },
  'cert_date': {
    'fr': 'Délivré le {date}',
    'en': 'Issued on {date}',
    'ar': 'صدرت بتاريخ {date}',
  },
  'cert_progress': {
    'fr': '{done}/{total} étapes réussies',
    'en': '{done}/{total} stages passed',
    'ar': 'تم اجتياز {done} من {total} مرحلة',
  },
  'cert_locked': {
    'fr': 'Réussissez toutes les étapes pour obtenir ce certificat. Il vous en reste {n}.',
    'en': 'Pass every stage to earn this certificate. {n} left.',
    'ar': 'اجتز جميع المراحل للحصول على هذه الشهادة. المتبقي {n}.',
  },
  'cert_earned_banner': {
    'fr': 'Félicitations ! Vous avez obtenu le certificat « {title} ».',
    'en': 'Congratulations! You earned the "{title}" certificate.',
    'ar': 'مبروك! حصلت على شهادة «{title}».',
  },
  'cert_view': {'fr': 'Voir', 'en': 'View', 'ar': 'عرض'},
  'cert_copy': {'fr': 'Copier le texte', 'en': 'Copy text', 'ar': 'نسخ النص'},
  'cert_copied': {'fr': 'Texte copié.', 'en': 'Text copied.', 'ar': 'تم نسخ النص.'},
  'cert_edit_name': {'fr': 'Modifier mon nom', 'en': 'Edit my name', 'ar': 'تعديل اسمي'},
  'cert_name_prompt': {
    'fr': 'Quel nom doit figurer sur le certificat ?',
    'en': 'What name should appear on the certificate?',
    'ar': 'ما الاسم الذي يجب أن يظهر على الشهادة؟',
  },
  'cert_name_hint': {'fr': 'Votre nom complet', 'en': 'Your full name', 'ar': 'اسمك الكامل'},
  'cert_save': {'fr': 'Enregistrer', 'en': 'Save', 'ar': 'حفظ'},

  // ---- Compte utilisateur ----
  'auth_account': {'fr': 'Mon compte', 'en': 'My account', 'ar': 'حسابي'},
  'auth_login': {'fr': 'Se connecter', 'en': 'Log in', 'ar': 'تسجيل الدخول'},
  'auth_register': {'fr': 'Créer un compte', 'en': 'Sign up', 'ar': 'إنشاء حساب'},
  'auth_logout': {'fr': 'Se déconnecter', 'en': 'Log out', 'ar': 'تسجيل الخروج'},
  'auth_name': {'fr': 'Nom', 'en': 'Name', 'ar': 'الاسم'},
  'auth_email': {'fr': 'Adresse e-mail', 'en': 'Email address', 'ar': 'البريد الإلكتروني'},
  'auth_password': {'fr': 'Mot de passe', 'en': 'Password', 'ar': 'كلمة المرور'},
  'auth_intro': {
    'fr': 'Créez un compte pour garder votre progression et la retrouver sur un autre téléphone.',
    'en': 'Create an account to keep your progress and find it on another phone.',
    'ar': 'أنشئ حسابًا للحفاظ على تقدمك واستعادته على هاتف آخر.',
  },
  'auth_skip': {
    'fr': 'Continuer sans compte',
    'en': 'Continue without an account',
    'ar': 'المتابعة بدون حساب',
  },
  'auth_sync_now': {
    'fr': 'Synchroniser maintenant',
    'en': 'Sync now',
    'ar': 'مزامنة الآن',
  },
  'auth_synced': {
    'fr': 'Progression synchronisée.',
    'en': 'Progress synced.',
    'ar': 'تمت مزامنة التقدم.',
  },
  'auth_logout_note': {
    'fr': 'Votre progression reste enregistrée sur votre compte. Elle sera effacée de cet appareil.',
    'en': 'Your progress stays saved on your account. It will be removed from this device.',
    'ar': 'يبقى تقدمك محفوظًا في حسابك وسيتم حذفه من هذا الجهاز.',
  },
  'auth_signed_in_as': {
    'fr': 'Connecté en tant que {name}',
    'en': 'Signed in as {name}',
    'ar': 'تم تسجيل الدخول باسم {name}',
  },
  'auth_err_name': {
    'fr': 'Entrez votre nom.',
    'en': 'Enter your name.',
    'ar': 'أدخل اسمك.',
  },
  'auth_err_email': {
    'fr': 'Adresse e-mail invalide.',
    'en': 'Invalid email address.',
    'ar': 'بريد إلكتروني غير صالح.',
  },
  'auth_err_password': {
    'fr': '8 caractères minimum.',
    'en': 'At least 8 characters.',
    'ar': '8 أحرف على الأقل.',
  },
  'auth_err_network': {
    'fr': 'Impossible de contacter le serveur. Vérifiez votre connexion et l\'adresse du serveur dans les réglages.',
    'en': 'Cannot reach the server. Check your connection and the server address in settings.',
    'ar': 'تعذر الاتصال بالخادم. تحقق من الاتصال وعنوان الخادم في الإعدادات.',
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
    'fr': 'Valeurs recommandées :\n• Production : https://votre-domaine.com\n• Émulateur Android : http://10.0.2.2:8000\n• PC / Web : http://127.0.0.1:8000\n• Téléphone (développement) : http://IP_DU_PC:8000',
    'en': 'Recommended values:\n• Production: https://your-domain.com\n• Android emulator: http://10.0.2.2:8000\n• PC / Web: http://127.0.0.1:8000\n• Phone (development): http://PC_IP:8000',
    'ar': 'القيم الموصى بها:\n• الإنتاج: https://your-domain.com\n• محاكي أندرويد: http://10.0.2.2:8000\n• الحاسوب / الويب: http://127.0.0.1:8000\n• الهاتف (تطوير): http://PC_IP:8000',
  },
  'srv_insecure_warn': {
    'fr': 'Attention : cette adresse utilise HTTP sur Internet, les données ne sont pas chiffrées. Utilisez HTTPS.',
    'en': 'Warning: this address uses HTTP over the Internet, so data is not encrypted. Use HTTPS.',
    'ar': 'تنبيه: هذا العنوان يستخدم HTTP عبر الإنترنت، فالبيانات غير مشفّرة. استخدم HTTPS.',
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
  'stage_locked_label': {'fr': 'Verrouillé', 'en': 'Locked', 'ar': 'مقفل'},
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
  'stars_of_three': {
    'fr': '{stars} sur 3 étoiles',
    'en': '{stars} out of 3 stars',
    'ar': '{stars} من 3 نجوم',
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

  // ---- Corrections (nouvel écran) ----
  'score_label': {'fr': 'Score', 'en': 'Score', 'ar': 'النتيجة'},
  'good_job': {'fr': 'Bon travail !', 'en': 'Good job!', 'ar': 'عمل رائع!'},
  'keep_going': {'fr': 'Continuez !', 'en': 'Keep going!', 'ar': 'واصل المحاولة!'},
  'correct_count': {
    'fr': '{count} Correctes',
    'en': '{count} Correct',
    'ar': '{count} صحيحة',
  },
  'incorrect_count': {
    'fr': '{count} Incorrectes',
    'en': '{count} Incorrect',
    'ar': '{count} خاطئة',
  },
  'unanswered_count': {
    'fr': '{count} Sans réponse',
    'en': '{count} Unanswered',
    'ar': '{count} بدون إجابة',
  },
  'filter_all': {'fr': 'Toutes', 'en': 'All', 'ar': 'الكل'},
  'filter_correct': {'fr': 'Correctes', 'en': 'Correct', 'ar': 'الصحيحة'},
  'filter_incorrect': {'fr': 'Incorrectes', 'en': 'Incorrect', 'ar': 'الخاطئة'},
  'unanswered': {'fr': 'Sans réponse', 'en': 'Unanswered', 'ar': 'بدون إجابة'},
  'explanation': {'fr': 'Explication', 'en': 'Explanation', 'ar': 'الشرح'},
  'perfect_score': {'fr': 'Score parfait !', 'en': 'Perfect score!', 'ar': 'نتيجة كاملة!'},
  'perfect_score_desc': {
    'fr': 'Vous avez répondu juste à toutes les questions. Bravo !',
    'en': 'You answered every question correctly. Well done!',
    'ar': 'لقد أجبت على جميع الأسئلة بشكل صحيح. أحسنت!',
  },
  'no_corrections': {
    'fr': 'Aucune correction',
    'en': 'No corrections',
    'ar': 'لا توجد تصحيحات',
  },
  'no_corrections_desc': {
    'fr': 'Terminez un quiz pour retrouver ici vos réponses corrigées.',
    'en': 'Finish a quiz to see your corrected answers here.',
    'ar': 'أكمل اختبارًا لتجد هنا إجاباتك المصححة.',
  },
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
