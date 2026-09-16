import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_gradient_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez saisir votre adresse e-mail.',
          ),
        ),
      );
      return;
    }

    final failure = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(email);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failure == null
              ? 'Un e-mail de réinitialisation a été envoyé.'
              : failure.message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        if (context.mounted) {
          context.go('/home');
        }
      }
    });

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildBrandPanel(
                      context,
                      theme,
                      colors,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _buildLoginPanel(
                      context,
                      theme,
                      colors,
                      authState.isLoading,
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                  ),
                  child: _buildLoginCard(
                    context,
                    theme,
                    colors,
                    authState.isLoading,
                    showMobileLogo: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.article_rounded,
              size: 34,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'MiniBlog',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bienvenue sur MiniBlog',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Connectez-vous pour accéder à votre espace',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    bool isLoading,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: _buildLoginCard(
            context,
            theme,
            colors,
            isLoading,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    bool isLoading, {
    bool showMobileLogo = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showMobileLogo) ...[
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      size: 30,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Bienvenue sur MiniBlog',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous pour accéder à votre espace',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              AuthField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir votre adresse e-mail.';
                  }

                  if (!value.contains('@')) {
                    return 'Veuillez saisir une adresse e-mail valide.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: _passwordController,
                label: 'Mot de passe',
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre mot de passe.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : _sendPasswordReset,
                  child: const Text(
                    'Mot de passe oublié ?',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuthGradientButton(
                text: isLoading
                    ? 'Connexion...'
                    : 'Se connecter',
                onPressed: isLoading ? null : _login,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colors.outlineVariant,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Text(
                      'OU',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: colors.outlineVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () => context.go('/signup'),
                child: const Text(
                  'Créer un compte',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}