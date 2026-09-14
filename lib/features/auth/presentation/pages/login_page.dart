import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_gradient_button.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authNotifierProvider.notifier).signIn(
          email: emailController.text.trim(),
          password: passwordController.text,
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final authState = ref.watch(authNotifierProvider);

  return Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 500,
  ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 70,
                ),

                const SizedBox(height: 24),

                Text(
                  'Bienvenue sur MiniBlog',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Connectez-vous pour accéder à votre espace',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                AuthField(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                      return 'Veuillez saisir votre mot de passe';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AuthGradientButton(
                  text: authState.isLoading
                      ? 'Connexion...'
                      : 'Se connecter',
                  onPressed: authState.isLoading ? null : login,
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    // Navigation vers l'inscription à ajouter ensuite.
                     context.go('/signup');
                  },
                  child: const Text(
                    'Créer un compte',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    )
  );
}
}