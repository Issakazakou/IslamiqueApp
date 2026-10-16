import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_strings.dart';
import 'certificates.dart';
import 'certificates_screen.dart';
import 'correction_screen.dart';
import 'quiz_models.dart';
import 'quiz_screen.dart';
import 'theme/theme.dart';
import 'widgets.dart';

class ResultScreen extends StatefulWidget {
  final QuizCategory category;
  final QuizLevel level;
  final QuizStage? stage;
  final QuizOptions options;
  final List<QuizQuestion> questions;
  final Map<int, int> userAnswers;
  final int score;
  final int stars;
  final bool newlyUnlocked;

  const ResultScreen({
    super.key,
    required this.category,
    required this.level,
    this.stage,
    this.options = const QuizOptions(),
    required this.questions,
    required this.userAnswers,
    required this.score,
    this.stars = 0,
    this.newlyUnlocked = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confettiController;

  /// Certificats obtenus grâce à ce quiz (affichés une seule fois).
  late final List<QuizCategory> _newCertificates =
      CertificateManager.instance.takePending();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    final total = widget.questions.length;
    final percentage = total > 0 ? (widget.score / total) * 100 : 0.0;
    if (percentage >= 80) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          _confettiController.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final percentage = total > 0 ? (widget.score / total) * 100 : 0.0;

    String appreciation;
    IconData trophyIcon;
    Color trophyColor;

    if (percentage >= 80) {
      appreciation = context.tr('appr_high');
      trophyIcon = Icons.emoji_events;
      trophyColor = TwColors.gold500;
    } else if (percentage >= 50) {
      appreciation = context.tr('appr_mid');
      trophyIcon = Icons.military_tech;
      trophyColor = TwColors.brand600;
    } else {
      appreciation = context.tr('appr_low');
      trophyIcon = Icons.school;
      trophyColor = context.tw.textSecondary;
    }

    final hasNextStage = widget.stage != null &&
        widget.stage!.number < defaultStages.length &&
        widget.stars >= 1;
    final nextStage = hasNextStage ? defaultStages[widget.stage!.number] : null;

    return Scaffold(
      backgroundColor: context.tw.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TwSpace.s5),
              child: Column(
                children: [
                  const SizedBox(height: TwSpace.s4),

                  // En-tête
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: TwSpace.s25),
                      Expanded(
                        child: Text(
                          context.tr('result_title'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: context.tw.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: TwSpace.s25),
                      RoundIconButton(
                        icon: Icons.home_outlined,
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ],
                  ),

                  const SizedBox(height: TwSpace.s4),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Anneau circulaire de score animé
                          _buildCircularScoreRing(
                            percentage: percentage,
                            trophyColor: trophyColor,
                            trophyIcon: trophyIcon,
                            total: total,
                          ),

                          const SizedBox(height: TwSpace.s4),

                          Text(
                            widget.category.titleOf(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: context.tw.textPrimary,
                            ),
                          ),
                          const SizedBox(height: TwSpace.s1),
                          Text(
                            widget.stage != null
                                ? '${widget.level.titleOf(context)} • ${context.tr(widget.stage!.titleKey)}'
                                : context.tr('level_label', {'level': widget.level.titleOf(context)}),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.tw.textSecondary,
                            ),
                          ),

                          // Étoiles obtenues avec animation élastique
                          const SizedBox(height: TwSpace.s35),
                          Semantics(
                            label: context.tr('stars_of_three', {'stars': '${widget.stars}'}),
                            excludeSemantics: true,
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (idx) {
                              final filled = idx < widget.stars;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: TwSpace.s15),
                                child: Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  color: filled ? TwColors.gold500 : context.tw.textMuted,
                                  size: 38,
                                )
                                    .animate()
                                    .scale(
                                      delay: (200 + idx * 120).ms,
                                      duration: TwMotion.d300,
                                      curve: Curves.elasticOut,
                                    ),
                              );
                            }),
                          ),
                          ),

                          // Bannière étape débloquée si applicable
                          if (widget.newlyUnlocked && nextStage != null) ...[
                            const SizedBox(height: TwSpace.s4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TwSpace.s4,
                                vertical: TwSpace.s25,
                              ),
                              decoration: BoxDecoration(
                                color: context.tw.goldTint,
                                borderRadius: TwRadius.r2xl,
                                border: Border.all(color: TwColors.gold500, width: 1.2),
                                boxShadow: TwShadow.sm(context),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.celebration, color: TwColors.gold500, size: 22),
                                  const SizedBox(width: TwSpace.s2),
                                  Flexible(
                                    child: Text(
                                      context.tr('stage_unlocked_congrats', {'number': '${nextStage.number}'}),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: context.tw.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(duration: TwMotion.d300, curve: TwMotion.bouncy),
                          ],

                          if (_newCertificates.isNotEmpty) ...[
                            const SizedBox(height: TwSpace.s4),
                            for (final certificate in _newCertificates)
                              CertificateBanner(category: certificate),
                          ],

                          const SizedBox(height: TwSpace.s5),

                          // Carte récapitulative du score
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(TwSpace.s5),
                            decoration: BoxDecoration(
                              color: context.tw.surface,
                              borderRadius: TwRadius.r3xl,
                              border: Border.all(color: context.tw.border),
                              boxShadow: TwShadow.md(context),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  context.tr('your_score'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: context.tw.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: TwSpace.s2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TwSpace.s35,
                                    vertical: TwSpace.s15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: percentage >= 50 ? context.tw.brandTint : TwTone.danger.tint(context),
                                    borderRadius: TwRadius.r2xl,
                                  ),
                                  child: Text(
                                    context.tr('success_rate', {'pct': percentage.toStringAsFixed(0)}),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: percentage >= 50
                                          ? (TwSurface.isDark(context) ? TwColors.gold400 : TwColors.brand700)
                                          : context.tw.danger,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: TwSpace.s3),
                                Text(
                                  appreciation,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.tw.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: TwSpace.s5),

                          // Bouton Étape suivante (si débloquée)
                          if (hasNextStage && nextStage != null) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        category: widget.category,
                                        level: widget.level,
                                        stage: nextStage,
                                        options: widget.options,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward, size: 20),
                                label: Text(
                                  context.tr('next_stage'),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: TwSpace.s4),
                                ),
                              ),
                            ),
                            const SizedBox(height: TwSpace.s3),
                          ],

                          // Bouton voir les corrections
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final navigator = Navigator.of(context);
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (_) => CorrectionScreen(
                                      questions: widget.questions,
                                      userAnswers: widget.userAnswers,
                                      // Footer de la correction : recommencer ce quiz
                                      onRestart: () {
                                        navigator.pop(); // ferme la correction
                                        navigator.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => QuizScreen(
                                              category: widget.category,
                                              level: widget.level,
                                              stage: widget.stage,
                                              options: widget.options,
                                            ),
                                          ),
                                        );
                                      },
                                      // … ou retour à l'accueil
                                      onHome: () => navigator.popUntil((route) => route.isFirst),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 20),
                              label: Text(
                                context.tr('view_corrections'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: TwSpace.s35),
                              ),
                            ),
                          ),

                          const SizedBox(height: TwSpace.s3),

                          // Bouton recommencer
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      category: widget.category,
                                      level: widget.level,
                                      stage: widget.stage,
                                      options: widget.options,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh, size: 20),
                              label: Text(
                                context.tr('restart_quiz'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: TwSpace.s35),
                              ),
                            ),
                          ),

                          const SizedBox(height: TwSpace.s3),

                          // Bouton retour au parcours
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.route_outlined, size: 20, color: context.tw.textSecondary),
                              label: Text(
                                context.tr('back_to_levels'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.tw.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: TwSpace.s5),
                        ],
                      ),
                    ),
                  ),

                  const AppFooter(),
                ],
              ),
            ),

            // Confettis de célébration (si score >= 80%)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  TwColors.gold500,
                  TwColors.brand600,
                  TwColors.gold400,
                  Color(0xFF2E639A),
                ],
                numberOfParticles: 25,
                gravity: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Anneau Circulaire de Progression avec Compteur Animé
  // ---------------------------------------------------------------------------
  Widget _buildCircularScoreRing({
    required double percentage,
    required Color trophyColor,
    required IconData trophyIcon,
    required int total,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage / 100),
      duration: const Duration(milliseconds: 1100),
      curve: TwMotion.emphasized,
      builder: (context, value, _) {
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle de fond
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.tw.border.withValues(alpha: 0.6),
                  ),
                ),
              ),

              // Progression circulaire
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(trophyColor),
                ),
              ),

              // Contenu central : Score qui monte de 0 à widget.score
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trophyIcon, color: trophyColor, size: 28),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: widget.score),
                      duration: const Duration(milliseconds: 1100),
                      curve: TwMotion.emphasized,
                      builder: (context, val, _) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$val',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: context.tw.textPrimary,
                              ),
                            ),
                            Text(
                              ' / $total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.tw.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
