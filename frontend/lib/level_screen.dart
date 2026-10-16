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
                      RoundIconButton(
                        icon: Icons.tune_rounded,
                        tooltip: context.tr('options_title'),
                        onTap: () => QuizOptionsSheet.show(context),
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

                          final isLast = index == defaultStages.length - 1;
                          final isCurrent = stage.number == _currentStageNumber(progressMgr);

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildStageRail(
                                  stage: stage,
                                  isUnlocked: isUnlocked,
                                  stars: stars,
                                  isCurrent: isCurrent,
                                  isLast: isLast,
                                ),
                                const SizedBox(width: TwSpace.s3),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: isLast ? 0 : TwSpace.s3),
                                    child: _buildStageCard(
                                      stage: stage,
                                      isUnlocked: isUnlocked,
                                      isCurrent: isCurrent,
                                      stars: stars,
                                      highScore: highScore,
                                      totalQ: totalQ,
                                    ),
                                  ),
                                ),
                              ],
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
        borderRadius: TwRadius.pill,
        border: Border.all(color: context.tw.border),
      ),
      child: Row(
        children: QuizLevel.values.map((lvl) {
          final isSel = _selectedLevel == lvl;
          final lvlColor = _getLevelColor(lvl);

          return Expanded(
            child: Semantics(
              button: true,
              selected: isSel,
              label: lvl.titleOf(context),
              excludeSemantics: true,
              child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedLevel = lvl),
              child: AnimatedContainer(
                duration: TwMotion.d300,
                curve: TwMotion.emphasized,
                padding: const EdgeInsets.symmetric(vertical: TwSpace.s25, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSel ? lvlColor : Colors.transparent,
                  borderRadius: TwRadius.pill,
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
    const maxStars = 15; // 5 étapes × 3 étoiles
    final percent = (totalStars / maxStars * 100).clamp(0.0, 100.0);
    final levelGradient = _getLevelGradient(_selectedLevel);

    return Semantics(
      label: '${_selectedLevel.titleOf(context)}, $totalStars / $maxStars, '
          '${context.tr('stages_completed', {'count': '$completedCount'})}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: levelGradient,
          borderRadius: AppTokens.rounded20,
          boxShadow: TwShadow.md(context),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: ClipRRect(
          borderRadius: AppTokens.rounded20,
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
                padding: const EdgeInsets.all(TwSpace.s5),
                child: Row(
                  children: [
                    // Anneau de progression (étoiles gagnées / 15)
                    ScoreRing(
                      percent: percent,
                      size: 84,
                      color: TwColors.gold500,
                      trackColor: Colors.white.withValues(alpha: 0.2),
                      textColor: Colors.white,
                      showCaption: false,
                    ),
                    const SizedBox(width: TwSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge du niveau
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TwSpace.s25,
                              vertical: TwSpace.s05,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: TwRadius.pill,
                            ),
                            child: Text(
                              _selectedLevel.titleOf(context).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: TwSpace.s15),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: TwColors.gold500, size: 24),
                              const SizedBox(width: TwSpace.s15),
                              Text(
                                '$totalStars / $maxStars',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TwSpace.s05),
                          Text(
                            context.tr('stages_completed', {'count': '$completedCount'}),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  /// Étape à jouer maintenant : la première débloquée qui n'a pas encore d'étoile.
  int? _currentStageNumber(StageProgressManager mgr) {
    for (final s in defaultStages) {
      final unlocked = mgr.isStageUnlocked(widget.category.id, _selectedLevel.apiValue, s.number);
      final stars = mgr.getStageStars(widget.category.id, _selectedLevel.apiValue, s.number);
      if (unlocked && stars == 0) return s.number;
    }
    return null;
  }

  /// Couleur du niveau, éclaircie en mode sombre pour rester lisible sur fond sombre.
  Color _levelAccent() {
    final c = _getLevelColor(_selectedLevel);
    return TwSurface.isDark(context) ? Color.lerp(c, Colors.white, 0.45)! : c;
  }

  /// Rail de la frise : badge (terminée / en cours / verrouillée) + trait de liaison.
  Widget _buildStageRail({
    required QuizStage stage,
    required bool isUnlocked,
    required int stars,
    required bool isCurrent,
    required bool isLast,
  }) {
    final levelColor = _getLevelColor(_selectedLevel);
    final completed = isUnlocked && stars >= 1;

    final Color badgeColor;
    final Widget badgeChild;
    Border? badgeBorder;
    if (completed) {
      badgeColor = levelColor;
      badgeChild = const Icon(Icons.check_rounded, color: Colors.white, size: 22);
    } else if (isCurrent) {
      badgeColor = levelColor.withValues(alpha: 0.14);
      badgeBorder = Border.all(color: _levelAccent(), width: 2);
      badgeChild = Text(
        '${stage.number}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _levelAccent(),
        ),
      );
    } else {
      badgeColor = context.tw.border.withValues(alpha: 0.5);
      badgeChild = Icon(Icons.lock_outline_rounded, color: context.tw.textMuted, size: 18);
    }

    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: badgeBorder,
            ),
            child: Center(child: badgeChild),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: TwSpace.s1),
                decoration: BoxDecoration(
                  color: completed ? levelColor.withValues(alpha: 0.5) : context.tw.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required QuizStage stage,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required int highScore,
    required int totalQ,
  }) {
    final tw = context.tw;
    final title = context.tr(stage.titleKey);
    final desc = context.tr(stage.descKey);
    final levelColor = _getLevelColor(_selectedLevel);
    final accent = _levelAccent();
    final replay = stars >= 1;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? tw.surface : tw.background,
        borderRadius: TwRadius.r2xl,
        border: Border.all(
          color: isCurrent
              ? levelColor.withValues(alpha: 0.6)
              : (isUnlocked ? tw.border : tw.border.withValues(alpha: 0.6)),
          width: isCurrent ? 1.5 : 1,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? tw.textPrimary : tw.textSecondary,
                  ),
                ),
                const SizedBox(height: TwSpace.s05),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, height: 1.35, color: tw.textSecondary),
                ),
                const SizedBox(height: TwSpace.s3),
                Row(
                  children: [
                    _buildStarRow(isUnlocked ? stars : 0),
                    if (isUnlocked && totalQ > 0) ...[
                      const SizedBox(width: TwSpace.s2),
                      Text(
                        '$highScore / $totalQ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tw.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TwSpace.s35,
                          vertical: TwSpace.s15 + 1,
                        ),
                        decoration: BoxDecoration(
                          color: replay ? levelColor.withValues(alpha: 0.12) : levelColor,
                          borderRadius: TwRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              replay ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              size: 16,
                              color: replay ? accent : Colors.white,
                            ),
                            const SizedBox(width: TwSpace.s1),
                            Text(
                              replay ? context.tr('replay') : context.tr('play_stage'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: replay ? accent : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, color: tw.textMuted, size: 16),
                          const SizedBox(width: TwSpace.s1),
                          Text(
                            context.tr('stage_locked_label'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: tw.textMuted,
                            ),
                          ),
                        ],
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

  Widget _buildStarRow(int stars) {
    return Semantics(
      label: context.tr('stars_of_three', {'stars': '$stars'}),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final filled = index < stars;
          return Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? TwColors.gold500 : context.tw.textMuted.withValues(alpha: 0.6),
            size: 20,
          );
        }),
      ),
    );
  }
}
