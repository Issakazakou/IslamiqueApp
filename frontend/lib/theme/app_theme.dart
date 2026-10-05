import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'tw_theme.dart';

/// ---------------------------------------------------------------------------
/// AppTheme : Thème central Material 3 de l'application
/// Prend en charge le mode Clair, le mode Sombre, et adapte la typographie
/// automatiquement selon la langue active (Latin : Plus Jakarta Sans / Arabe : Cairo & Amiri).
/// ---------------------------------------------------------------------------
abstract final class AppTheme {
  // ── Police Coranique Spécifique (Amiri) ───────────────────────────────────
  static TextStyle quranicText({
    double fontSize = 22.0,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double height = 1.8,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // ── Construction de la typographie multilingue ────────────────────────────
  static TextTheme _buildTextTheme({
    required String languageCode,
    required Color primaryText,
    required Color secondaryText,
    required Color mutedText,
  }) {
    final isArabic = languageCode == 'ar';

    // Base TextTheme selon la langue
    final baseTextTheme = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.plusJakartaSansTextTheme();

    return baseTextTheme.copyWith(
      // Display : Grands titres d'accueil et d'impact
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: primaryText,
        height: 1.15,
        letterSpacing: isArabic ? 0 : -0.5,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primaryText,
        height: 1.2,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.25,
      ),

      // Headline : Titres de sections et d'écrans
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: primaryText,
        height: 1.3,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.3,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.35,
      ),

      // Title : Titres de cartes et de dialogues
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.35,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.4,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: secondaryText,
        height: 1.4,
      ),

      // Body : Textes courants et descriptions
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryText,
        height: 1.45,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.45,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedText,
        height: 1.4,
      ),

      // Label : Boutons, badges et petits indicateurs
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: isArabic ? 0 : 0.2,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: secondaryText,
        letterSpacing: isArabic ? 0 : 0.3,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: mutedText,
        letterSpacing: isArabic ? 0 : 0.5,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // THÈME CLAIR (Light Mode)
  // ---------------------------------------------------------------------------
  static ThemeData lightTheme([String languageCode = 'fr']) {
    final textTheme = _buildTextTheme(
      languageCode: languageCode,
      primaryText: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
      mutedText: AppColors.textMuted,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryTint,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.gold,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.goldTint,
      onSecondaryContainer: AppColors.goldDark,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorTint,
      onErrorContainer: AppColors.error,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceElevated,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.card,
      surfaceContainerHigh: Color(0xFFF0F2EF),
      surfaceContainerHighest: AppColors.border,
      outline: AppColors.border,
      outlineVariant: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extensions: const [TwTheme.light],
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.rounded20,
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded16),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          disabledForegroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.rounded24),
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.rounded14),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.primaryTint,
      ),

      // ── Switch Theme ──────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Page Transitions ──────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: IslamicPageTransitionsBuilder(),
          TargetPlatform.iOS: IslamicPageTransitionsBuilder(),
          TargetPlatform.windows: IslamicPageTransitionsBuilder(),
          TargetPlatform.linux: IslamicPageTransitionsBuilder(),
          TargetPlatform.macOS: IslamicPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // THÈME SOMBRE (Dark Mode - Nuit d'Émeraude)
  // ---------------------------------------------------------------------------
  static ThemeData darkTheme([String languageCode = 'fr']) {
    final textTheme = _buildTextTheme(
      languageCode: languageCode,
      primaryText: AppColors.darkTextPrimary,
      secondaryText: AppColors.darkTextSecondary,
      mutedText: AppColors.darkTextMuted,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.darkPrimaryTint,
      onPrimaryContainer: AppColors.primaryTint,
      secondary: AppColors.gold,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.darkGoldTint,
      onSecondaryContainer: AppColors.goldLight,
      error: Color(0xFFEF5350),
      onError: Colors.black,
      errorContainer: AppColors.darkErrorTint,
      onErrorContainer: Color(0xFFFFCDD2),
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: Color(0xFF09120F),
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainer: AppColors.darkCard,
      surfaceContainerHigh: AppColors.darkSurfaceElevated,
      surfaceContainerHighest: AppColors.darkBorder,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkOutline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extensions: const [TwTheme.dark],
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.rounded20,
          side: BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkBorder,
          disabledForegroundColor: AppColors.darkTextMuted,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded16),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          disabledForegroundColor: AppColors.darkTextMuted,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.rounded12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.rounded24),
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.rounded14),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.darkBorder,
        circularTrackColor: AppColors.darkPrimaryTint,
      ),

      // ── Switch Theme ──────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.darkTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
          return AppColors.darkBorder;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Page Transitions ──────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: IslamicPageTransitionsBuilder(),
          TargetPlatform.iOS: IslamicPageTransitionsBuilder(),
          TargetPlatform.windows: IslamicPageTransitionsBuilder(),
          TargetPlatform.linux: IslamicPageTransitionsBuilder(),
          TargetPlatform.macOS: IslamicPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Transition de page personnalisée et cohérente (fondu + glissement doux)
/// Sens inversé en arabe (RTL) et respect de MediaQuery.disableAnimations.
/// ---------------------------------------------------------------------------
class IslamicPageTransitionsBuilder extends PageTransitionsBuilder {
  const IslamicPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final beginOffset = isRtl ? const Offset(-0.04, 0.0) : const Offset(0.04, 0.0);

    final slideAnim = CurvedAnimation(
      parent: animation,
      curve: AppTokens.curveDefault,
    );

    final fadeAnim = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    return SlideTransition(
      position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(slideAnim),
      child: FadeTransition(
        opacity: fadeAnim,
        child: child,
      ),
    );
  }
}
