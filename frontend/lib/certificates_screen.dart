import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_strings.dart';
import 'category_progress.dart';
import 'certificates.dart';
import 'quiz_models.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

void _openCertificate(BuildContext context, QuizCategory category) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => CertificateScreen(category: category)),
  );
}

/// ---------------------------------------------------------------------------
/// Carte « Mes certificats » de l'accueil
/// ---------------------------------------------------------------------------
class CertificatesCard extends StatelessWidget {
  const CertificatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        StageProgressManager.instance,
        CertificateManager.instance,
      ]),
      builder: (context, _) {
        final manager = CertificateManager.instance;
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.workspace_premium, color: TwColors.gold500, size: 30),
            title: Text(
              context.tr('cert_my'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(context.tr('cert_count', {
              'n': manager.earnedCount.toString(),
              'total': CertificateManager.all.length.toString(),
            })),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CertificatesScreen()),
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Liste des certificats (obtenus ou à débloquer)
/// ---------------------------------------------------------------------------
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tw.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(context.tr('cert_my')),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            StageProgressManager.instance,
            CertificateManager.instance,
          ]),
          builder: (context, _) {
            final manager = CertificateManager.instance;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final category in CertificateManager.all)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CertificateTile(category: category, manager: manager),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  final QuizCategory category;
  final CertificateManager manager;

  const _CertificateTile({required this.category, required this.manager});

  @override
  Widget build(BuildContext context) {
    final done = manager.completedStages(category);
    final total = manager.totalStages(category);
    final earned = manager.isEarned(category);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          earned ? Icons.workspace_premium : Icons.lock_outline,
          color: earned ? TwColors.gold500 : context.tw.textSecondary,
          size: 28,
        ),
        title: Text(
          category.titleOf(context),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: total == 0 ? 0 : (done / total).clamp(0.0, 1.0),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('cert_progress', {
                  'done': done.toString(),
                  'total': total.toString(),
                }),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: earned ? const Icon(Icons.chevron_right) : null,
        onTap: () {
          if (earned) {
            _openCertificate(context, category);
            return;
          }
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('cert_locked', {
                'n': (total - done).toString(),
              })),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Le certificat lui-même
/// ---------------------------------------------------------------------------
class CertificateScreen extends StatefulWidget {
  final QuizCategory category;

  const CertificateScreen({super.key, required this.category});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    // Premier certificat sans nom connu : on demande le nom à imprimer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && CertificateManager.instance.name.isEmpty) _editName();
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: CertificateManager.instance.name);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('cert_name_prompt')),
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
    if (saved != null && saved.trim().isNotEmpty) {
      await CertificateManager.instance.setName(saved);
    }
  }

  String _plainText(BuildContext context, String name, DateTime? date, String? code) {
    final category = widget.category;
    return [
      context.tr('cert_title'),
      '${context.tr('cert_awarded_to')} $name',
      '${context.tr('cert_for')} ${category.titleOf(context)}',
      context.tr('cert_stars', {
        'stars': categoryStars(category).toString(),
        'max': categoryMaxStars(category).toString(),
      }),
      if (date != null) context.tr('cert_date', {'date': _formatDate(date)}),
      if (code != null) context.tr('cert_code', {'code': code}),
      context.tr('app_name'),
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = widget.category;

    return Scaffold(
      backgroundColor: context.tw.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(context.tr('cert_title')),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: CertificateManager.instance,
          builder: (context, _) {
            final manager = CertificateManager.instance;
            final name = manager.name;
            final date = manager.earnedOn(category);
            final code = manager.codeOf(category);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Cadre doré
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: TwColors.goldGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium, size: 64, color: TwColors.gold500),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('cert_title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.tr('cert_awarded_to'),
                          style: TextStyle(color: context.tw.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name.isEmpty ? '…' : name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.tr('cert_for'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.tw.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.titleOf(context),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: TwColors.gold500),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('cert_stars', {
                                'stars': categoryStars(category).toString(),
                                'max': categoryMaxStars(category).toString(),
                              }),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        if (date != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            context.tr('cert_date', {'date': _formatDate(date)}),
                            style: TextStyle(color: context.tw.textSecondary),
                          ),
                        ],
                        if (code != null) ...[
                          const SizedBox(height: 6),
                          SelectableText(
                            context.tr('cert_code', {'code': code}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          context.tr('app_name'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: context.tw.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _editName,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.tr('cert_edit_name')),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _plainText(context, name, date, code)),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('cert_copied'))),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(context.tr('cert_copy')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Bannière « certificat obtenu » (écran de résultat)
/// ---------------------------------------------------------------------------
class CertificateBanner extends StatelessWidget {
  final QuizCategory category;

  const CertificateBanner({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: TwColors.gold500, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('cert_earned_banner', {'title': category.titleOf(context)}),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => _openCertificate(context, category),
              child: Text(context.tr('cert_view')),
            ),
          ],
        ),
      ),
    );
  }
}
