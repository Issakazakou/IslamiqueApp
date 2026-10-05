import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'user_progress.dart';

/// ---------------------------------------------------------------------------
/// Écran Premium — Offre d'abonnement professionnelle
/// ---------------------------------------------------------------------------
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumManager = PremiumManager.instance;

    return Scaffold(
      backgroundColor: TwColors.brand700,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header avec bouton fermer ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // ── Icône couronne ──
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              TwColors.gold500,
                              TwColors.gold800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TwColors.gold500.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white, size: 44),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Devenez Premium',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Accédez à toutes les fonctionnalités\npour progresser sans limite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withAlpha(180),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Liste des avantages ──
                      _FeatureItem(
                        icon: Icons.all_inclusive,
                        title: 'Quiz illimités',
                        subtitle: 'Sans restriction quotidienne',
                      ),
                      _FeatureItem(
                        icon: Icons.lock_open_outlined,
                        title: 'Tous les niveaux débloqués',
                        subtitle: 'Débutant, Intermédiaire et Avancé',
                      ),
                      _FeatureItem(
                        icon: Icons.bar_chart,
                        title: 'Statistiques avancées',
                        subtitle: 'Suivi complet de votre progression',
                      ),
                      _FeatureItem(
                        icon: Icons.emoji_events_outlined,
                        title: 'Tous les badges',
                        subtitle: 'Débloquez des récompenses exclusives',
                      ),
                      _FeatureItem(
                        icon: Icons.block,
                        title: 'Sans publicité',
                        subtitle: 'Une expérience fluide et sans interruption',
                      ),

                      const SizedBox(height: 28),

                      // ── Carte de prix ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: TwColors.gold500.withAlpha(80), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'XOF ',
                                  style: TextStyle(
                                    color: TwColors.gold500,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.6,
                                  ),
                                ),
                                const Text(
                                  '2 000',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'par mois',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: TwColors.gold500.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '🕌 Essai gratuit de 7 jours',
                                style: TextStyle(
                                  color: TwColors.gold500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Bouton d'achat principal ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            premiumManager.unlockPremium();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.workspace_premium, color: TwColors.gold500),
                                    SizedBox(width: 10),
                                    Text(
                                      'Bienvenue dans le club Premium ! ✨',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                backgroundColor: TwColors.brand700,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TwColors.gold500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.workspace_premium, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Commencer l\'essai gratuit',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Continuer gratuitement',
                          style: TextStyle(
                            color: Colors.white.withAlpha(140),
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Annulez à tout moment. Paiement sécurisé\nvia Google Play / App Store.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withAlpha(80),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TwColors.gold500.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TwColors.gold500, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: TwColors.gold500, size: 20),
        ],
      ),
    );
  }
}
