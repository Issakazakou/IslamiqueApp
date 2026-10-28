import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_strings.dart';
import 'category_progress.dart';
import 'level_screen.dart';
import 'quiz_models.dart';
import 'theme/theme.dart';
import 'widgets.dart';

/// ---------------------------------------------------------------------------
/// Écran d'un groupe de catégories (ex. Coran → Méditer, Tajwid, Culture).
/// Chaque sous-catégorie ouvre ses niveaux et ses quiz (LevelScreen).
/// ---------------------------------------------------------------------------
class CategoryGroupScreen extends StatelessWidget {
  final QuizCategory group;

  const CategoryGroupScreen({super.key, required this.group});

  void _open(BuildContext context, QuizCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LevelScreen(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    return Scaffold(
      backgroundColor: tw.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Largeur limitée pour rester lisible sur tablette et web.
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: TwSpace.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BackButton(),
                      const SizedBox(width: TwSpace.s2),
                      Expanded(
                        child: Text(
                          group.titleOf(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TwText.h3(context)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TwSpace.s35),
                  TwSectionHeader(
                    icon: Icons.grid_view_rounded,
                    title: context.tr('group_choose'),
                  ),
                  const SizedBox(height: TwSpace.s3),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        for (final entry in group.children.asMap().entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: TwSpace.s35),
                            child: AppCard(
                              icon: entry.value.icon,
                              iconColor: entry.value.iconColor,
                              iconBackground: entry.value.iconBackground,
                              title: entry.value.titleOf(context),
                              description: entry.value.descriptionOf(context),
                              heroTag: 'category_icon_${entry.value.id}',
                              extra: CategoryProgress(category: entry.value),
                              onTap: () => _open(context, entry.value),
                            )
                                .animate()
                                .fadeIn(
                                  duration: TwMotion.standard,
                                  delay: (entry.key * 60).ms,
                                  curve: TwMotion.emphasized,
                                )
                                .slideY(
                                  begin: 0.08,
                                  end: 0,
                                  duration: TwMotion.standard,
                                  delay: (entry.key * 60).ms,
                                  curve: TwMotion.emphasized,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
