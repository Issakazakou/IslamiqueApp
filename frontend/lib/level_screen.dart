import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'quiz_options_dialog.dart';
import 'quiz_screen.dart';
import 'stage_progress_manager.dart';
import 'theme_button.dart';
import 'widgets.dart';

/// Écran du parcours et des niveaux pour une catégorie donnée.
/// Permet de naviguer entre Débutant, Intermédiaire, Avancé,
/// d'accéder au parcours des 5 sous-niveaux (étapes 1 à 5) avec étoiles et déblocage,
/// ou de lancer un quiz rapide selon les options configurées.
class LevelScreen extends StatefulWidget {
  final QuizCategory category;

  const LevelScreen({super.key, required this.category});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  QuizLevel _selectedLevel = QuizLevel.debutant;

  void _launchQuickQuiz() {
    final options = StageProgressManager.instance.options;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: widget.category,
          level: _selectedLevel,
          stage: null, // null = mode rapide aléatoire
          options: options,
        ),
      ),
    );
  }

  void _launchStage(QuizStage stage) {
    final unlocked = StageProgressManager.instance.isStageUnlocked(
      widget.category.id,
      _selectedLevel.apiValue,
      stage.number,
    );

    if (!unlocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              const SizedBox(width: TwSpace.s25),
              Expanded(
                child: Text(
                  context.tr('stage_locked_msg'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: TwColors.brand700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: TwRadius.rXl),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final options = StageProgressManager.instance.options;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: widget.category,
          level: _selectedLevel,
          stage: stage,
          options: options,
        ),
      ),
    );
  }

  Color _getLevelColor(QuizLevel level) {
    switch (level) {
      case QuizLevel.debutant:
        return const Color(0xFF14573F);
      case QuizLevel.intermediaire:
        return const Color(0xFFC99A3B);
      case QuizLevel.avance:
        return const Color(0xFF2E639A);
    }
  }

  LinearGradient _getLevelGradient(QuizLevel level) {
    switch (level) {
      case QuizLevel.debutant:
        return const LinearGradient(
          colors: [Color(0xFF0E3B2C), Color(0xFF14573F), Color(0xFF1D6F50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QuizLevel.intermediaire:
        return const LinearGradient(
          colors: [Color(0xFF7A5A12), Color(0xFFC99A3B), Color(0xFFD8AF4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QuizLevel.avance:
        return const LinearGradient(
          colors: [Color(0xFF122840), Color(0xFF2E639A), Color(0xFF3D79B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tw.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: StageProgressManager.instance,
          builder: (context, _) {
            final progressMgr = StageProgressManager.instance;
            final totalStars = progressMgr.getTotalStars(
              widget.category.id,
              _selectedLevel.apiValue,
            );
            final completedCount = progressMgr.getCompletedStagesCount(
              widget.category.id,
              _selectedLevel.apiValue,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: TwSpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: TwSpace.s35),

                  // Barre supérieure
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: TwSpace.s3),
                      Hero(
                        tag: 'category_icon_${widget.category.id}',
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.category.iconBackground,
                            borderRadius: TwRadius.rXl,
                          ),
                          child: Icon(
                            widget.category.icon,
                            color: widget.category.iconColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: TwSpace.s25),
                      Expanded(
                        child: Text(
                          widget.category.titleOf(context),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: context.tw.textPrimary,
                          ),
                        ),
                      ),
                      const ThemeButton(),
                      const SizedBox(width: TwSpace.s1),
                      // Bouton d'options du Quiz
                      IconButton(
                        tooltip: context.tr('options_title'),
                        icon: Container(
                          padding: const EdgeInsets.all(TwSpace.s2),
                          decoration: BoxDecoration(
                            color: context.tw.surface,
                            borderRadius: TwRadius.rXl,
                            border: Border.all(color: context.tw.border),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: TwColors.brand600,
                            size: 20,
                          ),
                        ),
                        onPressed: () => QuizOptionsSheet.show(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: TwSpace.s4),

                  // Sélecteur de Difficulté avec couleur spécifique par niveau
                  _buildDifficultySelector(),

                  const SizedBox(height: TwSpace.s35),

                  // Carte récapitulative des étoiles & progression
                  _buildProgressBanner(totalStars, completedCount),

                  const SizedBox(height: TwSpace.s4),

                  // Liste déroulante : Mode Rapide + Parcours des 5 étapes
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Carte Mode Rapide Aléatoire
                        _buildQuickQuizCard(),

                        const SizedBox(height: TwSpace.s4),

                        // Titre de section du Parcours
                        Row(
                          children: [
                            Icon(
                              Icons.route_outlined,
                              color: _getLevelColor(_selectedLevel),
                              size: 20,
                            ),
                            const SizedBox(width: TwSpace.s2),
                            Expanded(
                              child: Text(
                                context.tr('journey_title'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: context.tw.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TwSpace.s1),
                        Text(
                          context.tr('journey_desc'),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.tw.textSecondary,
                          ),
                        ),

                        const SizedBox(height: TwSpace.s35),

                        // Les 5 étapes du parcours
                        ...defaultStages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final stage = entry.value;
                          final isUnlocked = progressMgr.isStageUnlocked(
                            widget.category.id,
                            _selectedLevel.apiValue,
                            stage.number,
                          );
                          final stars = progressMgr.getStageStars(
                            widget.category.id,
                            _selectedLevel.apiValue,
                            stage.number,
                          );
                          final highScore = progressMgr.getStageHighScore(
                            widget.category.id,
                            _selectedLevel.apiValue,
                            stage.number,
                          );
                          final totalQ = progressMgr.getStageHighTotal(
                            widget.category.id,
                            _selectedLevel.apiValue,
                            stage.number,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: TwSpace.s3),
                            child: _buildStageCard(
                              stage: stage,
                              isUnlocked: isUnlocked,
                              stars: stars,
                              highScore: highScore,
                              totalQ: totalQ,
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: TwMotion.d300,
                                delay: (index * 60).ms,
                                curve: TwMotion.emphasized,
                              )
                              .slideY(
                                begin: 0.06,
                                end: 0,
                                duration: TwMotion.d300,
                                delay: (index * 60).ms,
                                curve: TwMotion.emphasized,
                              );
                        }),

                        const SizedBox(height: TwSpace.s4),
                        const AppFooter(),
                        const SizedBox(height: TwSpace.s4),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sélecteur de Difficulté avec indicateur visuel & couleur propre
  // -------------------------------------------------------------------------

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(TwSpace.s1),
      decoration: BoxDecoration(
        color: context.tw.surface,
        borderRadius: TwRadius.r2xl,
        border: Border.all(color: context.tw.border),
      ),
      child: Row(
        children: QuizLevel.values.map((lvl) {
          final isSel = _selectedLevel == lvl;
          final lvlColor = _getLevelColor(lvl);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedLevel = lvl),
              child: AnimatedContainer(
                duration: TwMotion.d300,
                curve: TwMotion.emphasized,
                padding: const EdgeInsets.symmetric(vertical: TwSpace.s25, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSel ? lvlColor : Colors.transparent,
                  borderRadius: TwRadius.rXl,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lvl.icon,
                        size: 15,
                        color: isSel ? Colors.white : lvlColor,
                      ),
                      const SizedBox(width: TwSpace.s15),
                      Text(
                        lvl.titleOf(context),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel ? Colors.white : context.tw.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bannière de Progression avec dégradé propre au niveau & motif islamique
  // -------------------------------------------------------------------------

  Widget _buildProgressBanner(int totalStars, int completedCount) {
    final progress = (completedCount / 5).clamp(0.0, 1.0);
    final levelGradient = _getLevelGradient(_selectedLevel);

    return Container(
      decoration: BoxDecoration(
        gradient: levelGradient,
        borderRadius: TwRadius.r2xl,
        boxShadow: TwShadow.md(context),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: TwRadius.r2xl,
        child: Stack(
          children: [
            // Motif islamique subtil
            Positioned.fill(
              child: CustomPaint(
                painter: const IslamicPatternPainter(
                  color: Colors.white,
                  opacity: 0.08,
                  scale: 34.0,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(TwSpace.s4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(TwSpace.s2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: TwRadius.rXl,
                              ),
                              child: const Icon(Icons.star, color: TwColors.gold500, size: 20),
                            ),
                            const SizedBox(width: TwSpace.s25),
                            Flexible(
                              child: Text(
                                context.tr('stars_count', {'stars': '$totalStars'}),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: TwSpace.s2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TwSpace.s25,
                          vertical: TwSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: TwRadius.rXl,
                        ),
                        child: Text(
                          context.tr('stages_completed', {'count': '$completedCount'}),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TwSpace.s3),
                  ClipRRect(
                    borderRadius: TwRadius.rLg,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(TwColors.gold500),
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

  // -------------------------------------------------------------------------
  // Carte Mode Rapide
  // -------------------------------------------------------------------------

  Widget _buildQuickQuizCard() {
    final levelColor = _getLevelColor(_selectedLevel);

    return Container(
      decoration: BoxDecoration(
        color: context.tw.surface,
        borderRadius: TwRadius.r2xl,
        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
        boxShadow: TwShadow.sm(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TwRadius.r2xl,
          onTap: _launchQuickQuiz,
          child: Padding(
            padding: const EdgeInsets.all(TwSpace.s4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: TwRadius.rXl,
                  ),
                  child: Icon(
                    Icons.bolt_outlined,
                    color: levelColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: TwSpace.s35),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('quick_quiz'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.tw.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TwSpace.s05),
                      Text(
                        context.tr('quick_quiz_desc'),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tw.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(TwSpace.s2),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: TwRadius.rXl,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Carte d'une Étape du Parcours
  // -------------------------------------------------------------------------

  Widget _buildStageCard({
    required QuizStage stage,
    required bool isUnlocked,
    required int stars,
    required int highScore,
    required int totalQ,
  }) {
    final title = context.tr(stage.titleKey);
    final desc = context.tr(stage.descKey);
    final levelColor = _getLevelColor(_selectedLevel);

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? context.tw.surface
            : context.tw.surface.withValues(alpha: 0.6),
        borderRadius: TwRadius.r2xl,
        border: Border.all(
          color: isUnlocked
              ? (stars >= 1 ? levelColor.withValues(alpha: 0.4) : context.tw.border)
              : context.tw.border.withValues(alpha: 0.5),
        ),
        boxShadow: isUnlocked ? TwShadow.sm(context) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TwRadius.r2xl,
          onTap: () => _launchStage(stage),
          child: Padding(
            padding: const EdgeInsets.all(TwSpace.s4),
            child: Row(
              children: [
                // Numéro d'étape ou cadenas
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? (stars >= 1 ? levelColor.withValues(alpha: 0.12) : context.tw.background)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: TwRadius.rXl,
                  ),
                  child: Icon(
                    isUnlocked ? stage.icon : Icons.lock_outline,
                    color: isUnlocked
                        ? (stars >= 1 ? levelColor : context.tw.textPrimary)
                        : context.tw.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: TwSpace.s35),

                // Informations de l'étape
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked ? context.tw.textPrimary : context.tw.textMuted,
                        ),
                      ),
                      const SizedBox(height: TwSpace.s05),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tw.textSecondary,
                        ),
                      ),
                      if (isUnlocked && stars > 0) ...[
                        const SizedBox(height: TwSpace.s15),
                        Row(
                          children: [
                            _buildStarRow(stars),
                            if (totalQ > 0) ...[
                              const SizedBox(width: TwSpace.s2),
                              Text(
                                '$highScore / $totalQ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: context.tw.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Bouton d'action à droite
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TwSpace.s25,
                      vertical: TwSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: stars >= 1 ? context.tw.background : levelColor,
                      borderRadius: TwRadius.rXl,
                      border: Border.all(
                        color: stars >= 1 ? context.tw.border : levelColor,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        stars >= 1 ? context.tr('replay') : context.tr('play_stage'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: stars >= 1 ? context.tw.textPrimary : Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(TwSpace.s2),
                    child: Icon(Icons.lock, color: context.tw.border, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRow(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: filled ? TwColors.gold500 : context.tw.border,
          size: 16,
        );
      }),
    );
  }
}
