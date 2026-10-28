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
    final isDark = TwSurface.isDark(context);

    return Scaffold(
      backgroundColor: tw.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(
          context.tr(_registerMode ? 'auth_register' : 'auth_login'),
          style: TwText.h3(context).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Emblème supérieur
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14573F), Color(0xFF0E3B2C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TwColors.brand600.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: TwColors.gold400.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auth_intro'),
                  textAlign: TextAlign.center,
                  style: TwText.bodySm(context).copyWith(
                    color: tw.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),

                // Sélecteur d'onglet Inscription / Connexion raffiné
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tw.surfaceSubtle,
                    borderRadius: TwRadius.pill,
                    border: Border.all(color: tw.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _registerMode = true;
                            _error = null;
                          }),
                          child: AnimatedContainer(
                            duration: TwMotion.d200,
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _registerMode ? tw.surface : Colors.transparent,
                              borderRadius: TwRadius.pill,
                              boxShadow: _registerMode ? TwShadow.sm(context) : null,
                            ),
                            child: Text(
                              context.tr('auth_register'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: _registerMode ? FontWeight.w600 : FontWeight.w500,
                                color: _registerMode ? tw.textPrimary : tw.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _registerMode = false;
                            _error = null;
                          }),
                          child: AnimatedContainer(
                            duration: TwMotion.d200,
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_registerMode ? tw.surface : Colors.transparent,
                              borderRadius: TwRadius.pill,
                              boxShadow: !_registerMode ? TwShadow.sm(context) : null,
                            ),
                            child: Text(
                              context.tr('auth_login'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: !_registerMode ? FontWeight.w600 : FontWeight.w500,
                                color: !_registerMode ? tw.textPrimary : tw.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Formulaire encadré dans une carte moderne
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tw.surface,
                    borderRadius: TwRadius.r2xl,
                    border: Border.all(color: tw.border),
                    boxShadow: TwShadow.sm(context),
                  ),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          if (_registerMode) ...[
                            TextFormField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              style: TextStyle(color: tw.textPrimary, fontSize: 14.5),
                              decoration: InputDecoration(
                                labelText: context.tr('auth_name'),
                                labelStyle: TextStyle(color: tw.textSecondary, fontSize: 13.5),
                                prefixIcon: Icon(Icons.person_outline_rounded, color: tw.textSecondary, size: 20),
                                filled: true,
                                fillColor: tw.surfaceSubtle.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: TwRadius.rXl,
                                  borderSide: BorderSide(color: tw.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: TwRadius.rXl,
                                  borderSide: BorderSide(color: tw.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: TwRadius.rXl,
                                  borderSide: const BorderSide(color: TwColors.brand600, width: 1.5),
                                ),
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
                            style: TextStyle(color: tw.textPrimary, fontSize: 14.5),
                            decoration: InputDecoration(
                              labelText: context.tr('auth_email'),
                              labelStyle: TextStyle(color: tw.textSecondary, fontSize: 13.5),
                              prefixIcon: Icon(Icons.mail_outline_rounded, color: tw.textSecondary, size: 20),
                              filled: true,
                              fillColor: tw.surfaceSubtle.withValues(alpha: 0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: BorderSide(color: tw.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: BorderSide(color: tw.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: const BorderSide(color: TwColors.brand600, width: 1.5),
                              ),
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
                            style: TextStyle(color: tw.textPrimary, fontSize: 14.5),
                            decoration: InputDecoration(
                              labelText: context.tr('auth_password'),
                              labelStyle: TextStyle(color: tw.textSecondary, fontSize: 13.5),
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: tw.textSecondary, size: 20),
                              filled: true,
                              fillColor: tw.surfaceSubtle.withValues(alpha: 0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: BorderSide(color: tw.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: BorderSide(color: tw.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: TwRadius.rXl,
                                borderSide: const BorderSide(color: TwColors.brand600, width: 1.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: tw.textSecondary,
                                  size: 20,
                                ),
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
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: TwTone.danger.tint(context),
                      borderRadius: TwRadius.rLg,
                      border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Bouton principal d'action
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: TwRadius.r2xl,
                    onTap: _busy ? null : _submit,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: TwColors.gold400.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                context.tr(_registerMode ? 'auth_register' : 'auth_login'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                  child: Text(
                    context.tr('auth_skip'),
                    style: TextStyle(
                      color: tw.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
