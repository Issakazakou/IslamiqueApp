import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// AppColors : Palette de couleurs de l'application "Quiz Islamique"
/// Émeraudes profondes, dorures islamiques, nuances claires et sombres.
/// Conserve l'intégralité des noms existants pour une compatibilité parfaite.
/// ---------------------------------------------------------------------------
class AppColors {
  // ── Marque principale (Vert Émeraude Islamique) ───────────────────────────
  static const Color primary        = Color(0xFF14573F);
  static const Color primaryDark    = Color(0xFF0E3B2C);
  static const Color primaryLight   = Color(0xFF1F7E5C);
  static const Color primaryTint    = Color(0xFFE3F0EA);

  // ── Or et Reflets (Dorure Islamique) ──────────────────────────────────────
  static const Color gold           = Color(0xFFC99A3B);
  static const Color goldLight      = Color(0xFFDFC173);
  static const Color goldDark       = Color(0xFF9E7728);
  static const Color goldTint       = Color(0xFFF8EDD5);
  static const Color badgeBackground= Color(0xFFF5EBD6);

  // ── Neutres & Surfaces (Mode Clair) ───────────────────────────────────────
  static const Color background     = Color(0xFFF7F8F5);
  static const Color surface        = Colors.white;
  static const Color surfaceElevated= Color(0xFFFFFFFF);
  static const Color card           = Colors.white;
  static const Color border         = Color(0xFFE4E8E4);
  static const Color outline        = Color(0xFFD3DCD5);
  static const Color textPrimary    = Color(0xFF0E251C);
  static const Color textSecondary  = Color(0xFF66746D);
  static const Color textMuted      = Color(0xFF8E9E96);

  // ── Neutres & Surfaces (Mode Sombre - Nuit d'Émeraude) ─────────────────────
  static const Color darkBackground      = Color(0xFF0C1713);
  static const Color darkSurface         = Color(0xFF14241E);
  static const Color darkSurfaceElevated = Color(0xFF1B3028);
  static const Color darkCard            = Color(0xFF14241E);
  static const Color darkBorder          = Color(0xFF223A30);
  static const Color darkOutline         = Color(0xFF2B473C);
  static const Color darkPrimaryTint     = Color(0xFF19382B);
  static const Color darkGoldTint        = Color(0xFF332A17);
  static const Color darkTextPrimary     = Color(0xFFF0F5F2);
  static const Color darkTextSecondary   = Color(0xFFA1B5AA);
  static const Color darkTextMuted       = Color(0xFF6F8378);

  // ── Feedback & Alertes ────────────────────────────────────────────────────
  static const Color success        = Color(0xFF2E7D32);
  static const Color successTint    = Color(0xFFE8F5E9);
  static const Color darkSuccessTint= Color(0xFF1B3320);

  static const Color error          = Color(0xFFC62828);
  static const Color errorTint      = Color(0xFFFFEBEE);
  static const Color darkErrorTint  = Color(0xFF381A1A);

  static const Color warning        = Color(0xFFE65100);
  static const Color warningTint    = Color(0xFFFFF3E0);

  // ── Premium / Pro ─────────────────────────────────────────────────────────
  static const Color premium             = Color(0xFFB8860B);
  static const Color premiumLight        = Color(0xFFFFF8E1);
  static const Color premiumGradientStart= Color(0xFFC99A3B);
  static const Color premiumGradientEnd  = Color(0xFF8B6914);

  // ── Dégradés Signature (Gradients) ────────────────────────────────────────
  static const LinearGradient emeraldHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0E3B2C),
      Color(0xFF14573F),
      Color(0xFF1A6B4E),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDFC173),
      Color(0xFFC99A3B),
      Color(0xFF9E7728),
    ],
  );

  static const LinearGradient cardGlowLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Color(0xFFF9FAF8),
    ],
  );

  static const LinearGradient cardGlowDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF182B24),
      Color(0xFF13221C),
    ],
  );
}

/// Extension pratique sur BuildContext pour accéder directement aux couleurs thématiques
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get themeBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get themeSurface =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get themeCard =>
      isDarkMode ? AppColors.darkCard : AppColors.card;

  Color get themeBorder =>
      isDarkMode ? AppColors.darkBorder : AppColors.border;

  Color get themePrimaryTint =>
      isDarkMode ? AppColors.darkPrimaryTint : AppColors.primaryTint;

  Color get themeGoldTint =>
      isDarkMode ? AppColors.darkGoldTint : AppColors.goldTint;

  Color get themeTextPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get themeTextSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get themeTextMuted =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted;
}
