import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_strings.dart';
import 'auth_screen.dart';
import 'category_group_screen.dart';
import 'category_progress.dart';
import 'certificates.dart';
import 'certificates_screen.dart';
import 'config/api_config.dart';
import 'level_screen.dart';
import 'quiz_models.dart';
import 'quiz_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';
import 'user_progress.dart';
import 'welcome_auth_screen.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  await LanguageController.instance.load();
  await ThemeController.instance.load();
  await StageProgressManager.instance.init();
  await UserProgress.instance.load();
  await CertificateManager.instance.init();
  await AuthService.instance.init();
  await NotificationService.instance.init();
  runApp(const QuizIslamiqueApp());
}

/// Alias pour compatibilité
typedef MyApp = QuizIslamiqueApp;

class QuizIslamiqueApp extends StatelessWidget {
  const QuizIslamiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reconstruit toute l'application quand la langue ou le thème change.
    return AnimatedBuilder(
      animation: Listenable.merge([
        LanguageController.instance,
        ThemeController.instance,
      ]),
      builder: (context, _) {
        final langCode = LanguageController.instance.locale.languageCode;
        return MaterialApp(
          onGenerateTitle: (ctx) => ctx.tr('app_title'),
          debugShowCheckedModeBanner: false,
          locale: LanguageController.instance.locale,
          supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme(langCode),
          darkTheme: AppTheme.darkTheme(langCode),
          themeMode: ThemeController.instance.themeMode,
          // Grands écrans (tablette, web) : contenu centré, largeur limitée.
          builder: (context, child) => ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: child,
              ),
            ),
          ),
          home: const AppEntryGate(),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Porte d'entrée de l'application : exige le choix préalable entre
/// « Se connecter à mon compte » ou « Continuer sans compte » avant
/// d'accéder à l'écran d'accueil.
/// ---------------------------------------------------------------------------
class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  bool _enteredAsGuest = false;
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = AuthService.instance.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = AuthService.instance.isLoggedIn;

        // Si l'utilisateur s'est déconnecté, réinitialiser le choix
        if (_wasLoggedIn && !isLoggedIn) {
          _enteredAsGuest = false;
        }
        _wasLoggedIn = isLoggedIn;

        if (isLoggedIn || _enteredAsGuest) {
          return const HomeScreen();
        }

        return WelcomeAuthScreen(
          onContinueWithoutAccount: () {
            setState(() => _enteredAsGuest = true);
          },
          onLoginSuccess: () {
            // AuthService notifie automatiquement et bascule sur HomeScreen
          },
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Écran d'accueil (Home Screen)
/// Design moderne « Tailwind CSS » : épuré, aéré, hiérarchisé et naturel.
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openLevels(BuildContext context, QuizCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Un groupe (Coran) ouvre d'abord ses sous-catégories.
        builder: (_) => category.isGroup
            ? CategoryGroupScreen(group: category)
            : LevelScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    return Scaffold(
      backgroundColor: tw.background,
      body: SafeArea(
        child: Padding(
          padding: TwSpace.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TwSpace.s3),
              const _Header(),
              const SizedBox(height: TwSpace.s4),

              // Contenu principal entièrement scrollable
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: TwSpace.s8),
                  children: [
                    // Bannière héroïque épurée (Focus & Objectif d'apprentissage)
                    const _HeroBanner(),

                    const SizedBox(height: TwSpace.s4),

                    // Ligne Bento : Défi du jour & Certificats
                    const _BentoHighlightsRow(),

                    const SizedBox(height: TwSpace.s5),

                    // Titre de section "Choisir une catégorie"
                    TwSectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: context.tr('home_choose_category'),
                    ),

                    const SizedBox(height: TwSpace.s3),

                    // Cartes de catégories modernes avec micro-interactions
                    ...categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: TwSpace.s3),
                        child: _ModernCategoryCard(
                          category: category,
                          onTap: () => _openLevels(context, category),
                        )
                            .animate()
                            .fadeIn(
                              duration: TwMotion.standard,
                              delay: (index * 50).ms,
                              curve: TwMotion.emphasized,
                            )
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              duration: TwMotion.standard,
                              delay: (index * 50).ms,
                              curve: TwMotion.emphasized,
                            ),
                      );
                    }),

                    const SizedBox(height: TwSpace.s4),
                    const AppFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Barre supérieure : Identité, Salutation, Badges de statut et Menu Réglages
/// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthService.instance,
        UserProgress.instance,
        StageProgressManager.instance,
      ]),
      builder: (context, _) {
        final auth = AuthService.instance;
        final progress = UserProgress.instance;
        final user = auth.user;
        final stars = totalStars();
        final streak = progress.activeStreak;

        return Row(
          children: [
            // Emblème raffiné
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? TwColors.brand900 : TwColors.brand50,
                borderRadius: TwRadius.rXl,
                border: Border.all(
                  color: isDark ? TwColors.brand700 : TwColors.brand200,
                  width: TwBorder.thin,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.mosque_outlined,
                  color: isDark ? TwColors.gold400 : TwColors.brand600,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: TwSpace.s3),

            // Salutation / Titre moderne
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    auth.isLoggedIn && user != null && user.name.trim().isNotEmpty
                        ? 'Salam, ${user.name} 👋'
                        : context.tr('app_title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TwText.h4(context).copyWith(
                      fontWeight: TwWeight.extrabold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('home_subtitle'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TwText.caption(context).copyWith(
                      color: tw.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TwSpace.s2),

            // Badge Flamme (Série de jours)
            _StatusPill(
              icon: Icons.local_fire_department_rounded,
              iconColor: TwColors.gold500,
              label: '$streak j',
              bgColor: isDark ? TwColors.goldTintDark : TwColors.gold50,
              borderColor: isDark ? TwColors.gold800 : TwColors.gold200,
              textColor: isDark ? TwColors.gold300 : TwColors.gold800,
              tooltip: context.tr('streak_label', {'n': streak.toString()}),
              onTap: () => openAccount(context),
            ),
            const SizedBox(width: TwSpace.s15),

            // Badge Étoiles
            _StatusPill(
              icon: Icons.star_rounded,
              iconColor: TwColors.gold500,
              label: '$stars',
              bgColor: isDark ? TwColors.brandTintDark : TwColors.brand50,
              borderColor: isDark ? TwColors.brand800 : TwColors.brand200,
              textColor: isDark ? TwColors.brand300 : TwColors.brand800,
              tooltip: context.tr('profile_stars'),
              onTap: () => openAccount(context),
            ),
            const SizedBox(width: TwSpace.s15),

            // Bouton Réglages & Préférences (Thème, Langue, Serveur)
            Material(
              color: Colors.transparent,
              borderRadius: TwRadius.pill,
              child: InkWell(
                borderRadius: TwRadius.pill,
                onTap: () => _openQuickPreferences(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tw.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tw.border,
                      width: TwBorder.thin,
                    ),
                    boxShadow: TwShadow.sm(context),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 19,
                    color: tw.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: TwSpace.s15),

            // Bouton Compte / Profil
            Material(
              color: Colors.transparent,
              borderRadius: TwRadius.pill,
              child: InkWell(
                borderRadius: TwRadius.pill,
                onTap: () => openAccount(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: auth.isLoggedIn ? TwColors.brand600 : tw.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: auth.isLoggedIn
                          ? TwColors.gold500.withValues(alpha: 0.5)
                          : tw.border,
                      width: TwBorder.thin,
                    ),
                    boxShadow: TwShadow.sm(context),
                  ),
                  child: Center(
                    child: Icon(
                      auth.isLoggedIn ? Icons.person : Icons.person_outline_rounded,
                      size: 20,
                      color: auth.isLoggedIn ? Colors.white : tw.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pilule de statut compacte et tactile (Série, Étoiles)
/// ---------------------------------------------------------------------------
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final String? tooltip;
  final VoidCallback onTap;

  const _StatusPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill = Material(
      color: Colors.transparent,
      borderRadius: TwRadius.pill,
      child: InkWell(
        borderRadius: TwRadius.pill,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: TwRadius.pill,
            border: Border.all(color: borderColor, width: TwBorder.thin),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: TwWeight.extrabold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      pill = Tooltip(message: tooltip!, child: pill);
    }
    return pill;
  }
}

/// ---------------------------------------------------------------------------
/// Carte Héroïque moderne : Parcours d'apprentissage et progression globale
/// ---------------------------------------------------------------------------
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = TwSurface.isDark(context);
    return ListenableBuilder(
      listenable: StageProgressManager.instance,
      builder: (context, _) {
        final maxStars = totalMaxStars();
        final stars = totalStars();
        final progressRatio =
            maxStars == 0 ? 0.0 : (stars / maxStars).clamp(0.0, 1.0);
        final percentInt = (progressRatio * 100).round();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF0F261E),
                      Color(0xFF071813),
                    ]
                  : const [
                      Color(0xFF14573F),
                      Color(0xFF0E3B2C),
                    ],
            ),
            borderRadius: TwRadius.r2xl,
            border: Border.all(
              color: TwColors.gold500.withValues(alpha: 0.25),
              width: 1.0,
            ),
            boxShadow: TwShadow.md(context),
          ),
          child: ClipRRect(
            borderRadius: TwRadius.r2xl,
            child: Stack(
              children: [
                // Filigrane géométrique très subtil
                Positioned.fill(
                  child: CustomPaint(
                    painter: const IslamicPatternPainter(
                      color: TwColors.gold500,
                      opacity: 0.04,
                      scale: 36.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge supérieur
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: TwRadius.pill,
                              border: Border.all(
                                color: TwColors.gold400.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  color: TwColors.gold400,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  context.tr('badge_counts', {
                                    'n': leafCategories.length.toString(),
                                  }),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: TwWeight.extrabold,
                                    letterSpacing: 0.4,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Étoiles
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 15, color: TwColors.gold400),
                              const SizedBox(width: 3),
                              Text(
                                '$stars / $maxStars',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: TwWeight.extrabold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Titre inspirant
                      Text(
                        context.tr('home_subtitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Barre de progression moderne
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: TwRadius.pill,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 7,
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progressRatio,
                                    child: Container(
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        gradient: TwColors.goldGradient,
                                        borderRadius: TwRadius.pill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$percentInt%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: TwWeight.extrabold,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Ligne Bento : Défi du Jour & Certificats
/// ---------------------------------------------------------------------------
class _BentoHighlightsRow extends StatelessWidget {
  const _BentoHighlightsRow();

  QuizCategory _todayCategory() {
    final now = DateTime.now();
    final days = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(2024))
        .inDays;
    return leafCategories[days % leafCategories.length];
  }

  void _startDaily(BuildContext context, QuizCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: category,
          level: QuizLevel.debutant,
          options: StageProgressManager.instance.options,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = TwSurface.isDark(context);
    final category = _todayCategory();

    return ListenableBuilder(
      listenable: Listenable.merge([
        UserProgress.instance,
        CertificateManager.instance,
      ]),
      builder: (context, _) {
        final progress = UserProgress.instance;
        final certManager = CertificateManager.instance;
        final done = progress.playedToday;
        final earnedCerts = certManager.earnedCount;
        final totalCerts = CertificateManager.all.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte 1 : Défi du jour
            Expanded(
              child: _BentoCard(
                onTap: () => _startDaily(context, category),
                icon: Icons.local_fire_department_rounded,
                iconColor: TwColors.gold500,
                tag: 'DÉFI DU JOUR',
                title: done
                    ? context.tr('daily_done')
                    : category.titleOf(context),
                subtitle: done ? context.tr('daily_again') : '10 questions rapides',
                isCompleted: done,
                actionLabel: done ? context.tr('daily_again') : context.tr('daily_start'),
              ),
            ),
            const SizedBox(width: TwSpace.s3),

            // Carte 2 : Certificats & Succès
            Expanded(
              child: _BentoCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                ),
                icon: Icons.workspace_premium_rounded,
                iconColor: isDark ? TwColors.gold400 : TwColors.brand600,
                tag: 'ATTESTATIONS',
                title: context.tr('cert_my'),
                subtitle: context.tr('cert_count', {
                  'n': earnedCerts.toString(),
                  'total': totalCerts.toString(),
                }),
                isCompleted: earnedCerts > 0,
                actionLabel: 'Consulter',
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Carte compacte pour le Bento (style Tailwind UI)
/// ---------------------------------------------------------------------------
class _BentoCard extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final String tag;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isCompleted;

  const _BentoCard({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.isCompleted = false,
  });

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: TwMotion.d150,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TwRadius.r2xl,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tw.surface,
              borderRadius: TwRadius.r2xl,
              border: Border.all(
                color: tw.border,
                width: TwBorder.thin,
              ),
              boxShadow: TwShadow.sm(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.12),
                        borderRadius: TwRadius.rLg,
                      ),
                      child: Icon(widget.icon, size: 16, color: widget.iconColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: TwWeight.extrabold,
                          letterSpacing: 0.5,
                          color: tw.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TwText.bodySm(context).copyWith(
                    fontWeight: TwWeight.extrabold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TwText.caption(context).copyWith(
                    color: tw.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      widget.actionLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: TwWeight.bold,
                        color: isDark ? TwColors.gold400 : TwColors.brand600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: isDark ? TwColors.gold400 : TwColors.brand600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Carte de catégorie moderne (style Tailwind Card)
/// ---------------------------------------------------------------------------
class _ModernCategoryCard extends StatefulWidget {
  final QuizCategory category;
  final VoidCallback onTap;

  const _ModernCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  State<_ModernCategoryCard> createState() => _ModernCategoryCardState();
}

class _ModernCategoryCardState extends State<_ModernCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    final cat = widget.category;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ListenableBuilder(
      listenable: StageProgressManager.instance,
      builder: (context, _) {
        final stars = categoryStars(cat);
        final maxStars = categoryMaxStars(cat);
        final progressRatio =
            maxStars == 0 ? 0.0 : (stars / maxStars).clamp(0.0, 1.0);

        return AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: TwMotion.d150,
          curve: TwMotion.emphasized,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: TwRadius.r2xl,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tw.surface,
                  borderRadius: TwRadius.r2xl,
                  border: Border.all(
                    color: _pressed
                        ? cat.iconColor.withValues(alpha: 0.4)
                        : tw.border,
                    width: TwBorder.thin,
                  ),
                  boxShadow: _pressed ? TwShadow.md(context) : TwShadow.sm(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pastille d'icône avec dégradé doux
                        Hero(
                          tag: 'category_icon_${cat.id}',
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cat.iconBackground,
                              borderRadius: TwRadius.rXl,
                              border: Border.all(
                                color: cat.iconColor.withValues(alpha: 0.2),
                                width: TwBorder.thin,
                              ),
                            ),
                            child: Icon(cat.icon, color: cat.iconColor, size: 24),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Titre & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat.titleOf(context),
                                      style: TwText.h4(context).copyWith(
                                        fontWeight: TwWeight.extrabold,
                                      ),
                                    ),
                                  ),
                                  if (cat.isGroup)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? TwColors.brandTintDark
                                            : TwColors.brand50,
                                        borderRadius: TwRadius.pill,
                                        border: Border.all(
                                          color: isDark
                                              ? TwColors.brand800
                                              : TwColors.brand200,
                                          width: TwBorder.thin,
                                        ),
                                      ),
                                      child: Text(
                                        '${cat.children.length} THÈMES',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: TwWeight.extrabold,
                                          letterSpacing: 0.3,
                                          color: isDark
                                              ? TwColors.brand300
                                              : TwColors.brand700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.descriptionOf(context),
                                style: TwText.bodySm(context).copyWith(
                                  color: tw.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Flèche chevron discrète
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark ? TwColors.ink800 : TwColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            size: 18,
                            color: tw.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Barre de progression des étoiles
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: TwRadius.pill,
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  color: isDark
                                      ? TwColors.ink700
                                      : TwColors.slate100,
                                ),
                                FractionallySizedBox(
                                  widthFactor: progressRatio,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: cat.iconBackground == AppColors.goldTint
                                          ? TwColors.goldGradient
                                          : TwColors.brandGradient,
                                      borderRadius: TwRadius.pill,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: TwColors.gold500,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$stars/$maxStars',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: TwWeight.bold,
                            color: tw.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Panneau modal moderne de préférences rapides (Langue, Thème, Serveur)
/// ---------------------------------------------------------------------------
void _openQuickPreferences(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final tw = sheetContext.tw;
      final isDark = TwSurface.isDark(sheetContext);
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: tw.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: tw.border, width: TwBorder.thin),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée supérieure
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tw.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titre du panneau
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? TwColors.brandTintDark : TwColors.brand50,
                      borderRadius: TwRadius.rLg,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: isDark ? TwColors.gold400 : TwColors.brand600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Préférences',
                      style: TwText.h4(sheetContext).copyWith(
                        fontWeight: TwWeight.extrabold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Choix de la langue
              Text(
                sheetContext.tr('language'),
                style: TwText.label(sheetContext),
              ),
              const SizedBox(height: 8),
              const _LanguageSelector(),
              const SizedBox(height: 18),

              // 2. Choix du thème
              Text(
                sheetContext.tr('theme_title'),
                style: TwText.label(sheetContext),
              ),
              const SizedBox(height: 8),
              const _ThemeSelector(),
              const SizedBox(height: 18),

              // 3. Serveur API
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tw.surface,
                    borderRadius: TwRadius.rLg,
                    border: Border.all(color: tw.border),
                  ),
                  child: const Icon(Icons.dns_outlined, size: 20),
                ),
                title: Text(
                  sheetContext.tr('server_settings'),
                  style: TwText.bodySm(sheetContext).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  ApiConfig.baseUrl,
                  style: TwText.caption(sheetContext),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ServerSettingsDialog.show(context);
                },
              ),
              const SizedBox(height: 12),

              // 4. Rappel après 2h
              AnimatedBuilder(
                animation: NotificationService.instance,
                builder: (ctx, _) {
                  final notif = NotificationService.instance;
                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tw.surface,
                        borderRadius: TwRadius.rLg,
                        border: Border.all(color: tw.border),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        size: 20,
                        color: notif.isEnabled ? TwColors.gold500 : tw.textSecondary,
                      ),
                    ),
                    title: Text(
                      sheetContext.tr('notif_reminder_title'),
                      style: TwText.bodySm(sheetContext).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notif.isEnabled
                          ? sheetContext.tr('notif_reminder_desc')
                          : sheetContext.tr('notif_reminder_disabled'),
                      style: TwText.caption(sheetContext),
                    ),
                    value: notif.isEnabled,
                    onChanged: (val) => notif.setEnabled(val),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    final current = Localizations.localeOf(context).languageCode;

    final langs = [
      {'code': 'fr', 'label': 'Français'},
      {'code': 'en', 'label': 'English'},
      {'code': 'ar', 'label': 'العربية'},
    ];

    return Row(
      children: langs.map((l) {
        final code = l['code']!;
        final label = l['label']!;
        final isSelected = current == code;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: TwRadius.rXl,
              onTap: () => LanguageController.instance.setLanguage(code),
              child: AnimatedContainer(
                duration: TwMotion.d200,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? TwColors.brand600 : TwColors.brand50)
                      : tw.surface,
                  borderRadius: TwRadius.rXl,
                  border: Border.all(
                    color: isSelected ? TwColors.brand600 : tw.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? TwWeight.extrabold : TwWeight.medium,
                      color: isSelected
                          ? (isDark ? Colors.white : TwColors.brand700)
                          : tw.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final mode = ThemeController.instance.themeMode;
        final modes = [
          {
            'mode': ThemeMode.light,
            'label': context.tr('theme_light'),
            'icon': Icons.light_mode_outlined
          },
          {
            'mode': ThemeMode.dark,
            'label': context.tr('theme_dark'),
            'icon': Icons.dark_mode_outlined
          },
          {
            'mode': ThemeMode.system,
            'label': context.tr('theme_system'),
            'icon': Icons.brightness_auto_outlined
          },
        ];

        return Row(
          children: modes.map((m) {
            final targetMode = m['mode'] as ThemeMode;
            final label = m['label'] as String;
            final icon = m['icon'] as IconData;
            final isSelected = mode == targetMode;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  borderRadius: TwRadius.rXl,
                  onTap: () =>
                      ThemeController.instance.setThemeMode(targetMode),
                  child: AnimatedContainer(
                    duration: TwMotion.d200,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? TwColors.brand600 : TwColors.brand50)
                          : tw.surface,
                      borderRadius: TwRadius.rXl,
                      border: Border.all(
                        color: isSelected ? TwColors.brand600 : tw.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 15,
                          color: isSelected
                              ? (isDark ? Colors.white : TwColors.brand700)
                              : tw.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? TwWeight.extrabold
                                : TwWeight.medium,
                            color: isSelected
                                ? (isDark ? Colors.white : TwColors.brand700)
                                : tw.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

