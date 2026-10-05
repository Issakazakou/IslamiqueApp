import 'package:flutter/material.dart';

import 'theme/theme.dart';
import 'app_strings.dart';
import 'quiz_models.dart';
import 'widgets.dart';

class CorrectionScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, int> userAnswers;

  const CorrectionScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.tw.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwSpace.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TwSpace.s4),

              // En-tête
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: TwSpace.s35),
                  Expanded(
                    child: Text(
                      context.tr('corrections_title'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.tw.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TwSpace.s5),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: questions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: TwSpace.s35),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final userAnswer = userAnswers[index];
                    final bonneReponse = question.bonneReponse;
                    final isCorrect =
                        userAnswer != null && userAnswer == bonneReponse;

                    return Container(
                      padding: const EdgeInsets.all(TwSpace.s4),
                      decoration: BoxDecoration(
                        color: context.tw.surface,
                        borderRadius: TwRadius.r2xl,
                        border: Border.all(
                          color: isCorrect
                              ? TwColors.success600.withValues(
                                  alpha: isDark ? 0.5 : 0.35,
                                )
                              : TwColors.danger600.withValues(
                                  alpha: isDark ? 0.5 : 0.35,
                                ),
                          width: 1.2,
                        ),
                        boxShadow: TwShadow.sm(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Numéro et statut (Correct / Incorrect)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TwSpace.s25,
                                    vertical: TwSpace.s1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.tw.border.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: TwRadius.rLg,
                                  ),
                                  child: Text(
                                    context.tr('question_of', {
                                      'current': '${index + 1}',
                                      'total': '${questions.length}',
                                    }),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: context.tw.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: TwSpace.s2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TwSpace.s25,
                                  vertical: TwSpace.s1,
                                ),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? (isDark
                                            ? TwColors.successDark
                                            : TwColors.success50)
                                      : (isDark
                                            ? TwColors.dangerDark
                                            : TwColors.danger50),
                                  borderRadius: TwRadius.rXl,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 14,
                                      color: isCorrect
                                          ? TwColors.success600
                                          : TwColors.danger600,
                                    ),
                                    const SizedBox(width: TwSpace.s1),
                                    Text(
                                      isCorrect
                                          ? context.tr('correct')
                                          : context.tr('incorrect'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isCorrect
                                            ? TwColors.success600
                                            : TwColors.danger600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: TwSpace.s3),

                          // Énoncé de la question
                          Text(
                            question.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.tw.textPrimary,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: TwSpace.s35),

                          // Réponse de l'utilisateur
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(TwSpace.s3),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? (isDark
                                        ? TwColors.successDark
                                        : TwColors.success50)
                                  : (isDark
                                        ? TwColors.dangerDark
                                        : TwColors.danger50),
                              borderRadius: TwRadius.rXl,
                              border: Border.all(
                                color: isCorrect
                                    ? TwColors.success600.withValues(alpha: 0.3)
                                    : TwColors.danger600.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      size: 14,
                                      color: isCorrect
                                          ? TwColors.success600
                                          : TwColors.danger600,
                                    ),
                                    const SizedBox(width: TwSpace.s15),
                                    Text(
                                      context.tr('your_answer'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isCorrect
                                            ? TwColors.success600
                                            : TwColors.danger600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: TwSpace.s1),
                                Text(
                                  userAnswer != null &&
                                          userAnswer >= 0 &&
                                          userAnswer < question.options.length
                                      ? question.options[userAnswer]
                                      : context.tr('no_answer'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect
                                        ? context.tw.textPrimary
                                        : TwColors.danger600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Si la réponse était fausse, afficher la bonne réponse
                          if (!isCorrect &&
                              bonneReponse != null &&
                              bonneReponse >= 0 &&
                              bonneReponse < question.options.length) ...[
                            const SizedBox(height: TwSpace.s2),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(TwSpace.s3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? TwColors.successDark
                                    : TwColors.success50,
                                borderRadius: TwRadius.rXl,
                                border: Border.all(
                                  color: TwColors.success600.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 14,
                                        color: TwColors.success600,
                                      ),
                                      const SizedBox(width: TwSpace.s15),
                                      Text(
                                        context.tr('correct_answer_label'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: TwColors.success600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: TwSpace.s1),
                                  Text(
                                    question.options[bonneReponse],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.tw.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: TwSpace.s25),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
