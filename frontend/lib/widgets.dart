import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'theme/theme.dart';
import 'app_strings.dart';
import 'config/api_config.dart';

/// ---------------------------------------------------------------------------
/// Motif Géométrique Islamique (CustomPainter)
/// Dessine un réseau d'étoiles islamiques à 8 pointes (Khatim) discret.
/// Idéal en arrière-plan d'en-tête ou de cartes avec faible opacité (0.03 - 0.08).
/// ---------------------------------------------------------------------------
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double scale;

  const IslamicPatternPainter({
    this.color = TwColors.gold500,
    this.opacity = 0.06,
    this.scale = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final step = scale;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawEightPointStar(canvas, Offset(x, y), step * 0.45, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Premier carré
    final r1 = Rect.fromCenter(center: center, width: radius * 2, height: radius * 2);
    canvas.drawRect(r1, paint);

    // Second carré tourné à 45 degrés
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    final r2 = Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2);
    canvas.drawRect(r2, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.scale != scale;
  }
}

/// ---------------------------------------------------------------------------
/// Conteneur avec fond à motif géométrique islamique
/// ---------------------------------------------------------------------------
class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final Color patternColor;
  final double opacity;
  final double scale;

  const IslamicPatternBackground({
    super.key,
    required this.child,
    this.patternColor = TwColors.gold500,
    this.opacity = 0.06,
    this.scale = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IslamicPatternPainter(
        color: patternColor,
        opacity: opacity,
        scale: scale,
      ),
      child: child,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Carte cliquable premium (catégories, parcours, niveaux)
/// Compatible RTL, ombre douce dynamique, dégradé subtil et effet de clic doux.
/// ---------------------------------------------------------------------------
class AppCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final Widget? extra;
  final VoidCallback onTap;
  final String? heroTag;

  const AppCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.onTap,
    this.extra,
    this.heroTag,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget iconWidget = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.iconBackground,
            widget.iconBackground.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: TwRadius.rXl,
        border: Border.all(
          color: widget.iconColor.withValues(alpha: 0.22),
          width: TwBorder.thin,
        ),
      ),
      child: Icon(widget.icon, color: widget.iconColor, size: 26),
    );

    if (widget.heroTag != null) {
      iconWidget = Hero(
        tag: widget.heroTag!,
        child: iconWidget,
      );
    }

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: TwMotion.d150,
      curve: TwMotion.emphasized,
      child: AnimatedContainer(
        duration: TwMotion.d200,
        curve: TwMotion.emphasized,
        decoration: BoxDecoration(
          color: TwSurface.card(context),
          gradient: TwSurface.isDark(context)
              ? TwColors.cardGlowDark
              : TwColors.cardGlowLight,
          borderRadius: TwRadius.card,
          border: Border.all(
            color: _isPressed
                ? widget.iconColor.withValues(alpha: 0.35)
                : TwSurface.border(context),
            width: TwBorder.thin,
          ),
          boxShadow: _isPressed ? TwShadow.lg(context) : TwShadow.md(context),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: TwRadius.card,
          child: InkWell(
            borderRadius: TwRadius.card,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(TwSpace.s4),
              child: Row(
                children: [
                  iconWidget,
                  const SizedBox(width: TwSpace.s4),

                  // Titre et description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: TwText.h4(context)),
                        const SizedBox(height: TwSpace.s1),
                        Text(
                          widget.description,
                          style: TwText.bodySm(context),
                        ),
                        if (widget.extra != null) ...[
                          const SizedBox(height: TwSpace.s2),
                          widget.extra!,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: TwSpace.s2),

                  // Flèche chevron respectant le sens RTL
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: TwSurface.brandTint(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRtl ? Icons.chevron_left : Icons.chevron_right,
                      color: TwColors.brand600,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Bouton rond accessible (48 px minimum de cible tactile)
/// ---------------------------------------------------------------------------
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: TwSurface.card(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: TwSurface.border(context),
          width: TwBorder.thin,
        ),
        boxShadow: TwShadow.sm(context),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 19,
              color: TwSurface.textPrimary(context),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Semantics(
      button: true,
      label: tooltip,
      child: button,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pied de page avec arabesques et vers dorés
/// ---------------------------------------------------------------------------
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return TwDivider(
      label: context.tr('footer'),
      spacing: TwSpace.s4,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Chargement en Squelette (Shimmer Loading)
/// Remplace le simple indicateur circulaire par un squelette visuel élégant.
/// ---------------------------------------------------------------------------
class ShimmerLoadingList extends StatelessWidget {
  final int count;

  const ShimmerLoadingList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1B2F25) : const Color(0xFFE8ECE9);
    final highlightColor = isDark ? const Color(0xFF264235) : const Color(0xFFF6F8F6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(height: TwSpace.s35),
        itemBuilder: (context, index) => Container(
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: TwRadius.r3xl,
          ),
        ),
      ),
    );
  }
}

/// Squelette pour la carte de question
class ShimmerQuestionCard extends StatelessWidget {
  const ShimmerQuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1B2F25) : const Color(0xFFE8ECE9);
    final highlightColor = isDark ? const Color(0xFF264235) : const Color(0xFFF6F8F6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: TwRadius.r3xl,
            ),
          ),
          const SizedBox(height: TwSpace.s4),
          ...List.generate(4, (_) => Padding(
            padding: const EdgeInsets.only(bottom: TwSpace.s3),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: TwRadius.r2xl,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Écran d'état d'erreur illustré sobrement
/// ---------------------------------------------------------------------------
class IllustratedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const IllustratedErrorState({
    super.key,
    required this.message,
    required this.onRetry,
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
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: TwColors.danger50,
                borderRadius: TwRadius.r3xl,
              ),
              child: const Icon(Icons.cloud_off, size: 38, color: TwColors.danger600),
            ),
            const SizedBox(height: TwSpace.s5),
            Text(
              context.tr('conn_error'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.tw.textPrimary,
              ),
            ),
            const SizedBox(height: TwSpace.s2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.tw.textSecondary),
            ),
            const SizedBox(height: TwSpace.s6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: TwSpace.s3,
              runSpacing: TwSpace.s3,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ServerSettingsDialog.show(context),
                  icon: const Icon(Icons.settings, size: 18),
                  label: Text(context.tr('server_settings')),
                ),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(context.tr('retry')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Boîte de dialogue de configuration du serveur Backend PHP
/// ---------------------------------------------------------------------------
class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ServerSettingsDialog(),
    );
  }

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late final TextEditingController _controller;
  bool _testing = false;
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _isConnected = null;
    });

    final ok = await ApiConfig.checkHealth(_controller.text.trim());

    if (!mounted) return;
    setState(() {
      _testing = false;
      _isConnected = ok;
    });
  }

  Future<void> _save() async {
    await ApiConfig.save(_controller.text);
    if (!mounted) return;
    final message = context.tr('srv_saved', {'url': ApiConfig.baseUrl});
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TwColors.brand600,
      ),
    );
  }

  Future<void> _resetDefault() async {
    await ApiConfig.save(null);
    if (!mounted) return;
    _controller.text = ApiConfig.defaultBaseUrl;
    setState(() {
      _isConnected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? statusMessage = _isConnected == null
        ? null
        : (_isConnected == true ? context.tr('srv_ok') : context.tr('srv_fail'));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: TwRadius.r3xl),
      title: Row(
        children: [
          const Icon(Icons.dns_outlined, color: TwColors.brand600),
          const SizedBox(width: TwSpace.s25),
          Expanded(
            child: Text(
              context.tr('srv_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.tw.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('srv_address'),
              style: TextStyle(fontSize: 13, color: context.tw.textSecondary),
            ),
            const SizedBox(height: TwSpace.s2),
            TextField(
              controller: _controller,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.tw.background,
                border: OutlineInputBorder(
                  borderRadius: TwRadius.rXl,
                  borderSide: BorderSide(color: context.tw.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: TwSpace.s3),
            Text(
              context.tr('srv_hint'),
              style: TextStyle(fontSize: 11, color: context.tw.textSecondary, height: 1.3),
            ),
            if (statusMessage != null) ...[
              const SizedBox(height: TwSpace.s3),
              Container(
                padding: const EdgeInsets.all(TwSpace.s25),
                decoration: BoxDecoration(
                  color: _isConnected == true ? TwColors.success50 : TwColors.danger50,
                  borderRadius: TwRadius.rXl,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected == true ? Icons.check_circle : Icons.error_outline,
                      color: _isConnected == true ? TwColors.success600 : TwColors.danger600,
                      size: 20,
                    ),
                    const SizedBox(width: TwSpace.s2),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isConnected == true ? TwColors.success600 : TwColors.danger600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: TwSpace.s35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _testing ? null : _testConnection,
                  icon: _testing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('test'), style: const TextStyle(fontSize: 12)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TwColors.brand600,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                TextButton(
                  onPressed: _resetDefault,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('default'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}
