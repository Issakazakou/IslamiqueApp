import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'tw_colors.dart';
import 'tw_tokens.dart';

/// ---------------------------------------------------------------------------
/// TwButton — Bouton universel du design system (équivalent Tailwind UI).
///
/// Variantes : `primary`, `secondary`, `outline`, `ghost`, `danger`, `success`.
/// Tailles : `sm`, `md`, `lg`. Supporte icône, état de chargement et pleine
/// largeur, avec une micro-interaction d'appui cohérente.
/// ---------------------------------------------------------------------------
enum TwButtonVariant { primary, secondary, outline, ghost, danger, success }

enum TwButtonSize { sm, md, lg }

class TwButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final TwButtonVariant variant;
  final TwButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const TwButton({
    super.key,
    this.label,
    this.child,
    this.icon,
    this.trailingIcon,
    required this.onPressed,
    this.variant = TwButtonVariant.primary,
    this.size = TwButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : assert(label != null || child != null,
            'TwButton requiert un `label` ou un `child`.');

  @override
  State<TwButton> createState() => _TwButtonState();
}

class _TwButtonState extends State<TwButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  double get _height {
    switch (widget.size) {
      case TwButtonSize.sm:
        return 36;
      case TwButtonSize.md:
        return 46;
      case TwButtonSize.lg:
        return 54;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case TwButtonSize.sm:
        return TwFontSize.xs + 1;
      case TwButtonSize.md:
        return TwFontSize.sm + 1;
      case TwButtonSize.lg:
        return TwFontSize.base;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case TwButtonSize.sm:
        return 16;
      case TwButtonSize.md:
        return 18;
      case TwButtonSize.lg:
        return 20;
    }
  }

  EdgeInsetsGeometry get _insets {
    if (widget.padding != null) return widget.padding!;
    switch (widget.size) {
      case TwButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: TwSpace.s35);
      case TwButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: TwSpace.s5);
      case TwButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: TwSpace.s6);
    }
  }

  // ── Résolution des couleurs par variante ────────────────────────────────
  Color get _background {
    switch (widget.variant) {
      case TwButtonVariant.primary:
        return TwColors.brand600;
      case TwButtonVariant.secondary:
        return TwColors.gold500;
      case TwButtonVariant.outline:
      case TwButtonVariant.ghost:
        return Colors.transparent;
      case TwButtonVariant.danger:
        return TwColors.danger600;
      case TwButtonVariant.success:
        return TwColors.success600;
    }
  }

  Color _foreground(BuildContext c) {
    switch (widget.variant) {
      case TwButtonVariant.primary:
      case TwButtonVariant.secondary:
      case TwButtonVariant.danger:
      case TwButtonVariant.success:
        return Colors.white;
      case TwButtonVariant.outline:
        return TwSurface.textPrimary(c);
      case TwButtonVariant.ghost:
        return TwColors.brand600;
    }
  }

  Border? _border(BuildContext c) {
    if (widget.variant == TwButtonVariant.outline) {
      return Border.all(color: TwSurface.borderStrong(c));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fg = _enabled ? _foreground(context) : TwSurface.textMuted(context);
    final bg = _enabled ? _background : TwSurface.subtle(context);

    final content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: _iconSize, color: fg),
        if (widget.isLoading || widget.icon != null)
          const SizedBox(width: TwSpace.s2),
        if (widget.child != null)
          widget.child!
        else
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: TwWeight.bold,
              color: fg,
              letterSpacing: TwTracking.wide,
            ),
          ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: TwSpace.s2),
          Icon(widget.trailingIcon, size: _iconSize, color: fg),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: TwMotion.d100,
        curve: TwMotion.emphasized,
        child: AnimatedContainer(
          duration: TwMotion.d150,
          height: _height,
          width: widget.isFullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: TwRadius.rXl,
            border: _border(context),
            boxShadow: _enabled && widget.variant != TwButtonVariant.ghost
                ? TwShadow.sm(context)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: TwRadius.rXl,
            child: InkWell(
              borderRadius: TwRadius.rXl,
              onTap: _enabled ? widget.onPressed : null,
              onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
              onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel:
                  _enabled ? () => setState(() => _pressed = false) : null,
              child: Padding(
                padding: _insets,
                child: Center(widthFactor: 1.0, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwCard — Carte de contenu (équivalent `rounded-2xl border bg-white shadow-sm`).
///
/// Variantes : `elevated` (ombre douce), `outlined` (bordure seule),
/// `filled` (fond discret), `gradient` (dégradé émeraude signature).
/// ---------------------------------------------------------------------------
enum TwCardVariant { elevated, outlined, filled, gradient }

class TwCard extends StatelessWidget {
  final Widget child;
  final TwCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool animate;

  const TwCard({
    super.key,
    required this.child,
    this.variant = TwCardVariant.elevated,
    this.padding = const EdgeInsets.all(TwSpace.s4),
    this.onTap,
    this.color,
    this.borderRadius,
    this.width,
    this.height,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? TwRadius.card;

    final BoxDecoration decoration;
    switch (variant) {
      case TwCardVariant.elevated:
        decoration = BoxDecoration(
          color: color ?? TwSurface.card(context),
          gradient: color == null
              ? (TwSurface.isDark(context)
                  ? TwColors.cardGlowDark
                  : TwColors.cardGlowLight)
              : null,
          borderRadius: radius,
          border: Border.all(
            color: TwSurface.border(context),
            width: TwBorder.thin,
          ),
          boxShadow: TwShadow.md(context),
        );
      case TwCardVariant.outlined:
        decoration = BoxDecoration(
          color: color ?? TwSurface.card(context),
          borderRadius: radius,
          border: Border.all(
            color: TwSurface.border(context),
            width: TwBorder.thin,
          ),
        );
      case TwCardVariant.filled:
        decoration = BoxDecoration(
          color: color ?? TwSurface.subtle(context),
          borderRadius: radius,
          border: Border.all(
            color: TwSurface.border(context),
            width: TwBorder.thin,
          ),
        );
      case TwCardVariant.gradient:
        decoration = BoxDecoration(
          gradient: color == null ? TwColors.brandGradient : null,
          color: color,
          borderRadius: radius,
          border: Border.all(
            color: TwColors.gold500.withValues(alpha: 0.30),
            width: 1.2,
          ),
          boxShadow: TwShadow.md(context),
        );
    }

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    final decorated = AnimatedContainer(
      duration: animate ? TwMotion.standard : Duration.zero,
      curve: TwMotion.emphasized,
      width: width,
      height: height,
      decoration: decoration,
      child: content,
    );

    return decorated;
  }
}

/// ---------------------------------------------------------------------------
/// TwIconTile — Pastille d'icône colorée (équivalent `p-3 rounded-xl bg-*-50`).
///
/// Utilisée en tête de carte, dans les listes et les états vides.
/// ---------------------------------------------------------------------------
class TwIconTile extends StatelessWidget {
  final IconData icon;
  final TwTone tone;
  final double size;
  final double iconSize;
  final bool solid;

  const TwIconTile({
    super.key,
    required this.icon,
    this.tone = TwTone.brand,
    this.size = 48,
    this.iconSize = 24,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? tone.solid : tone.tint(context),
        borderRadius: TwRadius.rXl,
        border: solid ? null : Border.all(color: tone.border(context)),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: solid ? Colors.white : tone.on(context),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwBadge — Étiquette compacte (équivalent `inline-flex px-2 py-1 rounded-full`).
///
/// Modes : `soft` (teinte claire + texte coloré) ou `solid` (fond plein).
/// ---------------------------------------------------------------------------
class TwBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TwTone tone;
  final bool solid;
  final bool uppercase;

  const TwBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = TwTone.brand,
    this.solid = false,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : tone.on(context);
    final bg = solid ? tone.solid : tone.tint(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TwSpace.s25,
        vertical: TwSpace.s05 + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TwRadius.pill,
        border: solid ? null : Border.all(color: tone.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: TwSpace.s1),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: TextStyle(
              fontSize: TwFontSize.xs - 1,
              fontWeight: TwWeight.bold,
              letterSpacing: uppercase ? 0.6 : 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwAlert — Bandeau d'information sémantique (équivalent alertes Tailwind UI).
///
/// Combinaison `bg-{tone}-50 border-{tone}-100 text-{tone}-700`.
/// ---------------------------------------------------------------------------
class TwAlert extends StatelessWidget {
  final String message;
  final String? title;
  final TwTone tone;
  final IconData? icon;
  final Widget? action;

  const TwAlert({
    super.key,
    required this.message,
    this.title,
    this.tone = TwTone.info,
    this.icon,
    this.action,
  });

  IconData get _defaultIcon {
    switch (tone) {
      case TwTone.success:
        return Icons.check_circle_outline;
      case TwTone.danger:
        return Icons.error_outline;
      case TwTone.warning:
        return Icons.warning_amber_rounded;
      case TwTone.info:
        return Icons.info_outline;
      case TwTone.brand:
        return Icons.lightbulb_outline;
      case TwTone.neutral:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = tone.on(context);

    return Container(
      padding: const EdgeInsets.all(TwSpace.s3),
      decoration: BoxDecoration(
        color: tone.tint(context),
        borderRadius: TwRadius.rXl,
        border: Border.all(color: tone.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, size: 20, color: fg),
          const SizedBox(width: TwSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: TwFontSize.sm,
                      fontWeight: TwWeight.bold,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: TwSpace.s05),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: TwFontSize.xs,
                    fontWeight: TwWeight.medium,
                    height: TwLeading.relaxed,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: TwSpace.s2),
            action!,
          ],
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwSectionHeader — En-tête de section (titre + sous-titre + action à droite).
/// ---------------------------------------------------------------------------
class TwSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final bool centered;

  const TwSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: TwColors.gold500),
          const SizedBox(width: TwSpace.s2),
        ],
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: TwFontSize.xs + 1,
              fontWeight: TwWeight.extrabold,
              letterSpacing: TwTracking.wider,
              color: TwColors.gold500,
            ),
          ),
        ),
      ],
    );

    if (centered) {
      return Column(
        children: [
          titleWidget,
          if (subtitle != null) ...[
            const SizedBox(height: TwSpace.s1),
            Text(
              subtitle!,
              style: TwText.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              if (subtitle != null) ...[
                const SizedBox(height: TwSpace.s1),
                Text(subtitle!, style: TwText.caption(context)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwProgressBar — Barre de progression fine et arrondie (`rounded-full`).
/// ---------------------------------------------------------------------------
class TwProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final TwTone tone;
  final LinearGradient? gradient;
  final bool showLabel;

  const TwProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.tone = TwTone.brand,
    this.gradient,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: TwRadius.pill,
            child: Stack(
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: TwSurface.isDark(context)
                        ? TwColors.ink700
                        : TwColors.slate100,
                    borderRadius: TwRadius.pill,
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clamped,
                  child: AnimatedContainer(
                    duration: TwMotion.d500,
                    curve: TwMotion.emphasized,
                    height: height,
                    decoration: BoxDecoration(
                      color: gradient == null ? tone.solid : null,
                      gradient: gradient,
                      borderRadius: TwRadius.pill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: TwSpace.s2),
          Text(
            '${(clamped * 100).round()} %',
            style: TextStyle(
              fontSize: TwFontSize.xs,
              fontWeight: TwWeight.bold,
              color: TwSurface.textSecondary(context),
            ),
          ),
        ],
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwDivider — Séparateur horizontal avec libellé central optionnel.
/// ---------------------------------------------------------------------------
class TwDivider extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final double spacing;

  const TwDivider({super.key, this.label, this.icon, this.spacing = TwSpace.s4});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              TwColors.gold500.withValues(
                alpha: TwSurface.isDark(context) ? 0.35 : 0.45,
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        children: [
          line,
          if (label != null || icon != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TwSpace.s2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon ?? Icons.auto_awesome,
                      size: 13,
                      color: TwColors.gold500.withValues(alpha: 0.75),
                    ),
                    if (label != null) ...[
                      const SizedBox(width: TwSpace.s2),
                      Flexible(
                        child: Text(
                          label!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: TwFontSize.xs - 1,
                            fontWeight: TwWeight.semibold,
                            letterSpacing: TwTracking.wide,
                            color: TwSurface.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          line,
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwSkeleton — Bloc de chargement « shimmer » (équivalent `animate-pulse`).
/// ---------------------------------------------------------------------------
class TwSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const TwSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = TwRadius.rLg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TwSurface.isDark(context);
    return Shimmer.fromColors(
      baseColor: isDark ? TwColors.ink800 : TwColors.slate100,
      highlightColor: isDark ? TwColors.ink700 : Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? TwColors.ink800 : TwColors.slate100,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwEmptyState — État vide ou d'erreur illustré, avec action optionnelle.
/// ---------------------------------------------------------------------------
class TwEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final TwTone tone;
  final Widget? action;

  const TwEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = TwTone.neutral,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TwSpace.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tone.tint(context),
                borderRadius: TwRadius.r2xl,
                border: Border.all(color: tone.border(context)),
              ),
              child: Icon(icon, size: 38, color: tone.on(context)),
            ),
            const SizedBox(height: TwSpace.s5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TwText.h3(context),
            ),
            if (message != null) ...[
              const SizedBox(height: TwSpace.s2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TwText.bodySm(context),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: TwSpace.s6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwTextField — Champ de saisie stylé (équivalent `input` de Tailwind UI).
/// ---------------------------------------------------------------------------
class TwTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextDirection? textDirection;

  const TwTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TwText.label(context)),
          const SizedBox(height: TwSpace.s2),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          textDirection: textDirection,
          style: TwText.body(context),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TwText.bodySm(context, color: TwSurface.textMuted(context)),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: 18,
                    color: TwSurface.textMuted(context),
                  ),
            suffixIcon: suffix,
            filled: true,
            fillColor: TwSurface.subtle(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TwSpace.s4,
              vertical: TwSpace.s35,
            ),
            border: OutlineInputBorder(
              borderRadius: TwRadius.control,
              borderSide: BorderSide(color: TwSurface.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: TwRadius.control,
              borderSide: BorderSide(color: TwSurface.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: TwRadius.control,
              borderSide: const BorderSide(color: TwColors.brand600, width: 1.6),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: TwSpace.s15),
          Text(helper!, style: TwText.caption(context)),
        ],
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// TwStatCard — Statistique mise en avant (valeur + libellé + icône).
/// ---------------------------------------------------------------------------
class TwStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final TwTone tone;

  const TwStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone = TwTone.brand,
  });

  @override
  Widget build(BuildContext context) {
    return TwCard(
      variant: TwCardVariant.outlined,
      padding: const EdgeInsets.all(TwSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TwIconTile(icon: icon, tone: tone, size: 38, iconSize: 20),
          const SizedBox(height: TwSpace.s3),
          Text(
            value,
            style: TextStyle(
              fontSize: TwFontSize.xl,
              fontWeight: TwWeight.extrabold,
              color: TwSurface.textPrimary(context),
            ),
          ),
          const SizedBox(height: TwSpace.s05),
          Text(
            label,
            style: TextStyle(
              fontSize: TwFontSize.xs,
              fontWeight: TwWeight.medium,
              color: TwSurface.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}