import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_gradient_button.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final verifyPasswordController = TextEditingController();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          displayName: displayNameController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);

    state.whenOrNull(
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    verifyPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: colors.primary,
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 480,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.article_rounded,
                                size: 72,
                                color: colors.onPrimary,
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
                                'Créer un compte',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Rejoignez la communauté MiniBlog',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildForm(
                      context,
                      authState.isLoading,
                    ),
                  ),
                ],
              );
            }

            return _buildForm(
              context,
              authState.isLoading,
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (MediaQuery.sizeOf(context).width < 900) ...[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 32,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rejoignez la communauté MiniBlog',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Card(
                  elevation: 0,
                  color: colors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colors.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AuthField(
                          controller: displayNameController,
                          label: 'Nom d\'affichage',
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Veuillez saisir votre nom';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Veuillez saisir votre e-mail';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: passwordController,
                          label: 'Mot de passe',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un mot de passe';
                            }

                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthField(
                          controller: verifyPasswordController,
                          label: 'Confirmer le mot de passe',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer le mot de passe';
                            }

                            if (value != passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  text: isLoading
                      ? 'Inscription...'
                      : 'S’inscrire',
                  onPressed: isLoading ? null : register,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go('/login'),
                  child: const Text(
                    'Déjà un compte ? Se connecter',
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