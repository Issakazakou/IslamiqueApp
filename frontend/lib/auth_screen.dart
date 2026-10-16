import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'auth_errors.dart';
import 'profile_screen.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';

/// Ouvre l'écran de connexion (compte déconnecté) ou le profil (connecté).
void openAccount(BuildContext context) {
  if (AuthService.instance.isLoggedIn) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Écran de connexion / création de compte
/// ---------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _registerMode = true;
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_registerMode) {
        await AuthService.instance.register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        await AuthService.instance.login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = authErrorText(context, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tw = context.tw;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: tw.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(context.tr(_registerMode ? 'auth_register' : 'auth_login')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Largeur limitée : le formulaire reste lisible sur tablette et web.
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Icon(Icons.account_circle_outlined, size: 64, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  context.tr('auth_intro'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tw.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(context.tr('auth_register'))),
                    ButtonSegment(value: false, label: Text(context.tr('auth_login'))),
                  ],
                  selected: {_registerMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() {
                    _registerMode = s.first;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        if (_registerMode) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: InputDecoration(
                              labelText: context.tr('auth_name'),
                              prefixIcon: const Icon(Icons.person_outline),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? context.tr('auth_err_name')
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: context.tr('auth_email'),
                            prefixIcon: const Icon(Icons.mail_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch((v ?? '').trim())
                              ? null
                              : context.tr('auth_err_email'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: [
                            _registerMode
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: context.tr('auth_password'),
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return context.tr('auth_err_password');
                            if (_registerMode && value.length < 8) {
                              return context.tr('auth_err_password');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.tr(_registerMode ? 'auth_register' : 'auth_login')),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                  child: Text(context.tr('auth_skip')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
