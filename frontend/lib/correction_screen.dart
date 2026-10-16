import 'package:flutter/material.dart';

import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'theme_button.dart';
import 'widgets.dart';
import 'correction_widgets.dart';

/// ---------------------------------------------------------------------------
/// Écran de correction du quiz (design Figma : « Corrections »)
///
/// - [questions]    : liste des questions (avec `bonneReponse` renseignée par le serveur)
/// - [userAnswers]  : index de la question -> index de l'option choisie (-1 = temps écoulé)
/// - [explanations] : (optionnel) index de la question -> texte d'explication
/// - [onRestart] / [onHome] : (optionnels) affichent les boutons du footer fixe
/// ---------------------------------------------------------------------------
class CorrectionScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Map<int, int> userAnswers;
  final Map<int, String>? explanations;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;

  const CorrectionScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    this.explanations,
    this.onRestart,
    this.onHome,
  });

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  CorrectionFilter _filter = CorrectionFilter.all;

  AnswerStatus _statusOf(int index) {
    final question = widget.questions[index];
    final answer = widget.userAnswers[index];
    final valid = answer != null && answer >= 0 && answer < question.options.length;
    if (!valid) return AnswerStatus.unanswered;
    return answer == question.bonneReponse ? AnswerStatus.correct : AnswerStatus.incorrect;
  }

  bool _matchesFilter(AnswerStatus status) {
    switch (_filter) {
      case CorrectionFilter.all:
        return true;
      case CorrectionFilter.correct:
        return status == AnswerStatus.correct;
      case CorrectionFilter.incorrect:
        // « Incorrectes » regroupe les fausses réponses et les questions sans réponse
        return status != AnswerStatus.correct;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;

    var correct = 0, incorrect = 0, unanswered = 0;
    for (var i = 0; i < total; i++) {
      switch (_statusOf(i)) {
        case AnswerStatus.correct:
          correct++;
          break;
        case AnswerStatus.incorrect:
          incorrect++;
          break;
        case AnswerStatus.unanswered:
          unanswered++;
          break;
      }
    }

    final isPerfect = total > 0 && correct == total;
    final visible = <int>[
      for (var i = 0; i < total; i++)
        if (_matchesFilter(_statusOf(i))) i,
    ];

    return Scaffold(
      backgroundColor: context.tw.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── En-tête ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(TwSpace.s5, TwSpace.s4, TwSpace.s5, TwSpace.s3),
              child: _Header(correct: correct, total: total),
            ),

            // ── Contenu ────────────────────────────────────────────────
            Expanded(
              child: total == 0
                  ? const CorrectionEmptyState()
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        TwSpace.s5,
                        TwSpace.s2,
                        TwSpace.s5,
                        TwSpace.s5,
                      ),
                      children: [
                        StaggeredEntrance(
                          index: 0,
                          child: isPerfect
                              ? const PerfectScoreBanner()
                              : CorrectionSummaryCard(
                                  correct: correct,
                                  incorrect: incorrect,
                                  unanswered: unanswered,
                                ),
                        ),
                        const SizedBox(height: TwSpace.s4),
                        StaggeredEntrance(
                          index: 1,
                          child: CorrectionFilterChips(
                            selected: _filter,
                            onChanged: (f) => setState(() => _filter = f),
                          ),
                        ),
                        const SizedBox(height: TwSpace.s4),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: TwSpace.s6),
                            child: Center(
                              child: Text(
                                context.tr('no_corrections'),
                                style: TextStyle(fontSize: 14, color: context.tw.textSecondary),
                              ),
                            ),
                          )
                        else
                          for (var n = 0; n < visible.length; n++) ...[
                            if (n > 0) const SizedBox(height: TwSpace.s35),
                            StaggeredEntrance(
                              // La clé inclut le filtre : l'animation rejoue quand il change
                              key: ValueKey('${_filter.name}-${visible[n]}'),
                              index: n + 2,
                              child: CorrectionCard(
                                number: visible[n] + 1,
                                total: total,
                                question: widget.questions[visible[n]],
                                userAnswer: widget.userAnswers[visible[n]],
                                explanation: widget.explanations?[visible[n]],
                              ),
                            ),
                          ],
                      ],
                    ),
            ),

            // ── Footer fixe ────────────────────────────────────────────
            CorrectionFooter(
              onRestart: widget.onRestart,
              onHome: widget.onHome,
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête : retour + titre + bouton de thème + pastille de score
class _Header extends StatelessWidget {
  final int correct;
  final int total;

  const _Header({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final accent = TwSurface.isDark(context) ? TwColors.gold400 : TwColors.brand600;

    return Row(
      children: [
        // Icons.arrow_back se retourne automatiquement en RTL
        RoundIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: TwSpace.s3),
        Expanded(
          child: Text(
            context.tr('corrections_title'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: TwWeight.extrabold,
              color: tw.textPrimary,
            ),
          ),
        ),
        const ThemeButton(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: TwSpace.s3, vertical: TwSpace.s15),
          decoration: BoxDecoration(
            color: tw.brandTint,
            borderRadius: TwRadius.pill,
            border: Border.all(color: tw.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$correct/$total',
            style: TextStyle(fontSize: 14, fontWeight: TwWeight.extrabold, color: accent),
          ),
        ),
      ],
    );
  }
}
