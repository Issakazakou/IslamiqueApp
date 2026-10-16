import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// TwColors : Palette de couleurs « Tailwind CSS » adaptée à l'identité
/// islamique de l'application (émeraude + dorure).
///
/// Chaque famille suit l'échelle Tailwind 50 → 950 : `TwColors.brand600`,
/// `TwColors.gold400`, `TwColors.slate200`…
///
/// Rétrocompatibilité : `AppColors` (lib/theme/app_colors.dart) reste la source
/// de vérité historique. `TwColors` est une surcouche additive, strictement
/// alignée sur les mêmes valeurs de marque.
/// ---------------------------------------------------------------------------
abstract final class TwColors {
  // ══════════════════════════════════════════════════════════════════════════
  //  BRAND — Émeraude islamique (couleur de marque principale)
  // ══════════════════════════════════════════════════════════════════════════
  static const Color brand50  = Color(0xFFE9F4EF);
  static const Color brand100 = Color(0xFFE3F0EA); // = AppColors.primaryTint
  static const Color brand200 = Color(0xFFBFDCCF);
  static const Color brand300 = Color(0xFF8FC2AC);
  static const Color brand400 = Color(0xFF4C9C7A);
  static const Color brand500 = Color(0xFF1F7E5C); // = AppColors.primaryLight
  static const Color brand600 = Color(0xFF14573F); // = AppColors.primary
  static const Color brand700 = Color(0xFF0E3B2C); // = AppColors.primaryDark
  static const Color brand800 = Color(0xFF0A2C21);
  static const Color brand900 = Color(0xFF071F17);
  static const Color brand950 = Color(0xFF04130E);

  // ══════════════════════════════════════════════════════════════════════════
  //  GOLD — Dorure islamique (couleur d'accent)
  // ══════════════════════════════════════════════════════════════════════════
  static const Color gold50  = Color(0xFFFBF6E9);
  static const Color gold100 = Color(0xFFF8EDD5); // = AppColors.goldTint
  static const Color gold200 = Color(0xFFF0DCAE);
  static const Color gold300 = Color(0xFFE5C67F);
  static const Color gold400 = Color(0xFFDFC173); // = AppColors.goldLight
  static const Color gold500 = Color(0xFFC99A3B); // = AppColors.gold
  static const Color gold600 = Color(0xFFB0812C);
  static const Color gold700 = Color(0xFF9E7728); // = AppColors.goldDark
  static const Color gold800 = Color(0xFF7C5D1F);
  static const Color gold900 = Color(0xFF5C4417);

  // ══════════════════════════════════════════════════════════════════════════
  //  SLATE — Neutres clairs (fonds, bordures, textes en mode clair)
  // ══════════════════════════════════════════════════════════════════════════
  static const Color slate50  = Color(0xFFF7F8F5); // = AppColors.background
  static const Color slate100 = Color(0xFFF0F2EF);
  static const Color slate200 = Color(0xFFE4E8E4); // = AppColors.border
  static const Color slate300 = Color(0xFFD3DCD5); // = AppColors.outline
  static const Color slate400 = Color(0xFFA8B3AC);
  static const Color slate500 = Color(0xFF8E9E96); // = AppColors.textMuted
  static const Color slate600 = Color(0xFF66746D); // = AppColors.textSecondary
  static const Color slate700 = Color(0xFF47544E);
  static const Color slate800 = Color(0xFF2A3833);
  static const Color slate900 = Color(0xFF0E251C); // = AppColors.textPrimary
  static const Color slate950 = Color(0xFF071310);

  // ══════════════════════════════════════════════════════════════════════════
  //  INK — Surfaces sombres (« nuit d'émeraude »)
  // ══════════════════════════════════════════════════════════════════════════
  static const Color ink950 = Color(0xFF0C1713); // = AppColors.darkBackground
  static const Color ink900 = Color(0xFF14241E); // = AppColors.darkSurface
  static const Color ink800 = Color(0xFF1B3028); // = darkSurfaceElevated
  static const Color ink700 = Color(0xFF223A30); // = AppColors.darkBorder
  static const Color ink600 = Color(0xFF2B473C); // = AppColors.darkOutline
  static const Color ink500 = Color(0xFF3C5B4E);

  // ── Teintes sombres (tints « dark mode ») ────────────────────────────────
  static const Color brandTintDark = Color(0xFF19382B); // = darkPrimaryTint
  static const Color goldTintDark  = Color(0xFF332A17); // = darkGoldTint

  // ══════════════════════════════════════════════════════════════════════════
  //  SÉMANTIQUES — Feedback utilisateur
  // ══════════════════════════════════════════════════════════════════════════
  // Success
  static const Color success50   = Color(0xFFE8F5E9);
  static const Color success100  = Color(0xFFC8E6C9);
  static const Color success500  = Color(0xFF43A047);
  static const Color success600  = Color(0xFF2E7D32); // = AppColors.success
  static const Color success700  = Color(0xFF1B5E20);
  static const Color successDark = Color(0xFF1B3320); // tint sombre

  // Danger / Error
  static const Color danger50   = Color(0xFFFFEBEE);
  static const Color danger100  = Color(0xFFFFCDD2);
  static const Color danger500  = Color(0xFFE53935);
  static const Color danger600  = Color(0xFFC62828); // = AppColors.error
  static const Color danger700  = Color(0xFFB71C1C);
  static const Color dangerDark = Color(0xFF381A1A); // tint sombre

  // Warning
  static const Color warning50   = Color(0xFFFFF3E0);
  static const Color warning100  = Color(0xFFFFE0B2);
  static const Color warning500  = Color(0xFFFB8C00);
  static const Color warning600  = Color(0xFFE65100); // = AppColors.warning
  static const Color warning700  = Color(0xFFEF6C00);
  static const Color warningDark = Color(0xFF3A2711); // tint sombre

  // Info
  static const Color info50   = Color(0xFFE3F2FD);
  static const Color info100  = Color(0xFFBBDEFB);
  static const Color info500  = Color(0xFF2196F3);
  static const Color info600  = Color(0xFF1565C0);
  static const Color info700  = Color(0xFF0D47A1);
  static const Color infoDark = Color(0xFF12273A); // tint sombre

  // ══════════════════════════════════════════════════════════════════════════
  //  ALIAS SÉMANTIQUES (raccourcis d'usage quotidien)
  // ══════════════════════════════════════════════════════════════════════════
  static const Color primary      = brand600;
  static const Color primaryDark  = brand700;
  static const Color primaryLight = brand500;
  static const Color accent       = gold500;
  static const Color accentLight  = gold400;
  static const Color success      = success600;
  static const Color danger       = danger600;
  static const Color warning      = warning600;
  static const Color info         = info600;

  // ══════════════════════════════════════════════════════════════════════════
  //  DÉGRADÉS SIGNATURE
  // ══════════════════════════════════════════════════════════════════════════
  /// Dégradé émeraude principal (en-têtes, bannières héroïques)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand700, brand600, Color(0xFF1A6B4E)],
  );

  /// Dégradé émeraude profond (états actifs, en-têtes de quiz)
  static const LinearGradient brandGradientDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand900, brand700, brand600],
  );

  /// Dégradé doré (badges premium, récompenses, scores)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold400, gold500, gold700],
  );

  /// Voile lumineux des cartes en mode clair
  static const LinearGradient cardGlowLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF9FAF8)],
  );

  /// Voile lumineux des cartes en mode sombre
  static const LinearGradient cardGlowDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF182B24), Color(0xFF13221C)],
  );
}

/// ---------------------------------------------------------------------------
/// TwSurface : Résolveur de surfaces theme-aware (clair / sombre).
///
/// Équivalent Flutter des utilitaires Tailwind `bg-white`, `dark:bg-slate-900`,
/// `border-slate-200`, `text-slate-600`… mais centralisé et typé.
///
/// Usage : `TwSurface.card(context)`, `TwSurface.textMuted(context)`.
/// ---------------------------------------------------------------------------
abstract final class TwSurface {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Fonds ────────────────────────────────────────────────────────────────
  /// Fond général de l'écran (équivalent `bg-slate-50` / `dark:bg-ink-950`)
  static Color background(BuildContext c) =>
      isDark(c) ? TwColors.ink950 : TwColors.slate50;

  /// Surface d'une carte (équivalent `bg-white` / `dark:bg-ink-900`)
  static Color card(BuildContext c) =>
      isDark(c) ? TwColors.ink900 : Colors.white;

  /// Surface surélevée (modales, menus, bottom sheets)
  static Color elevated(BuildContext c) =>
      isDark(c) ? TwColors.ink800 : Colors.white;

  /// Surface discrète (champs de saisie, zones neutres)
  static Color subtle(BuildContext c) =>
      isDark(c) ? TwColors.ink800 : TwColors.slate100;

  /// Surface au survol / à l'appui
  static Color hover(BuildContext c) =>
      isDark(c) ? TwColors.ink700 : TwColors.slate100;

  // ── Bordures ─────────────────────────────────────────────────────────────
  /// Bordure standard (équivalent `border-slate-200` / `dark:border-ink-700`)
  static Color border(BuildContext c) =>
      isDark(c) ? TwColors.ink700 : TwColors.slate200;

  /// Bordure marquée (équivalent `border-slate-300`)
  static Color borderStrong(BuildContext c) =>
      isDark(c) ? TwColors.ink600 : TwColors.slate300;

  // ── Textes ───────────────────────────────────────────────────────────────
  /// Texte principal (équivalent `text-slate-900`)
  static Color textPrimary(BuildContext c) =>
      isDark(c) ? const Color(0xFFF0F5F2) : TwColors.slate900;

  /// Texte secondaire (équivalent `text-slate-600`)
  static Color textSecondary(BuildContext c) =>
      isDark(c) ? const Color(0xFFA1B5AA) : TwColors.slate600;

  /// Texte atténué (équivalent `text-slate-500`)
  static Color textMuted(BuildContext c) =>
      isDark(c) ? const Color(0xFF6F8378) : TwColors.slate500;

  /// Teinte émeraude (équivalent `bg-emerald-50` / `dark:bg-emerald-950`)
  static Color brandTint(BuildContext c) =>
      isDark(c) ? const Color(0xFF19382B) : TwColors.brand100;

  /// Teinte dorée (équivalent `bg-amber-50` / `dark:bg-amber-950`)
  static Color goldTint(BuildContext c) =>
      isDark(c) ? const Color(0xFF332A17) : TwColors.gold100;
}

/// Teintes sémantiques utilisables par les composants Tw (alertes, badges…).
enum TwTone { brand, success, danger, warning, info, neutral }

/// Utilitaires de couleur associés à une teinte sémantique.
///
/// Reproduit l'API Tailwind `bg-{tone}-50 text-{tone}-700 border-{tone}-100`
/// (et ses variantes sombres `dark:`).
extension TwToneColor on TwTone {
  /// Fond de la teinte, adapté au mode clair / sombre.
  Color tint(BuildContext c) {
    if (TwSurface.isDark(c)) {
      switch (this) {
        case TwTone.brand:
          return TwColors.brandTintDark;
        case TwTone.success:
          return TwColors.successDark;
        case TwTone.danger:
          return TwColors.dangerDark;
        case TwTone.warning:
          return TwColors.warningDark;
        case TwTone.info:
          return TwColors.infoDark;
        case TwTone.neutral:
          return TwColors.ink800;
      }
    }
    switch (this) {
      case TwTone.brand:
        return TwColors.brand100;
      case TwTone.success:
        return TwColors.success50;
      case TwTone.danger:
        return TwColors.danger50;
      case TwTone.warning:
        return TwColors.warning50;
      case TwTone.info:
        return TwColors.info50;
      case TwTone.neutral:
        return TwColors.slate100;
    }
  }

  /// Couleur de premier plan (texte / icône), adaptée au mode clair / sombre.
  Color on(BuildContext c) {
    if (TwSurface.isDark(c)) {
      switch (this) {
        case TwTone.brand:
          return TwColors.brand300;
        case TwTone.success:
          return TwColors.success100;
        case TwTone.danger:
          return TwColors.danger100;
        case TwTone.warning:
          return TwColors.warning100;
        case TwTone.info:
          return TwColors.info100;
        case TwTone.neutral:
          return TwColors.slate300;
      }
    }
    switch (this) {
      case TwTone.brand:
        return TwColors.brand700;
      case TwTone.success:
        return TwColors.success700;
      case TwTone.danger:
        return TwColors.danger700;
      case TwTone.warning:
        return TwColors.warning700;
      case TwTone.info:
        return TwColors.info700;
      case TwTone.neutral:
        return TwColors.slate700;
    }
  }

  /// Bordure associée à la teinte.
  Color border(BuildContext c) {
    if (TwSurface.isDark(c)) return TwColors.ink600;
    switch (this) {
      case TwTone.brand:
        return TwColors.brand200;
      case TwTone.success:
        return TwColors.success100;
      case TwTone.danger:
        return TwColors.danger100;
      case TwTone.warning:
        return TwColors.warning100;
      case TwTone.info:
        return TwColors.info100;
      case TwTone.neutral:
        return TwColors.slate200;
    }
  }

  /// Couleur « pleine » de la teinte (badges solides, accents).
  Color get solid {
    switch (this) {
      case TwTone.brand:
        return TwColors.brand600;
      case TwTone.success:
        return TwColors.success600;
      case TwTone.danger:
        return TwColors.danger600;
      case TwTone.warning:
        return TwColors.warning600;
      case TwTone.info:
        return TwColors.info600;
      case TwTone.neutral:
        return TwColors.slate600;
    }
  }
}
