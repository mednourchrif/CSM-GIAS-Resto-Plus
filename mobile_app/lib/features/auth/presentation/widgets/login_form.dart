import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';

class LoginForm extends StatefulWidget {
  final String? error;
  final bool isLoading;
  final void Function(String email, String password) onSubmit;

  const LoginForm({
    super.key,
    this.error,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: _validateEmail,
            enabled: !widget.isLoading,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),

          const SizedBox(height: Spacing.md),

          // Password
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                tooltip: _obscurePassword
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            enabled: !widget.isLoading,
            onFieldSubmitted: (_) => _submit(),
          ),

          // Error banner
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: widget.error != null
                ? Padding(
                    key: const ValueKey('error'),
                    padding: const EdgeInsets.only(top: Spacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.sm + 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: Spacing.iconSm,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              widget.error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-error')),
          ),

          const SizedBox(height: Spacing.xl),

          // Submit button
          SizedBox(
            height: Spacing.minTouchTarget + 4,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}
