import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// AppTokens : Design tokens centralisés de l'application
/// Espacements, rayons de bordure, ombres, durées et courbes d'animation.
/// Philosophie équivalente à Tailwind CSS adaptée à Flutter.
/// ---------------------------------------------------------------------------
abstract final class AppTokens {
  // ── Espacements (Spacing) ──────────────────────────────────────────────────
  static const double space2  = 2.0;
  static const double space4  = 4.0;
  static const double space6  = 6.0;
  static const double space8  = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space15 = 15.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // ── Rayons de bordure (Border Radii) ───────────────────────────────────────
  static const double radius6   = 6.0;
  static const double radius8   = 8.0;
  static const double radius10  = 10.0;
  static const double radius12  = 12.0;
  static const double radius14  = 14.0;
  static const double radius16  = 16.0;
  static const double radius18  = 18.0;
  static const double radius20  = 20.0;
  static const double radius24  = 24.0;
  static const double radius28  = 28.0;
  static const double radius32  = 32.0;
  static const double radiusFull = 999.0;

  static const BorderRadius rounded8   = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius rounded10  = BorderRadius.all(Radius.circular(radius10));
  static const BorderRadius rounded12  = BorderRadius.all(Radius.circular(radius12));
  static const BorderRadius rounded14  = BorderRadius.all(Radius.circular(radius14));
  static const BorderRadius rounded16  = BorderRadius.all(Radius.circular(radius16));
  static const BorderRadius rounded18  = BorderRadius.all(Radius.circular(radius18));
  static const BorderRadius rounded20  = BorderRadius.all(Radius.circular(radius20));
  static const BorderRadius rounded24  = BorderRadius.all(Radius.circular(radius24));
  static const BorderRadius rounded28  = BorderRadius.all(Radius.circular(radius28));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // ── Ombres (BoxShadows) ────────────────────────────────────────────────────
  /// Ombre subtile pour éléments interactifs au repos
  static List<BoxShadow> shadowSm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Ombre par défaut pour les cartes (AppCard, etc.)
  static List<BoxShadow> shadowMd(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0xFF0E3B2C).withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Ombre prononcée pour éléments surélevés ou modales
  static List<BoxShadow> shadowLg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF0E3B2C).withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // ── Durées d'animation (Durations) ─────────────────────────────────────────
  static const Duration durationFast   = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow   = Duration(milliseconds: 400);

  // ── Courbes d'animation (Curves) ───────────────────────────────────────────
  static const Curve curveDefault  = Curves.easeOutCubic;
  static const Curve curveSmooth   = Curves.easeInOutCubic;
  static const Curve curveBouncy   = Curves.easeOutBack;
}
