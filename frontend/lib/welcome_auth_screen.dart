import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_strings.dart';
import 'auth_screen.dart';
import 'config/api_config.dart';
import 'language_button.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';
import 'theme_button.dart';

/// ---------------------------------------------------------------------------
/// WelcomeAuthScreen : Écran de démarrage avec choix préalable obligatoire
/// entre « Se connecter à mon compte » et « Continuer sans compte ».
/// ---------------------------------------------------------------------------
class WelcomeAuthScreen extends StatefulWidget {
  final VoidCallback onContinueWithoutAccount;
  final VoidCallback onLoginSuccess;

  const WelcomeAuthScreen({
    super.key,
    required this.onContinueWithoutAccount,
    required this.onLoginSuccess,
  });

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  bool _openingLogin = false;

  Future<void> _openLogin() async {
    if (_openingLogin) return;
    setState(() => _openingLogin = true);

    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );

    if (mounted) {
      setState(() => _openingLogin = false);
      if (loggedIn == true || AuthService.instance.isLoggedIn) {
        widget.onLoginSuccess();
      }
    }
  }

  void _openServerSettings() {
    final ctrl = TextEditingController(text: ApiConfig.baseUrl);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('srv_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ctx.tr('srv_address'), style: TwText.bodySm(ctx)),
            const SizedBox(height: TwSpace.s2),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              await ApiConfig.save(ctrl.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(ctx.tr('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);

    return Scaffold(
      backgroundColor: tw.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Barre supérieure discrète (Langue, Thème, Réglages)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge décoratif subtil
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? TwColors.brandTintDark : TwColors.brand50,
                          borderRadius: TwRadius.pill,
                          border: Border.all(
                            color: isDark ? TwColors.brand800 : TwColors.brand200,
                            width: TwBorder.thin,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 13,
                              color: isDark ? TwColors.gold400 : TwColors.brand700,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ÉDITION OFFICIELLE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: TwWeight.extrabold,
                                letterSpacing: 0.5,
                                color: isDark ? TwColors.brand300 : TwColors.brand800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions Réglages
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LanguageButton(),
                          const SizedBox(width: 4),
                          const ThemeButton(),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: context.tr('srv_title'),
                            icon: Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: tw.textSecondary,
                            ),
                            onPressed: _openServerSettings,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Contenu central scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),

                          // Emblème & Logo central
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [TwColors.brand600, TwColors.brand800],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: TwColors.brand500.withValues(alpha: 0.35),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: TwColors.gold400.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 42,
                                color: Colors.white,
                              ),
                            ),
                          ).animate().scale(
                                duration: TwMotion.d300,
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: 20),

                          // Titre principal
                          Text(
                            context.tr('welcome_title'),
                            textAlign: TextAlign.center,
                            style: TwText.h2(context).copyWith(
                              fontWeight: TwWeight.extrabold,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(duration: TwMotion.d300),

                          const SizedBox(height: 8),

                          // Sous-titre
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.tr('welcome_tagline'),
                              textAlign: TextAlign.center,
                              style: TwText.body(context).copyWith(
                                color: tw.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: TwMotion.d300),

                          const SizedBox(height: 28),

                          // 3 Avantages clés en mini-cartes Bento
                          _FeatureRow(
                            icon: Icons.cloud_done_rounded,
                            iconColor: TwColors.brand500,
                            title: context.tr('welcome_feat_cloud_title'),
                            desc: context.tr('welcome_feat_cloud_desc'),
                          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 10),

                          _FeatureRow(
                            icon: Icons.workspace_premium_rounded,
                            iconColor: TwColors.gold500,
                            title: context.tr('welcome_feat_cert_title'),
                            desc: context.tr('welcome_feat_cert_desc'),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 10),

                          _FeatureRow(
                            icon: Icons.bolt_rounded,
                            iconColor: isDark ? TwColors.brand400 : TwColors.brand600,
                            title: context.tr('welcome_feat_offline_title'),
                            desc: context.tr('welcome_feat_offline_desc'),
                          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),

                  // Zone des 2 Choix d'accès (Boutons d'action)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Option 1 : Se connecter à mon compte (Primary CTA)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: TwRadius.r2xl,
                          onTap: _openLogin,
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [TwColors.brand600, TwColors.brand700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: TwRadius.r2xl,
                              boxShadow: [
                                BoxShadow(
                                  color: TwColors.brand600.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: TwBorder.thin,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.login_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.tr('welcome_login_btn'),
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: TwWeight.extrabold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.tr('welcome_login_desc'),
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 12),

                      // Option 2 : Continuer sans compte (Secondary Button)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: TwRadius.r2xl,
                          onTap: widget.onContinueWithoutAccount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: tw.surface,
                              borderRadius: TwRadius.r2xl,
                              border: Border.all(
                                color: tw.border,
                                width: TwBorder.thin,
                              ),
                              boxShadow: TwShadow.sm(context),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? TwColors.brandTintDark
                                        : TwColors.brand50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: 22,
                                    color: isDark
                                        ? TwColors.brand300
                                        : TwColors.brand700,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.tr('welcome_guest_btn'),
                                        style: TwText.body(context).copyWith(
                                          fontWeight: TwWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.tr('welcome_guest_desc'),
                                        style: TwText.caption(context).copyWith(
                                          color: tw.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: tw.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 12),

                      // Mention discrète
                      Text(
                        context.tr('welcome_hint'),
                        textAlign: TextAlign.center,
                        style: TwText.caption(context).copyWith(
                          fontSize: 10.5,
                          color: tw.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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

/// Ligne d'avantage avec icône et texte condensé
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final isDark = TwSurface.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? tw.surface : tw.surface,
        borderRadius: TwRadius.rXl,
        border: Border.all(
          color: tw.border,
          width: TwBorder.thin,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: TwRadius.rDefault,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TwText.bodySm(context).copyWith(
                    fontWeight: TwWeight.extrabold,
                  ),
                ),
                Text(
                  desc,
                  style: TwText.caption(context).copyWith(
                    color: tw.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
