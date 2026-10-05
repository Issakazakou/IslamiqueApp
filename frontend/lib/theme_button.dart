import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'theme/theme.dart';

/// Bouton de bascule du mode de thème (Clair / Sombre)
/// À placer dans la barre d'en-tête de l'application.
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDark(context);

        final label = isDark ? context.tr('theme_light') : context.tr('theme_dark');
        return Semantics(
          button: true,
          label: label,
          child: IconButton(
            tooltip: label,
            icon: AnimatedSwitcher(
              duration: TwMotion.d300,
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                key: ValueKey<bool>(isDark),
                color: isDark ? TwColors.gold400 : Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
            ),
            onPressed: () => ThemeController.instance.toggleTheme(context),
          ),
        );
      },
    );
  }
}
