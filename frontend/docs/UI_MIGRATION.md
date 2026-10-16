# Plan de migration UI — Design system « Tailwind / shadcn »

> Objectif : unifier toute la couche UI sur le design system `Tw*`, sans toucher à
> la logique métier (services, `ChangeNotifier`, navigation, modèles).

## 1. Architecture du design system

```
lib/theme/
├─ app_colors.dart      # palette historique (rétrocompat) + ext. BuildContext
├─ app_tokens.dart      # espacements/rayons/ombres historiques (rétrocompat)
├─ app_theme.dart       # ThemeData Material 3 (light + dark) + transitions de page
├─ theme_controller.dart# mode clair/sombre/système (persisté)
├─ tw_colors.dart       # TwColors (échelles Tailwind) + TwSurface + TwTone
├─ tw_tokens.dart       # TwSpace, TwRadius, TwBorder, TwShadow, TwMotion,
│                       # TwFontSize, TwWeight, TwLeading, TwTracking, TwText,
│                       # TwZ, TwBreakpoints, TwResponsive
├─ tw_theme.dart        # ★ TwTheme (ThemeExtension) + `context.tw`
└─ tw_components.dart   # TwButton, TwCard, TwInput, TwBadge, TwAlert,
                        # TwSectionHeader, TwProgressBar, TwDivider,
                        # TwSkeleton, TwEmptyState, TwIconTile, TwStatCard
```

### Règle d'or
- **Couleurs** → `context.tw.<token>` (thème-aware, testable, centralisé).
- **Espacements / rayons / ombres / typo** → constantes `TwSpace`, `TwRadius`,
  `TwShadow`, `TwText`… (indépendantes du mode clair/sombre).
- **Composants** → `TwButton`, `TwCard`, `TwAlert`, `TwSkeleton`, `TwEmptyState`…

### `context.tw` (ThemeExtension)
```dart
import 'theme/theme.dart';

final tw = context.tw;                 // ou TwTheme.of(context)
Container(color: tw.surface,           // bg-card
  decoration: BoxDecoration(
    border: Border.all(color: tw.border),
    borderRadius: TwRadius.card,
    boxShadow: TwShadow.md(context),
  ),
);
```
`TwTheme.light` / `TwTheme.dark` sont enregistrés dans `AppTheme` via
`ThemeData(extensions: [TwTheme.light])`. Le thème s'anime grâce à `lerp`.

## 2. Exemple avant / après (écran d'accueil `HomeScreen`)

**Avant** (couplé aux couleurs statiques, peu responsive) :
```dart
Scaffold(backgroundColor: context.themeBackground)      // static
Padding(padding: EdgeInsets.symmetric(horizontal: AppTokens.space20))
Text(ctx.tr('home_choose_category'),
     style: TextStyle(fontSize: 14, color: AppColors.gold))  // style ad-hoc
gradient: AppColors.emeraldHeaderGradient, borderRadius: AppTokens.rounded24
boxShadow: AppTokens.shadowMd(context),   border width: 1
.animate().fadeIn(duration: AppTokens.durationNormal, curve: AppTokens.curveDefault)
```

**Après** (design system, tokens sémantiques, animation unifiée) :
```dart
final tw = context.tw;
Scaffold(backgroundColor: tw.background)                // ThemeExtension
Padding(padding: TwSpace.pagePadding)                   // échelle Tailwind
TwSectionHeader(icon: Icons.grid_view_rounded,
                title: ctx.tr('home_choose_category'))  // composant réutilisable
gradient: TwColors.brandGradient, borderRadius: TwRadius.r3xl,
boxShadow: TwShadow.md(context), width: TwBorder.thin
.animate().fadeIn(duration: TwMotion.standard, curve: TwMotion.emphasized)
```
Aucun changement de logique : `categories`, `_openLevels`, `AppCard.onTap`,
`heroTag` sont **inchangés**. Seule la présentation a bougé.

## 3. Migration progressive, écran par écran

| Étape | Fichier | Action |
|------|---------|--------|
| ✅ 0 | `theme/tw_theme.dart` | ThemeExtension + `context.tw` |
| ✅ 1 | `theme/app_theme.dart` | enregistrer les extensions light/dark |
| ✅ 2 | `main.dart` (HomeScreen, `_Header`, `_HeroBanner`) | exemple de référence |
| 3 | `widgets.dart` (`AppCard`, `RoundIconButton`, `AppFooter`) | déplacer vers `Tw*`, garder l'API publique |
| 4 | `level_screen.dart` | `TwCard`/`TwProgressBar`/`TwBadge` |
| 5 | `quiz_screen.dart` | `TwButton`, `TwProgressBar`, `TwAlert`, `flutter_animate` |
| 6 | `result_screen.dart` | `TwCard` (gradient), `TwStatCard`, `confetti` |
| 7 | `correction_screen.dart` | `TwEmptyState`, `TwAlert`, `TwDivider` |
| 8 | ~~`settings_screen.dart`~~ | *Supprimé : écran jamais atteignable* |
| 9 | ~~`premium_screen.dart`~~ | *Supprimé : écran jamais atteignable (faux déblocage)* |
| 10 | `quiz_options_dialog.dart` | helper dialogue + `TwButton` |

### Procédure par écran (checklist)
1. Remplacer les `AppColors.*` / `context.theme*` par `context.tw.*`.
2. Remplacer `AppTokens.space*` / `radius*` / `shadow*` par `TwSpace` / `TwRadius` / `TwShadow`.
3. Remplacer les `TextStyle(...)` ad-hoc par `TwText.headline/bodySm/label…`.
4. Remplacer les `Container` décorés par `TwCard`, boutons par `TwButton`, etc.
5. `const` partout où possible ; vérifier `flutter analyze` à 0 warning.
6. Tester clair **et** sombre, LTR **et** RTL (arabe), + `--release` pour la perf.

## 4. Dépendances

Déjà présentes (aucune action) :
`google_fonts`, `shimmer` (skeleton), `flutter_animate`, `flutter_svg`,
`shared_preferences`, `just_audio`, `http`, `flutter_localizations`.

Optionnel (à valider) : `go_router` — **non requis** ici, la navigation
`Navigator.push` + `IslamicPageTransitionsBuilder` couvre déjà les transitions
fluides et le RTL. À n'ajouter que si l'on veut deep-linking / routes nommées.

## 5. Accessibilité & performance

- Contraste : les couples `tw.textPrimary`/`tw.background` respectent AA.
- `Semantics` : à ajouter sur les boutons icône (`RoundIconButton`, `TwButton`).
- Éviter les rebuilds : `AnimatedBuilder` du `MaterialApp` ne se déclenche qu'au
  changement de langue/thème (déjà en place). Préférer `context.tw` (léger).
- `MediaQuery.disableAnimations` respecté par `IslamicPageTransitionsBuilder` ;
  il reste à le propager à `flutter_animate` (durée `Duration.zero`).
