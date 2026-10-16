import 'package:flutter/material.dart';

import 'quiz_models.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';
import 'widgets.dart';

/// ---------------------------------------------------------------------------
/// Progression (étoiles) : 5 étapes × 3 étoiles par niveau
/// ---------------------------------------------------------------------------
const int starsPerLevel = 15;
final int starsPerCategory = QuizLevel.values.length * starsPerLevel;

int _leafStars(String categoryId) {
  final manager = StageProgressManager.instance;
  var total = 0;
  for (final level in QuizLevel.values) {
    total += manager.getTotalStars(categoryId, level.apiValue);
  }
  return total;
}

/// Étoiles d'une catégorie (pour un groupe : somme de ses sous-catégories).
int categoryStars(QuizCategory category) =>
    category.leaves.fold<int>(0, (sum, leaf) => sum + _leafStars(leaf.id));

int categoryMaxStars(QuizCategory category) =>
    category.leaves.length * starsPerCategory;

int totalStars() =>
    leafCategories.fold<int>(0, (sum, leaf) => sum + _leafStars(leaf.id));

int totalMaxStars() => leafCategories.length * starsPerCategory;

/// Progression d'une catégorie, affichée dans la carte (slot `extra` d'AppCard).
class CategoryProgress extends StatelessWidget {
  final QuizCategory category;

  const CategoryProgress({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isGold = category.iconBackground == AppColors.goldTint;

    return ListenableBuilder(
      listenable: StageProgressManager.instance,
      builder: (context, _) {
        final stars = categoryStars(category);
        final max = categoryMaxStars(category);

        return Padding(
          padding: const EdgeInsets.only(top: TwSpace.s1),
          child: Row(
            children: [
              Expanded(
                child: TwProgressBar(
                  value: max == 0 ? 0.0 : stars / max,
                  height: 6,
                  tone: TwTone.brand,
                  gradient: isGold ? TwColors.goldGradient : null,
                ),
              ),
              const SizedBox(width: TwSpace.s2),
              const Icon(Icons.star_rounded, size: 12, color: TwColors.gold500),
              const SizedBox(width: 3),
              Text(
                '$stars/$max',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: TwWeight.bold,
                  color: context.tw.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
