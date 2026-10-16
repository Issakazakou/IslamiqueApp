import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'widgets.dart';

/// ---------------------------------------------------------------------------
/// Composants de l'écran « Corrections » (design Figma : Corrections / Light|Dark)
///
/// Tout est construit avec le design system existant :
///   couleurs  → context.tw.* et TwTone
///   rayons    → TwRadius.* (20 px : AppTokens.rounded20)
///   ombres    → TwShadow.*
///   boutons   → TwButton, séparateur → AppFooter (TwDivider)
/// ---------------------------------------------------------------------------

enum AnswerStatus { correct, incorrect, unanswered }

enum CorrectionFilter { all, correct, incorrect }

/// Couleurs sémantiques d'un statut (texte/icône, fond teinté, bordure).
class _Tone {
  final Color fg;
  final Color bg;
  final Color border;
  const _Tone({required this.fg, required this.bg, required this.border});
}

_Tone _toneOf(BuildContext context, AnswerStatus status) {
  final tw = context.tw;
  switch (status) {
    case AnswerStatus.correct:
      return _Tone(fg: tw.success, bg: TwTone.success.tint(context), border: tw.success);
    case AnswerStatus.incorrect:
      return _Tone(fg: tw.danger, bg: TwTone.danger.tint(context), border: tw.danger);
    case AnswerStatus.unanswered:
      return _Tone(fg: tw.textSecondary, bg: TwTone.neutral.tint(context), border: tw.border);
  }
}

/// Couleur d'accent des textes sur fond teinté : émeraude en clair, or en sombre.
Color _accent(BuildContext context) =>
    TwSurface.isDark(context) ? TwColors.gold400 : TwColors.brand600;

bool _validIndex(int? i, int length) => i != null && i >= 0 && i < length;

/// Motif géométrique islamique discret (réutilise IslamicPatternPainter).
class _PatternLayer extends StatelessWidget {
  const _PatternLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: IslamicPatternPainter(
            color: TwColors.gold500,
            opacity: TwSurface.isDark(context) ? 0.09 : 0.08,
            scale: 44,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Entrée en cascade (staggered) — respecte « réduire les animations »
/// ---------------------------------------------------------------------------
class StaggeredEntrance extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggeredEntrance({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;

    final delayMs = math.min(index, 6) * 70;
    const baseMs = 340;
    final totalMs = baseMs + delayMs;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: TwMotion.emphasized,
      child: child,
      builder: (context, t, child) {
        final p = ((t * totalMs - delayMs) / baseMs).clamp(0.0, 1.0);
        return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(0, 16 * (1 - p)), child: child),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Badge de statut : ✓ Correct / ✗ Incorrect / — Sans réponse
/// ---------------------------------------------------------------------------
class CorrectionStatusBadge extends StatelessWidget {
  final AnswerStatus status;

  const CorrectionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _toneOf(context, status);
    final IconData icon;
    final String label;
    switch (status) {
      case AnswerStatus.correct:
        icon = Icons.check_circle_outline_rounded;
        label = context.tr('correct');
        break;
      case AnswerStatus.incorrect:
        icon = Icons.cancel_outlined;
        label = context.tr('incorrect');
        break;
      case AnswerStatus.unanswered:
        icon = Icons.remove_circle_outline_rounded;
        label = context.tr('unanswered');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TwSpace.s25, vertical: TwSpace.s1),
      decoration: BoxDecoration(color: tone.bg, borderRadius: TwRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone.fg),
          const SizedBox(width: TwSpace.s1),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: TwWeight.extrabold, color: tone.fg),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Bloc de réponse (« Votre réponse » / « Bonne réponse »)
/// ---------------------------------------------------------------------------
class CorrectionAnswerBlock extends StatelessWidget {
  final AnswerStatus status;
  final IconData icon;
  final String label;
  final String text;
  final Color? textColor;

  const CorrectionAnswerBlock({
    super.key,
    required this.status,
    required this.icon,
    required this.label,
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _toneOf(context, status);
    final hasTint = status != AnswerStatus.unanswered;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TwSpace.s3),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: TwRadius.r2xl,
        border: Border.all(color: tone.border.withValues(alpha: hasTint ? 0.3 : 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone.fg),
              const SizedBox(width: TwSpace.s15),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: TwWeight.bold, color: tone.fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwSpace.s15),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: TwWeight.semibold,
              height: 1.4,
              color: textColor ?? context.tw.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Explication repliable (💡) — affichée seulement si un texte est fourni
/// ---------------------------------------------------------------------------
class CorrectionExplanationTile extends StatefulWidget {
  final String text;

  const CorrectionExplanationTile({super.key, required this.text});

  @override
  State<CorrectionExplanationTile> createState() => _CorrectionExplanationTileState();
}

class _CorrectionExplanationTileState extends State<CorrectionExplanationTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);

    return Semantics(
      button: true,
      expanded: _open,
      label: context.tr('explanation'),
      child: Material(
        color: context.tw.brandTint,
        borderRadius: TwRadius.r2xl,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TwSpace.s3, vertical: TwSpace.s25),
            child: AnimatedSize(
              duration: TwMotion.d200,
              curve: TwMotion.easeOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 16, color: accent),
                      const SizedBox(width: TwSpace.s2),
                      Expanded(
                        child: Text(
                          context.tr('explanation'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: TwWeight.semibold,
                            color: accent,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: TwMotion.d200,
                        child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: accent),
                      ),
                    ],
                  ),
                  if (_open) ...[
                    const SizedBox(height: TwSpace.s2),
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: context.tw.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Carte de correction d'une question (Card / Correct | Incorrect | Unanswered)
/// ---------------------------------------------------------------------------
class CorrectionCard extends StatelessWidget {
  final int number;
  final int total;
  final QuizQuestion question;
  final int? userAnswer;
  final String? explanation;

  const CorrectionCard({
    super.key,
    required this.number,
    required this.total,
    required this.question,
    required this.userAnswer,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    final correctIndex = question.bonneReponse;

    final answered = _validIndex(userAnswer, options.length);
    final status = !answered
        ? AnswerStatus.unanswered
        : (userAnswer == correctIndex ? AnswerStatus.correct : AnswerStatus.incorrect);
    final tone = _toneOf(context, status);

    final IconData userIcon = status == AnswerStatus.correct
        ? Icons.check_rounded
        : status == AnswerStatus.incorrect
            ? Icons.close_rounded
            : Icons.remove_rounded;

    final showCorrect = status != AnswerStatus.correct && _validIndex(correctIndex, options.length);

    return Container(
      padding: const EdgeInsets.all(TwSpace.s4),
      decoration: BoxDecoration(
        color: context.tw.surface,
        borderRadius: AppTokens.rounded20,
        border: Border.all(
          color: status == AnswerStatus.unanswered
              ? context.tw.border
              : tone.border.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: TwShadow.sm(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro + statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: TwSpace.s25, vertical: TwSpace.s1),
                  decoration: BoxDecoration(
                    color: TwTone.neutral.tint(context),
                    borderRadius: TwRadius.pill,
                  ),
                  child: Text(
                    context.tr('question_of', {
                      'current': '$number',
                      'total': '$total',
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: TwWeight.bold,
                      color: context.tw.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TwSpace.s2),
              CorrectionStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: TwSpace.s3),

          // Énoncé
          Text(
            question.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: TwWeight.bold,
              height: 1.35,
              color: context.tw.textPrimary,
            ),
          ),
          const SizedBox(height: TwSpace.s3),

          // Réponse de l'utilisateur
          CorrectionAnswerBlock(
            status: status,
            icon: userIcon,
            label: context.tr('your_answer'),
            text: answered ? options[userAnswer!] : context.tr('no_answer'),
            textColor: status == AnswerStatus.incorrect ? context.tw.danger : null,
          ),

          // Bonne réponse (si fausse ou sans réponse)
          if (showCorrect) ...[
            const SizedBox(height: TwSpace.s3),
            CorrectionAnswerBlock(
              status: AnswerStatus.correct,
              icon: Icons.check_circle_outline_rounded,
              label: context.tr('correct_answer_label'),
              text: options[correctIndex!],
            ),
          ],

          // Explication (optionnelle)
          if (explanation != null && explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: TwSpace.s3),
            CorrectionExplanationTile(text: explanation!),
          ],
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Carte de résumé (dégradé + motif islamique discret)
/// ---------------------------------------------------------------------------
class CorrectionSummaryCard extends StatelessWidget {
  final int correct;
  final int incorrect;
  final int unanswered;

  const CorrectionSummaryCard({
    super.key,
    required this.correct,
    required this.incorrect,
    required this.unanswered,
  });

  int get total => correct + incorrect + unanswered;

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    final percent = total == 0 ? 0.0 : correct * 100 / total;
    final headline = percent >= 70 ? context.tr('good_job') : context.tr('keep_going');

    // Émeraude très doux → crème doré (clair) / surface sombre (sombre)
    final endColor =
        isDark ? tw.surface : Color.alphaBlend(tw.goldTint.withValues(alpha: 0.5), tw.surface);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [tw.brandTint, endColor],
        ),
        borderRadius: AppTokens.rounded20,
        border: Border.all(color: tw.primary.withValues(alpha: 0.2)),
        boxShadow: TwShadow.md(context),
      ),
      child: Stack(
        children: [
          const _PatternLayer(),
          Padding(
            padding: const EdgeInsets.all(TwSpace.s5),
            child: Row(
              children: [
                ScoreRing(percent: percent),
                const SizedBox(width: TwSpace.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: TwWeight.extrabold,
                          color: tw.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TwSpace.s2),
                      _StatRow(
                        icon: Icons.check_rounded,
                        color: tw.success,
                        text: context.tr('correct_count', {'count': '$correct'}),
                      ),
                      const SizedBox(height: TwSpace.s2),
                      _StatRow(
                        icon: Icons.close_rounded,
                        color: tw.danger,
                        text: context.tr('incorrect_count', {'count': '$incorrect'}),
                      ),
                      const SizedBox(height: TwSpace.s2),
                      _StatRow(
                        icon: Icons.remove_rounded,
                        color: tw.textSecondary,
                        text: context.tr('unanswered_count', {'count': '$unanswered'}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _StatRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: TwSpace.s2),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: TwWeight.bold,
              color: context.tw.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Bannière « Score parfait »
/// ---------------------------------------------------------------------------
class PerfectScoreBanner extends StatelessWidget {
  const PerfectScoreBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);
    final start = TwTone.success.tint(context);
    final end = isDark ? tw.surface : Color.alphaBlend(tw.success.withValues(alpha: 0.12), start);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [start, end],
        ),
        borderRadius: AppTokens.rounded20,
        border: Border.all(color: tw.success.withValues(alpha: 0.4), width: 1.2),
        boxShadow: TwShadow.md(context),
      ),
      child: Stack(
        children: [
          const _PatternLayer(),
          Padding(
            padding: const EdgeInsets.all(TwSpace.s5),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: tw.success, shape: BoxShape.circle),
                  child: const Icon(Icons.emoji_events_outlined, size: 32, color: Colors.white),
                ),
                const SizedBox(width: TwSpace.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('perfect_score'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: TwWeight.extrabold,
                          color: tw.success,
                        ),
                      ),
                      const SizedBox(height: TwSpace.s1),
                      Text(
                        context.tr('perfect_score_desc'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: TwWeight.semibold,
                          height: 1.4,
                          color: tw.textSecondary,
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
    );
  }
}

/// ---------------------------------------------------------------------------
/// Filtres : Toutes | Correctes | Incorrectes
/// ---------------------------------------------------------------------------
class CorrectionFilterChips extends StatelessWidget {
  final CorrectionFilter selected;
  final ValueChanged<CorrectionFilter> onChanged;

  const CorrectionFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <CorrectionFilter, String>{
      CorrectionFilter.all: context.tr('filter_all'),
      CorrectionFilter.correct: context.tr('filter_correct'),
      CorrectionFilter.incorrect: context.tr('filter_incorrect'),
    };
    final entries = labels.entries.toList();

    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: TwSpace.s2),
          Expanded(
            child: _FilterChip(
              label: entries[i].value,
              active: entries[i].key == selected,
              onTap: () => onChanged(entries[i].key),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: AnimatedContainer(
        duration: TwMotion.d200,
        curve: TwMotion.easeOut,
        decoration: BoxDecoration(
          color: active ? tw.primary : tw.surface,
          borderRadius: TwRadius.pill,
          border: Border.all(color: active ? tw.primary : tw.border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: tw.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: TwRadius.pill,
          child: InkWell(
            borderRadius: TwRadius.pill,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TwSpace.s25, horizontal: TwSpace.s15),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: TwWeight.bold,
                      color: active ? Colors.white : tw.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// État vide (réutilise TwEmptyState du design system)
/// ---------------------------------------------------------------------------
class CorrectionEmptyState extends StatelessWidget {
  const CorrectionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return TwEmptyState(
      icon: Icons.lightbulb_outline_rounded,
      tone: TwTone.brand,
      title: context.tr('no_corrections'),
      message: context.tr('no_corrections_desc'),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Footer fixe : boutons (TwButton) + séparateur orné (AppFooter)
/// ---------------------------------------------------------------------------
class CorrectionFooter extends StatelessWidget {
  final VoidCallback? onRestart;
  final VoidCallback? onHome;

  const CorrectionFooter({super.key, this.onRestart, this.onHome});

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(TwSpace.s5, TwSpace.s4, TwSpace.s5, TwSpace.s05),
      decoration: BoxDecoration(
        color: tw.surface,
        border: Border(top: BorderSide(color: tw.border, width: TwBorder.thin)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRestart != null)
              TwButton(
                label: context.tr('restart_quiz'),
                icon: Icons.replay_rounded,
                size: TwButtonSize.lg,
                isFullWidth: true,
                onPressed: onRestart,
              ),
            if (onHome != null) ...[
              const SizedBox(height: TwSpace.s1),
              TwButton(
                label: context.tr('back_home'),
                variant: TwButtonVariant.ghost,
                isFullWidth: true,
                onPressed: onHome,
              ),
            ],
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
