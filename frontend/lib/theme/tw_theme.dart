import 'package:flutter/material.dart';

import 'tw_colors.dart';

/// ---------------------------------------------------------------------------
/// TwTheme — Extension de thème (ThemeExtension) du design system.
///
/// Centralise la palette SÉMANTIQUE de l'application (fonds, surfaces, bordures,
/// textes, couleurs d'état) sous forme de valeurs typées accessibles depuis
/// n'importe quel `BuildContext` via `context.tw` ou `TwTheme.of(context)`.
///
/// Philosophie : exactement comme Tailwind CSS, où une classe sémantique
/// (`bg-background`, `text-foreground`, `border`) résout une valeur différente
/// en mode clair et sombre. Ici, `context.tw.surface` fait la même chose.
///
/// Les constantes pures (espacements, rayons, ombres, typographie) restent
/// exposées par `TwSpace`, `TwRadius`, `TwShadow`, `TwText` : elles ne dépendent
/// pas du mode clair/sombre et n'ont donc pas à vivre dans une ThemeExtension.
/// ---------------------------------------------------------------------------
@immutable
class TwTheme extends ThemeExtension<TwTheme> {
  // ── Fonds & surfaces ────────────────────────────────────────────────────
  /// Fond général de l'écran (équivalent `bg-background`).
  final Color background;

  /// Surface d'une carte (équivalent `bg-card`).
  final Color surface;

  /// Surface surélevée : modales, menus, bottom sheets.
  final Color surfaceElevated;

  /// Surface discrète : champs de saisie, zones neutres.
  final Color surfaceSubtle;

  /// Surface au survol / à l'appui.
  final Color surfaceHover;

  // ── Bordures ────────────────────────────────────────────────────────────
  /// Bordure standard (équivalent `border`).
  final Color border;

  /// Bordure marquée / accent (équivalent `border-strong`).
  final Color borderStrong;

  // ── Textes ──────────────────────────────────────────────────────────────
  /// Texte principal (équivalent `text-foreground`).
  final Color textPrimary;

  /// Texte secondaire (équivalent `text-muted-foreground`).
  final Color textSecondary;

  /// Texte atténué / placeholders.
  final Color textMuted;

  // ── Teintes de marque (fonds doux) ──────────────────────────────────────
  /// Fond teinté émeraude (équivalent `bg-primary/10`).
  final Color brandTint;

  /// Fond teinté doré (équivalent `bg-accent/10`).
  final Color goldTint;

  // ── Couleurs d'action & d'état ──────────────────────────────────────────
  /// Couleur primaire (émeraude) adaptée au mode.
  final Color primary;

  /// Variante claire/accent de la primaire.
  final Color primaryLight;

  /// Couleur d'accent (dorure).
  final Color accent;

  final Color success;
  final Color danger;
  final Color warning;
  final Color info;

  const TwTheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSubtle,
    required this.surfaceHover,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.brandTint,
    required this.goldTint,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
  });

  // ── Presets clair / sombre ────────────────────────────────────────────────
  /// Jeu de couleurs sémantiques du mode clair (organique, chaleureux, haut contraste).
  static const TwTheme light = TwTheme(
    background: Color(0xFFF7F8F5),
    surface: Colors.white,
    surfaceElevated: Colors.white,
    surfaceSubtle: Color(0xFFEFF2EE),
    surfaceHover: Color(0xFFE5EDE7),
    border: Color(0xFFDFE6E1),
    borderStrong: Color(0xFFC6D3CB),
    textPrimary: Color(0xFF0F241D),
    textSecondary: Color(0xFF4C6057),
    textMuted: Color(0xFF7A8F85),
    brandTint: Color(0xFFE8F4EE),
    goldTint: Color(0xFFFBF4E6),
    primary: TwColors.brand600,
    primaryLight: TwColors.brand500,
    accent: TwColors.gold500,
    success: TwColors.success600,
    danger: TwColors.danger600,
    warning: TwColors.warning600,
    info: TwColors.info600,
  );

  /// Jeu de couleurs sémantiques du mode sombre (« nuit d'émeraude profonde »).
  static const TwTheme dark = TwTheme(
    background: Color(0xFF0B1612),
    surface: Color(0xFF12231C),
    surfaceElevated: Color(0xFF182D24),
    surfaceSubtle: Color(0xFF182D24),
    surfaceHover: Color(0xFF1F382E),
    border: Color(0xFF223A30),
    borderStrong: Color(0xFF2E4E40),
    textPrimary: Color(0xFFF2F6F3),
    textSecondary: Color(0xFFA6BCB0),
    textMuted: Color(0xFF6E8579),
    brandTint: Color(0xFF19382B),
    goldTint: Color(0xFF332A17),
    primary: TwColors.brand500,
    primaryLight: TwColors.brand400,
    accent: TwColors.gold500,
    success: TwColors.success500,
    danger: TwColors.danger500,
    warning: TwColors.warning500,
    info: TwColors.info500,
  );

  /// Preset correspondant à une luminosité donnée.
  static TwTheme forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Récupère l'extension depuis le thème, avec repli sûr.
  static TwTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<TwTheme>() ?? forBrightness(theme.brightness);
  }

  /// Copie immuable en remplaçant uniquement les couleurs fournies.
  @override
  TwTheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSubtle,
    Color? surfaceHover,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? brandTint,
    Color? goldTint,
    Color? primary,
    Color? primaryLight,
    Color? accent,
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
  }) {
    return TwTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      brandTint: brandTint ?? this.brandTint,
      goldTint: goldTint ?? this.goldTint,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  /// Interpolation animée entre deux jeux de couleurs (transition de thème).
  @override
  TwTheme lerp(covariant ThemeExtension<TwTheme>? other, double t) {
    if (other is! TwTheme) return this;
    return TwTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      goldTint: Color.lerp(goldTint, other.goldTint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Accesseur pratique : `context.tw` (raccourci de `TwTheme.of(context)`).
/// ---------------------------------------------------------------------------
extension TwThemeContext on BuildContext {
  /// Récupère les couleurs sémantiques du design system.
  TwTheme get tw => TwTheme.of(this);

  /// Raccourci vers le `ColorScheme` Material 3 courant.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
