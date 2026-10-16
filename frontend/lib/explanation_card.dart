import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Carte « Explication + source » affichée après la réponse à une question.
class ExplanationCard extends StatelessWidget {
  final String? explication;
  final String? source;

  const ExplanationCard({super.key, this.explication, this.source});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasExplanation = explication != null && explication!.isNotEmpty;
    final hasSource = source != null && source!.isNotEmpty;
    if (!hasExplanation && !hasSource) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                context.tr('explanation_title'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          if (hasExplanation) ...[
            const SizedBox(height: 8),
            Text(explication!, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
          if (hasSource) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${context.tr('source_label')} : $source',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
