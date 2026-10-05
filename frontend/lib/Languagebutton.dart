import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'app_colors.dart';

/// Petit menu pour choisir la langue. À placer par exemple dans la barre
/// supérieure de l'écran d'accueil : const LanguageButton()
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;

    return PopupMenuButton<String>(
      tooltip: context.tr('language'),
      icon: const Icon(Icons.language, color: AppColors.primaryDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (code) => LanguageController.instance.setLanguage(code),
      itemBuilder: (_) => [
        _item('fr', 'Français', current),
        _item('en', 'English', current),
        _item('ar', 'العربية', current),
      ],
    );
  }

  PopupMenuItem<String> _item(String code, String label, String current) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (code == current)
            const Icon(Icons.check, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}