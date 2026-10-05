import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_strings.dart';
import 'config/api_config.dart';
import 'language_button.dart';
import 'level_screen.dart';
import 'quiz_models.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';
import 'theme_button.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  await LanguageController.instance.load();
  await ThemeController.instance.load();
  await StageProgressManager.instance.init();
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
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Écran d'accueil
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openLevels(BuildContext context, QuizCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LevelScreen(category: category)),
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
              const SizedBox(height: TwSpace.s35),
              const _Header(),
              const SizedBox(height: TwSpace.s35),

              // Contenu principal entièrement scrollable pour responsivité totale
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // Bannière héroïque avec motif géométrique islamique discret
                    const _HeroBanner(),

                    const SizedBox(height: TwSpace.s5),

                    // Titre de section "Choisir une catégorie"
                    TwSectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: context.tr('home_choose_category'),
                    ),

                    const SizedBox(height: TwSpace.s3),

                    // Liste des catégories avec apparition en cascade
                    ...categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: TwSpace.s35),
                        child: AppCard(
                          icon: category.icon,
                          iconColor: category.iconColor,
                          iconBackground: category.iconBackground,
                          title: category.titleOf(context),
                          description: category.descriptionOf(context),
                          heroTag: 'category_icon_${category.id}',
                          onTap: () => _openLevels(context, category),
                        )
                            .animate()
                            .fadeIn(
                              duration: TwMotion.standard,
                              delay: (index * 60).ms,
                              curve: TwMotion.emphasized,
                            )
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: TwMotion.standard,
                              delay: (index * 60).ms,
                              curve: TwMotion.emphasized,
                            ),
                      );
                    }),

                    const SizedBox(height: TwSpace.s2),
                    const AppFooter(),
                    const SizedBox(height: TwSpace.s4),
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
/// Barre supérieure : Logo, Titre, Thème, Langue, Réglages
/// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: TwColors.brandGradient,
            borderRadius: TwRadius.rXl,
            boxShadow: TwShadow.sm(context),
            border: Border.all(
              color: TwColors.gold500.withValues(alpha: 0.3),
              width: TwBorder.thin,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.mosque_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: TwSpace.s25),
        Expanded(
          child: Text(
            context.tr('app_title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TwText.h3(context)
                .copyWith(fontWeight: TwWeight.extrabold),
          ),
        ),
        const ThemeButton(),
        const LanguageButton(),
        RoundIconButton(
          icon: Icons.settings_outlined,
          tooltip: context.tr('srv_title'),
          onTap: () {
            ServerSettingsDialog.show(context);
          },
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Bannière d'en-tête Héroïque (Dégradé émeraude + Motif géométrique islamique)
/// ---------------------------------------------------------------------------
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: TwColors.brandGradient,
        borderRadius: TwRadius.r3xl,
        boxShadow: TwShadow.md(context),
        border: Border.all(
          color: TwColors.gold500.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: TwRadius.r3xl,
        child: Stack(
          children: [
            // Motif géométrique islamique subtil en surimpression
            Positioned.fill(
              child: CustomPaint(
                painter: const IslamicPatternPainter(
                  color: TwColors.gold500,
                  opacity: 0.08,
                  scale: 36.0,
                ),
              ),
            ),

            // Contenu textuel
            Padding(
              padding: const EdgeInsets.all(TwSpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge supérieur
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TwSpace.s25,
                      vertical: TwSpace.s1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: TwRadius.rXl,
                      border: Border.all(
                        color: TwColors.gold500.withValues(alpha: 0.4),
                        width: TwBorder.thin,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars,
                            color: TwColors.gold500, size: 14),
                        const SizedBox(width: TwSpace.s15),
                        Text(
                          context.tr('badge_counts'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: TwWeight.bold,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: TwSpace.s3),

                  // Titre principal
                  Text(
                    context.tr('app_title'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: TwLeading.tight,
                    ),
                  ),

                  const SizedBox(height: TwSpace.s15),

                  // Sous-titre inspirant
                  Text(
                    context.tr('home_subtitle'),
                    style: TextStyle(
                      fontSize: TwFontSize.sm,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: TwLeading.snug,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
