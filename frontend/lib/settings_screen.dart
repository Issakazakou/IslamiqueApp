import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'config/api_config.dart';
import 'user_progress.dart';
import 'widgets.dart';

/// ---------------------------------------------------------------------------
/// Écran Paramètres — Réglages complets de l'application
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Paramètres locaux (en prod → SharedPreferences)
  int    _questionsPerQuiz = 10;
  bool   _shuffle          = true;
  bool   _instantFeedback  = true;
  bool   _enableTimer      = false;
  int    _timerSeconds     = 20;
  bool   _soundEffects     = true;
  bool   _vibration        = true;

  // Serveur backend
  late TextEditingController _urlController;
  bool   _testingConn      = false;
  bool?  _connOk;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() { _testingConn = true; _connOk = null; });
    final ok = await ApiConfig.checkHealth(_urlController.text.trim());
    if (!mounted) return;
    setState(() { _testingConn = false; _connOk = ok; });
  }

  Future<void> _saveServerUrl() async {
    await ApiConfig.save(_urlController.text);
    if (!mounted) return;
    setState(() => _connOk = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Adresse serveur mise à jour !'),
        backgroundColor: TwColors.brand600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Paramètres',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: TwColors.brand700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [

                  // ═══════════════════════════════════════════════
                  // SECTION 1 : SERVEUR BACKEND
                  // ═══════════════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.dns_outlined,
                    label: 'Serveur Backend',
                    color: TwColors.brand600,
                  ),

                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adresse du serveur PHP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: TwColors.brand700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• Adresse IP directe : http://100.109.88.197:8000\n'
                          '• PC / Localhost : http://127.0.0.1:8000\n'
                          '• Émulateur Android : http://10.0.2.2:8000',
                          style: TextStyle(fontSize: 11, color: TwColors.slate600, height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: TwColors.slate50,
                            hintText: 'http://100.109.88.197:8000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: TwColors.slate200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: TwColors.slate200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: TwColors.brand600, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                          onChanged: (_) => setState(() => _connOk = null),
                        ),

                        if (_connOk != null) ...[
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _connOk! ? TwColors.success50 : TwColors.danger50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _connOk! ? Icons.check_circle : Icons.error_outline,
                                  size: 16,
                                  color: _connOk! ? TwColors.success600 : TwColors.danger600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _connOk!
                                        ? 'Connexion établie — Le backend PHP répond !'
                                        : 'Impossible de joindre le serveur. Vérifiez l\'adresse et que PHP est lancé.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _connOk! ? TwColors.success600 : TwColors.danger600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _testingConn ? null : _testConnection,
                                icon: _testingConn
                                    ? const SizedBox(
                                        width: 14, height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.network_check, size: 16),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Tester'),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: TwColors.brand600,
                                  side: const BorderSide(color: TwColors.brand600),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveServerUrl,
                                icon: const Icon(Icons.save_outlined, size: 16),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Enregistrer'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TwColors.brand600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Statut actuel protégé contre les débordements
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _connOk == true ? TwColors.success600
                                    : _connOk == false ? TwColors.danger600
                                    : TwColors.slate600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Serveur actuel : ${ApiConfig.baseUrl}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: TwColors.slate600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ═══════════════════════════════════════════════
                  // SECTION 2 : QUIZ
                  // ═══════════════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.quiz_outlined,
                    label: 'Expérience Quiz',
                    color: TwColors.brand600,
                  ),

                  _SettingsCard(
                    child: Column(
                      children: [
                        // Nombre de questions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Questions par quiz',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: TwColors.brand700,
                                    ),
                                  ),
                                  Text(
                                    'Nombre de questions par session',
                                    style: TextStyle(fontSize: 12, color: TwColors.slate600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: TwColors.slate200),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_questionsPerQuiz > 5) {
                                        setState(() => _questionsPerQuiz -= 5);
                                      }
                                    },
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      child: Icon(Icons.remove, size: 18, color: TwColors.brand700),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '$_questionsPerQuiz',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: TwColors.brand700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_questionsPerQuiz < 25) {
                                        setState(() => _questionsPerQuiz += 5);
                                      }
                                    },
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      child: Icon(Icons.add, size: 18, color: TwColors.brand700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24, color: TwColors.slate200),

                        _ToggleRow(
                          icon: Icons.shuffle,
                          label: 'Questions aléatoires',
                          subtitle: 'Mélanger l\'ordre des questions',
                          value: _shuffle,
                          onChanged: (v) => setState(() => _shuffle = v),
                        ),

                        const Divider(height: 20, color: TwColors.slate200),

                        _ToggleRow(
                          icon: Icons.lightbulb_outline,
                          label: 'Correction instantanée',
                          subtitle: 'Afficher la bonne réponse après chaque question',
                          value: _instantFeedback,
                          onChanged: (v) => setState(() => _instantFeedback = v),
                        ),

                        const Divider(height: 20, color: TwColors.slate200),

                        _ToggleRow(
                          icon: Icons.timer_outlined,
                          label: 'Minuteur par question',
                          subtitle: 'Répondez avant la fin du temps',
                          value: _enableTimer,
                          onChanged: (v) => setState(() => _enableTimer = v),
                          trailing: _enableTimer
                              ? Chip(
                                  label: Text('$_timerSeconds s'),
                                  backgroundColor: TwColors.brand100,
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: TwColors.brand700,
                                  ),
                                  padding: EdgeInsets.zero,
                                )
                              : null,
                        ),

                        if (_enableTimer) ...[
                          const SizedBox(height: 8),
                          Slider(
                            value: _timerSeconds.toDouble(),
                            min: 10,
                            max: 60,
                            divisions: 10,
                            activeColor: TwColors.brand600,
                            inactiveColor: TwColors.brand100,
                            label: '$_timerSeconds s',
                            onChanged: (v) => setState(() => _timerSeconds = v.toInt()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('10 s', style: TextStyle(fontSize: 11, color: TwColors.slate600)),
                              Text('60 s', style: TextStyle(fontSize: 11, color: TwColors.slate600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ═══════════════════════════════════════════════
                  // SECTION 3 : SON & HAPTIQUE
                  // ═══════════════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.tune,
                    label: 'Son & Retour haptique',
                    color: TwColors.gold500,
                  ),

                  _SettingsCard(
                    child: Column(
                      children: [
                        _ToggleRow(
                          icon: Icons.volume_up_outlined,
                          label: 'Effets sonores',
                          subtitle: 'Son sur bonne/mauvaise réponse',
                          value: _soundEffects,
                          onChanged: (v) => setState(() => _soundEffects = v),
                        ),
                        const Divider(height: 20, color: TwColors.slate200),
                        _ToggleRow(
                          icon: Icons.vibration,
                          label: 'Vibration',
                          subtitle: 'Retour haptique sur les réponses',
                          value: _vibration,
                          onChanged: (v) => setState(() => _vibration = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ═══════════════════════════════════════════════
                  // SECTION 4 : COMPTE & DONNÉES
                  // ═══════════════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Compte & Données',
                    color: TwColors.danger600,
                  ),

                  _SettingsCard(
                    child: Column(
                      children: [
                        _ActionRow(
                          icon: Icons.delete_sweep_outlined,
                          label: 'Réinitialiser ma progression',
                          subtitle: 'Supprimer scores, badges et statistiques',
                          color: TwColors.danger600,
                          onTap: () => _confirmReset(context),
                        ),
                        const Divider(height: 20, color: TwColors.slate200),
                        _ActionRow(
                          icon: Icons.info_outline,
                          label: 'À propos de l\'application',
                          subtitle: 'Version 1.0.0 — Quiz Islamique',
                          color: TwColors.brand600,
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'Quiz Islamique',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2026 Quiz Islamique\nTous droits réservés.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Réinitialiser la progression',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          'Toutes vos statistiques, badges et scores seront effacés.\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              UserProgress.instance.reset();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Progression réinitialisée.'),
                  backgroundColor: TwColors.danger600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TwColors.danger600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}

// ─── Sous-widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TwColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: TwColors.slate50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: TwColors.brand700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: TwColors.brand700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: TwColors.slate600),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          trailing!,
          const SizedBox(width: 8),
        ],
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: TwColors.brand600,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: TwColors.slate600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: color.withAlpha(150)),
        ],
      ),
    );
  }
}
