import 'package:flutter/material.dart';

import 'tw_colors.dart';

/// ---------------------------------------------------------------------------
/// TwSpace : Échelle d'espacement « Tailwind CSS » (1 unité = 4 px).
///
/// Reproduit exactement l'échelle par défaut de Tailwind :
/// `s1` = 4 px, `s2` = 8 px, `s4` = 16 px, `s6` = 24 px, `s8` = 32 px…
/// Utilisation : `SizedBox(height: TwSpace.s4)`, `EdgeInsets.all(TwSpace.s5)`.
/// ---------------------------------------------------------------------------
abstract final class TwSpace {
  static const double s0    = 0.0;
  static const double sPx  = 1.0;
  static const double s05  = 2.0;   // 0.5
  static const double s1   = 4.0;
  static const double s15  = 6.0;   // 1.5
  static const double s2   = 8.0;
  static const double s25  = 10.0;  // 2.5
  static const double s3   = 12.0;
  static const double s35  = 14.0;  // 3.5
  static const double s4   = 16.0;
  static const double s5   = 20.0;
  static const double s6   = 24.0;
  static const double s7   = 28.0;
  static const double s8   = 32.0;
  static const double s9   = 36.0;
  static const double s10  = 40.0;
  static const double s11  = 44.0;
  static const double s12  = 48.0;
  static const double s14  = 56.0;
  static const double s16  = 64.0;
  static const double s20  = 80.0;
  static const double s24  = 96.0;

  /// Gouttière horizontale standard des écrans (`px-5` = 20 px).
  static const double screenX = s5;

  /// Raccourcis EdgeInsets prêts à l'emploi.
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: screenX);

  static const EdgeInsets cardPadding = EdgeInsets.all(s4);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(s5);
}

/// ---------------------------------------------------------------------------
/// TwRadius : Échelle des rayons de bordure « Tailwind CSS ».
///
/// `sm` = 2 px, `DEFAULT` = 4 px, `md` = 6 px, `lg` = 8 px,
/// `xl` = 12 px, `2xl` = 16 px, `3xl` = 24 px, `full` = pilule.
/// ---------------------------------------------------------------------------
abstract final class TwRadius {
  static const double none    = 0.0;
  static const double sm      = 2.0;
  static const double DEFAULT = 4.0;
  static const double md      = 6.0;
  static const double lg      = 8.0;
  static const double xl      = 12.0;
  static const double xxl     = 16.0; // 2xl
  static const double xxxl    = 24.0; // 3xl
  static const double full    = 9999.0;

  static const BorderRadius rSm      = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rDefault = BorderRadius.all(Radius.circular(DEFAULT));
  static const BorderRadius rMd      = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg      = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl      = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius r2xl     = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius r3xl     = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius rFull    = BorderRadius.all(Radius.circular(full));

  /// Rayon « carte » recommandé par le design system (16 px).
  static const BorderRadius card = r2xl;

  /// Rayon « bouton / champ » recommandé (12 px).
  static const BorderRadius control = rXl;

  /// Rayon « badge / puce » recommandé (pilule).
  static const BorderRadius pill = rFull;
}

/// ---------------------------------------------------------------------------
/// TwBorder : Épaisseurs de bordure (équivalent `border`, `border-2`…).
/// ---------------------------------------------------------------------------
abstract final class TwBorder {
  static const double thin   = 1.0;
  static const double medium = 1.5;
  static const double thick  = 2.0;

  /// Bordure « hairline » standard des cartes (1 px).
  static const BorderSide card = BorderSide(width: thin);
}

/// ---------------------------------------------------------------------------
/// TwShadow : Ombres portées « Tailwind CSS » (sm → 2xl), theme-aware.
///
/// Les valeurs sont exactement celles de Tailwind :
/// `shadow-sm` 0 1px 2px, `shadow-md` 0 4px 6px -1px, `shadow-lg` 0 10px 15px…
/// En mode sombre, l'opacité est renforcée et l'ombre teintée de noir profond.
/// ---------------------------------------------------------------------------
abstract final class TwShadow {
  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static double _alpha(BuildContext c, double light) =>
      _dark(c) ? light * 2.2 : light;

  /// Ombre la plus discrète (bordures actives, puces).
  static List<BoxShadow> sm(BuildContext c) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.05)),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Ombre par défaut (équivalent `shadow`).
  static List<BoxShadow> base(BuildContext c) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.10)),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.06)),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Ombre des cartes interactives (équivalent `shadow-md`).
  static List<BoxShadow> md(BuildContext c) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.08)),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.05)),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  /// Ombre élevée (équivalent `shadow-lg`, menus, popovers).
  static List<BoxShadow> lg(BuildContext c) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.10)),
          blurRadius: 15,
          offset: const Offset(0, 10),
          spreadRadius: -3,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.06)),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  /// Ombre très élevée (équivalent `shadow-xl`, modales).
  static List<BoxShadow> xl(BuildContext c) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.12)),
          blurRadius: 25,
          offset: const Offset(0, 20),
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _alpha(c, 0.08)),
          blurRadius: 10,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ];

  /// Ombre de « focus ring » (équivalent `ring-2 ring-emerald-500/40`).
  static List<BoxShadow> ring(Color color, {double alpha = 0.35}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];

  /// Alias de rétrocompatibilité avec l'API existante `AppTokens`.
  static List<BoxShadow> shadowSm(BuildContext c) => sm(c);
  static List<BoxShadow> shadowMd(BuildContext c) => md(c);
  static List<BoxShadow> shadowLg(BuildContext c) => lg(c);
}

/// ---------------------------------------------------------------------------
/// TwMotion : Durées et courbes d'animation (équivalent `duration-*` / `ease-*`).
/// ---------------------------------------------------------------------------
abstract final class TwMotion {
  // Durées
  static const Duration d75   = Duration(milliseconds: 75);
  static const Duration d100  = Duration(milliseconds: 100);
  static const Duration d150  = Duration(milliseconds: 150);
  static const Duration d200  = Duration(milliseconds: 200);
  static const Duration d300  = Duration(milliseconds: 300);
  static const Duration d500  = Duration(milliseconds: 500);
  static const Duration d700  = Duration(milliseconds: 700);
  static const Duration d1000 = Duration(milliseconds: 1000);

  /// Durée standard des micro-interactions (`duration-200`).
  static const Duration standard = d200;

  // Courbes
  static const Curve linear  = Curves.linear;
  static const Curve easeIn  = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  /// Courbe « ease-out-cubic » : sensation de fluidité premium.
  static const Curve emphasized = Curves.easeOutCubic;

  /// Courbe avec léger dépassement (pop d'un badge, d'une carte).
  static const Curve bouncy = Curves.easeOutBack;
}

/// ---------------------------------------------------------------------------
/// TwFontSize / TwWeight / TwLeading / TwTracking
/// Échelle typographique « Tailwind CSS » (text-xs → text-4xl).
/// ---------------------------------------------------------------------------
abstract final class TwFontSize {
  static const double xs   = 12.0; // text-xs
  static const double sm   = 14.0; // text-sm
  static const double base = 16.0; // text-base
  static const double lg   = 18.0; // text-lg
  static const double xl   = 20.0; // text-xl
  static const double xxl  = 24.0; // text-2xl
  static const double xxxl = 30.0; // text-3xl
  static const double x4l  = 36.0; // text-4xl
}

abstract final class TwWeight {
  static const FontWeight normal    = FontWeight.w400;
  static const FontWeight medium    = FontWeight.w500;
  static const FontWeight semibold  = FontWeight.w600;
  static const FontWeight bold      = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;
  static const FontWeight black     = FontWeight.w900;
}

abstract final class TwLeading {
  static const double none    = 1.0;
  static const double tight   = 1.25;
  static const double snug    = 1.375;
  static const double normal  = 1.5;
  static const double relaxed = 1.625;
  static const double loose   = 2.0;
}

abstract final class TwTracking {
  static const double tighter = -0.05;
  static const double tight   = -0.025;
  static const double normal  = 0.0;
  static const double wide    = 0.025;
  static const double wider   = 0.05;
  static const double widest  = 0.1;
}

/// ---------------------------------------------------------------------------
/// TwText : Styles typographiques prêts à l'emploi (échelle Tailwind).
///
/// Ils conservent la famille de police du thème (Plus Jakarta Sans / Cairo)
/// car le `TextStyle` est fusionné avec le `DefaultTextStyle` ambiant.
/// ---------------------------------------------------------------------------
abstract final class TwText {
  // ── Titres ───────────────────────────────────────────────────────────────
  /// Grand titre d'impact (écran d'accueil) — 30 px / w800.
  static TextStyle display(BuildContext c,
          {Color? color, double size = TwFontSize.xxxl, FontWeight weight = TwWeight.extrabold}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.tight,
        letterSpacing: TwTracking.tight,
      );

  /// Titre d'écran (`text-2xl font-bold`).
  static TextStyle h1(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.xxl,
        fontWeight: TwWeight.bold,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.snug,
      );

  /// Titre de section (`text-xl font-bold`).
  static TextStyle h2(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.xl,
        fontWeight: TwWeight.bold,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.snug,
      );

  /// Titre de carte (`text-lg font-semibold`).
  static TextStyle h3(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.lg,
        fontWeight: TwWeight.semibold,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.snug,
      );

  /// Sous-titre (`text-base font-semibold`).
  static TextStyle h4(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.base,
        fontWeight: TwWeight.semibold,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.normal,
      );

  // ── Corps de texte ───────────────────────────────────────────────────────
  /// Texte courant (`text-base`).
  static TextStyle body(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.base,
        fontWeight: TwWeight.normal,
        color: color ?? TwSurface.textPrimary(c),
        height: TwLeading.normal,
      );

  /// Texte secondaire (`text-sm text-slate-600`).
  static TextStyle bodySm(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.sm,
        fontWeight: TwWeight.normal,
        color: color ?? TwSurface.textSecondary(c),
        height: TwLeading.relaxed,
      );

  /// Légende (`text-xs text-slate-500`).
  static TextStyle caption(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.xs,
        fontWeight: TwWeight.normal,
        color: color ?? TwSurface.textMuted(c),
        height: TwLeading.normal,
      );

  /// Étiquette de champ / bouton (`text-sm font-semibold`).
  static TextStyle label(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.sm,
        fontWeight: TwWeight.semibold,
        color: color ?? TwSurface.textPrimary(c),
      );

  /// Micro-titre en majuscules (`text-xs font-bold uppercase tracking-widest`).
  static TextStyle overline(BuildContext c, {Color? color}) => TextStyle(
        fontSize: TwFontSize.xs - 1,
        fontWeight: TwWeight.bold,
        letterSpacing: 1.2,
        color: color ?? TwSurface.textMuted(c),
      );

  /// Libellé de bouton (`text-sm font-bold`).
  static TextStyle button({Color color = Colors.white}) => TextStyle(
        fontSize: TwFontSize.sm + 1,
        fontWeight: TwWeight.bold,
        color: color,
        letterSpacing: TwTracking.wide,
      );
}

/// ---------------------------------------------------------------------------
/// TwZ : Piles de superposition (équivalent `z-0` … `z-50`).
/// ---------------------------------------------------------------------------
abstract final class TwZ {
  static const int z0  = 0;
  static const int z10 = 10;
  static const int z20 = 20;
  static const int z30 = 30;
  static const int z40 = 40;
  static const int z50 = 50;
}

/// ---------------------------------------------------------------------------
/// TwBreakpoints : Points de rupture responsives (équivalent `sm: md: lg: xl:`).
/// ---------------------------------------------------------------------------
abstract final class TwBreakpoints {
  static const double sm  = 640.0;
  static const double md  = 768.0;
  static const double lg  = 1024.0;
  static const double xl  = 1280.0;
  static const double xxl = 1536.0;
}

/// ---------------------------------------------------------------------------
/// TwResponsive : Sélection de valeurs selon la largeur d'écran.
///
/// Équivalent Flutter des variantes responsives de Tailwind :
/// `TwResponsive.value(context, base: 16, md: 20, lg: 24)`.
/// ---------------------------------------------------------------------------
abstract final class TwResponsive {
  /// Largeur logique courante.
  static double width(BuildContext c) => MediaQuery.sizeOf(c).width;

  /// Vrai si la largeur dépasse le point de rupture `sm` (640 px).
  static bool isSm(BuildContext c) => width(c) >= TwBreakpoints.sm;

  /// Vrai si la largeur dépasse `md` (768 px) — tablettes.
  static bool isMd(BuildContext c) => width(c) >= TwBreakpoints.md;

  /// Vrai si la largeur dépasse `lg` (1024 px) — desktop.
  static bool isLg(BuildContext c) => width(c) >= TwBreakpoints.lg;

  /// Vrai si l'appareil est en mode paysage.
  static bool isLandscape(BuildContext c) =>
      MediaQuery.orientationOf(c) == Orientation.landscape;

  /// Renvoie `md` si l'écran est ≥ 768 px, sinon `base`
  /// (et `lg` si ≥ 1024 px, en priorisant la plus grande rupture atteinte).
  static T value<T>(BuildContext c, {required T base, T? sm, T? md, T? lg}) {
    final w = width(c);
    if (lg != null && w >= TwBreakpoints.lg) return lg;
    if (md != null && w >= TwBreakpoints.md) return md;
    if (sm != null && w >= TwBreakpoints.sm) return sm;
    return base;
  }

  /// Nombre de colonnes adapté (1 en mobile, 2 en ≥ 640 px, 3 en ≥ 1024 px).
  static int columns(BuildContext c, {int base = 1, int sm = 2, int lg = 3}) =>
      value<int>(c, base: base, sm: sm, lg: lg);

  /// Largeur maximale de contenu (évite les lignes trop longues en desktop).
  static const double contentMaxWidth = 720.0;
}