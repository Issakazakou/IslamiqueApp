import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width >= 600 ? 540 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Barre supérieure discrète (Langue, Thème, Réglages)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge spirituel d'accueil
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                              Icons.auto_awesome,
                              size: 13,
                              color: isDark ? TwColors.gold400 : TwColors.gold500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: GoogleFonts.amiri(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? TwColors.gold300 : TwColors.brand800,
                                height: 1.2,
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
                            style: TwText.display(context, size: 28).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ).animate().fadeIn(duration: TwMotion.d300),

                          const SizedBox(height: 8),

                          // Sous-titre
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              context.tr('welcome_tagline'),
                              textAlign: TextAlign.center,
                              style: TwText.body(context).copyWith(
                                color: tw.textSecondary,
                                height: 1.5,
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
                                colors: [Color(0xFF14573F), Color(0xFF0E3B2C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: TwRadius.r2xl,
                              boxShadow: [
                                BoxShadow(
                                  color: TwColors.brand600.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: TwColors.gold400.withValues(alpha: 0.3),
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
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        context.tr('welcome_login_desc'),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.white.withValues(alpha: 0.88),
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
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        context.tr('welcome_guest_desc'),
                                        style: TwText.bodySm(context).copyWith(
                                          color: tw.textSecondary,
                                          fontSize: 12.5,
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
                          fontSize: 12,
                          color: tw.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: TwRadius.rDefault,
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TwText.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TwText.bodySm(context).copyWith(
                    color: tw.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
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
