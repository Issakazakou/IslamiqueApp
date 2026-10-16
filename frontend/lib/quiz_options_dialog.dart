import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'stage_progress_manager.dart';
import 'widgets.dart';

/// Modal Bottom Sheet pour régler les options du Quiz
class QuizOptionsSheet extends StatefulWidget {
  const QuizOptionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuizOptionsSheet(),
    );
  }

  @override
  State<QuizOptionsSheet> createState() => _QuizOptionsSheetState();
}

class _QuizOptionsSheetState extends State<QuizOptionsSheet> {
  late bool _timerEnabled;
  late int _timerSeconds;
  late int _questionCount;
  late bool _instantFeedback;
  late bool _livesEnabled;

  @override
  void initState() {
    super.initState();
    final opt = StageProgressManager.instance.options;
    _timerEnabled = opt.timerEnabled;
    _timerSeconds = opt.timerSeconds;
    _questionCount = opt.questionCount;
    _instantFeedback = opt.instantFeedback;
    _livesEnabled = opt.livesEnabled;
  }

  void _save() {
    final updated = QuizOptions(
      timerEnabled: _timerEnabled,
      timerSeconds: _timerSeconds,
      questionCount: _questionCount,
      instantFeedback: _instantFeedback,
      livesEnabled: _livesEnabled,
      livesCount: 3,
    );
    StageProgressManager.instance.updateOptions(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final accent = TwSurface.isDark(context) ? TwColors.gold400 : TwColors.brand600;

    return Container(
      decoration: BoxDecoration(
        color: tw.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: tw.border)),
        boxShadow: TwShadow.lg(context),
      ),
      padding: EdgeInsets.only(
        left: TwSpace.s5,
        right: TwSpace.s5,
        top: TwSpace.s4,
        bottom: MediaQuery.of(context).viewInsets.bottom + TwSpace.s5,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre indicateur
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tw.border,
                    borderRadius: TwRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: TwSpace.s4),

              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(TwSpace.s2),
                    decoration: BoxDecoration(
                      color: tw.brandTint,
                      borderRadius: TwRadius.rXl,
                    ),
                    child: Icon(Icons.tune_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: TwSpace.s3),
                  Expanded(
                    child: Text(
                      context.tr('options_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: TwWeight.extrabold,
                        color: tw.textPrimary,
                      ),
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: TwSpace.s4),

              // Option 1 : Chronomètre
              _buildSwitchTile(
                icon: Icons.timer_outlined,
                iconColor: TwColors.gold500,
                title: context.tr('opt_timer'),
                subtitle: context.tr('opt_timer_desc'),
                value: _timerEnabled,
                onChanged: (val) => setState(() => _timerEnabled = val),
              ),
              _divider(),

              // Option 2 : Mode 3 Vies
              _buildSwitchTile(
                icon: Icons.favorite_rounded,
                iconColor: tw.danger,
                title: context.tr('opt_lives'),
                subtitle: context.tr('opt_lives_desc'),
                value: _livesEnabled,
                onChanged: (val) => setState(() => _livesEnabled = val),
              ),
              _divider(),

              // Option 3 : Correction directe
              _buildSwitchTile(
                icon: Icons.checklist_rounded,
                iconColor: tw.primary,
                title: context.tr('opt_instant_feedback'),
                subtitle: context.tr('opt_instant_feedback_desc'),
                value: _instantFeedback,
                onChanged: (val) => setState(() => _instantFeedback = val),
              ),
              _divider(),

              // Option 4 : Nombre de questions (Mode Rapide)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(TwSpace.s2),
                    decoration: BoxDecoration(
                      color: tw.brandTint,
                      borderRadius: TwRadius.rXl,
                    ),
                    child: Icon(Icons.help_outline_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: TwSpace.s3),
                  Expanded(
                    child: Text(
                      context.tr('opt_question_count'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: TwWeight.bold,
                        color: tw.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TwSpace.s25),
              Row(
                children: [5, 10, 15, 20].map((count) {
                  final isSel = _questionCount == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TwSpace.s1),
                      child: Semantics(
                        button: true,
                        selected: isSel,
                        label: '$count',
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: () => setState(() => _questionCount = count),
                          borderRadius: TwRadius.pill,
                          child: AnimatedContainer(
                            duration: TwMotion.d150,
                            padding: const EdgeInsets.symmetric(vertical: TwSpace.s25),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? tw.primary : tw.background,
                              borderRadius: TwRadius.pill,
                              border: Border.all(color: isSel ? tw.primary : tw.border),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: TwWeight.bold,
                                fontSize: 14,
                                color: isSel ? Colors.white : tw.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: TwSpace.s5),

              // Bouton Valider
              TwButton(
                label: context.tr('apply'),
                size: TwButtonSize.lg,
                isFullWidth: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: TwSpace.s3),
        child: Divider(color: context.tw.border, height: 1),
      );

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tw = context.tw;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(TwSpace.s2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: TwRadius.rXl,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: TwSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: TwWeight.bold,
                  color: tw.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  color: tw.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: title,
          child: Switch.adaptive(
            value: value,
            activeTrackColor: tw.primary,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
