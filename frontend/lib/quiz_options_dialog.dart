import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'stage_progress_manager.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    color: TwColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TwColors.brand100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: TwColors.brand600, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('options_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: TwColors.brand700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: TwColors.slate600),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Option 1 : Chronomètre
              _buildSwitchTile(
                icon: Icons.timer_outlined,
                iconColor: TwColors.gold500,
                title: context.tr('opt_timer'),
                subtitle: context.tr('opt_timer_desc'),
                value: _timerEnabled,
                onChanged: (val) => setState(() => _timerEnabled = val),
              ),
              const Divider(color: TwColors.slate200, height: 20),

              // Option 2 : Mode 3 Vies
              _buildSwitchTile(
                icon: Icons.favorite,
                iconColor: TwColors.danger600,
                title: context.tr('opt_lives'),
                subtitle: context.tr('opt_lives_desc'),
                value: _livesEnabled,
                onChanged: (val) => setState(() => _livesEnabled = val),
              ),
              const Divider(color: TwColors.slate200, height: 20),

              // Option 3 : Correction directe
              _buildSwitchTile(
                icon: Icons.checklist_outlined,
                iconColor: TwColors.brand600,
                title: context.tr('opt_instant_feedback'),
                subtitle: context.tr('opt_instant_feedback_desc'),
                value: _instantFeedback,
                onChanged: (val) => setState(() => _instantFeedback = val),
              ),
              const Divider(color: TwColors.slate200, height: 20),

              // Option 4 : Nombre de questions (Mode Rapide)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TwColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.help_outline, color: TwColors.brand700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('opt_question_count'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TwColors.brand700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [5, 10, 15, 20].map((count) {
                  final isSel = _questionCount == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _questionCount = count),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSel ? TwColors.brand600 : TwColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? TwColors.brand600 : TwColors.slate200,
                            ),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isSel ? Colors.white : TwColors.brand700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Bouton Valider
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TwColors.brand600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('apply'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TwColors.brand700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: TwColors.slate600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: TwColors.brand600,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
