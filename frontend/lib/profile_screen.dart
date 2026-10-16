import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'auth_errors.dart';
import 'category_progress.dart';
import 'certificates.dart';
import 'certificates_screen.dart';
import 'services/auth_service.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';
import 'user_progress.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String _formatTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

/// ---------------------------------------------------------------------------
/// Profil de l'utilisateur connecté : identité, statistiques, badges, certificats.
/// Tout est enregistré sur le compte (voir AuthService.syncProgress).
/// ---------------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _busy = false;
  String? _message;
  bool _isError = false;

  void _setMessage(String? message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = message;
      _isError = error;
    });
  }

  Future<void> _sync() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await AuthService.instance.syncProgress();
      if (!mounted) return;
      _setMessage(context.tr('auth_synced'));
    } catch (e) {
      if (!mounted) return;
      _setMessage(authErrorText(context, e), error: true);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: AuthService.instance.user?.name ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('profile_edit_name')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: ctx.tr('cert_name_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(ctx.tr('cert_save')),
          ),
        ],
      ),
    );
    if (saved == null || saved.trim().isEmpty || !mounted) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await AuthService.instance.updateName(saved);
      // Le certificat reprend le nom du compte.
      await CertificateManager.instance.setName('');
      if (!mounted) return;
      _setMessage(context.tr('profile_name_saved'));
    } catch (e) {
      if (!mounted) return;
      _setMessage(authErrorText(context, e), error: true);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('auth_logout')),
        content: Text(ctx.tr('auth_logout_note')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.tr('auth_logout')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await AuthService.instance.logout();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _setMessage(authErrorText(context, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.tw.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(context.tr('profile_title')),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            AuthService.instance,
            UserProgress.instance,
            StageProgressManager.instance,
            CertificateManager.instance,
          ]),
          builder: (context, _) {
            final user = AuthService.instance.user;
            final stats = UserProgress.instance;
            final certificates = CertificateManager.instance;
            final lastSync = AuthService.instance.lastSync;
            final name = user?.name ?? '';
            final earned = CertificateManager.all.where(certificates.isEarned).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                // ── Identité ──────────────────────────────────────
                Center(
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.tw.textSecondary),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _editName,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(context.tr('profile_edit_name')),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('profile_saved_note'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: context.tw.textSecondary, height: 1.4),
                ),

                // ── Statistiques ──────────────────────────────────
                _SectionTitle(context.tr('profile_stats')),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 10) / 2;
                    final tiles = <(IconData, String, String)>[
                      (Icons.quiz_outlined, context.tr('profile_quizzes'), '${stats.totalQuizDone}'),
                      (Icons.help_outline, context.tr('profile_questions'), '${stats.totalQuestions}'),
                      (Icons.percent, context.tr('profile_accuracy'), '${stats.globalAccuracy.round()} %'),
                      (
                        Icons.local_fire_department,
                        context.tr('profile_streak'),
                        context.tr('profile_days', {'n': '${stats.activeStreak}'}),
                      ),
                      (
                        Icons.emoji_events_outlined,
                        context.tr('profile_best_streak'),
                        context.tr('profile_days', {'n': '${stats.bestStreak}'}),
                      ),
                      (Icons.star_rounded, context.tr('profile_stars'), '${totalStars()}/${totalMaxStars()}'),
                    ];
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final tile in tiles)
                          SizedBox(
                            width: width,
                            child: _StatTile(icon: tile.$1, label: tile.$2, value: tile.$3),
                          ),
                      ],
                    );
                  },
                ),

                // ── Badges ────────────────────────────────────────
                _SectionTitle(context.tr('profile_badges')),
                if (stats.badges.isEmpty)
                  Text(
                    context.tr('profile_no_badges'),
                    style: TextStyle(color: context.tw.textSecondary),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final badge in (stats.badges.toList()..sort()))
                        Chip(
                          avatar: const Icon(Icons.military_tech, size: 18, color: TwColors.gold500),
                          label: Text(context.tr('badge_$badge')),
                        ),
                    ],
                  ),

                // ── Certificats ───────────────────────────────────
                _SectionTitle(context.tr('profile_certificates')),
                if (earned.isEmpty)
                  Text(
                    context.tr('profile_no_certificates'),
                    style: TextStyle(color: context.tw.textSecondary),
                  )
                else
                  for (final category in earned)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium, color: TwColors.gold500, size: 28),
                        title: Text(
                          category.titleOf(context),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text([
                          if (certificates.earnedOn(category) != null)
                            context.tr('cert_date', {
                              'date':
                                  '${_two(certificates.earnedOn(category)!.day)}/${_two(certificates.earnedOn(category)!.month)}/${certificates.earnedOn(category)!.year}',
                            }),
                          if (certificates.codeOf(category) != null)
                            context.tr('cert_code', {'code': certificates.codeOf(category)!}),
                        ].join('\n')),
                        isThreeLine: certificates.codeOf(category) != null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CertificateScreen(category: category),
                          ),
                        ),
                      ),
                    ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                  ),
                  child: Text(context.tr('cert_my')),
                ),

                // ── Synchronisation et déconnexion ────────────────
                const SizedBox(height: 12),
                Text(
                  lastSync == null
                      ? context.tr('profile_never_synced')
                      : context.tr('profile_last_sync', {'time': _formatTime(lastSync)}),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: context.tw.textSecondary),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _isError ? scheme.error : scheme.primary),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _sync,
                  icon: const Icon(Icons.sync),
                  label: Text(context.tr('auth_sync_now')),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: Text(context.tr('auth_logout')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: context.tw.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
