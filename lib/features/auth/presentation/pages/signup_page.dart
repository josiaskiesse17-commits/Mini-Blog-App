import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    await ref.read(authNotifierProvider.notifier).signUp(
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthField(
                  controller: displayNameController,
                  label: 'Nom d\'affichage',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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

                const SizedBox(height: 24),

                AuthGradientButton(
                  text: authState.isLoading
                      ? 'Inscription...'
                      : 'S’inscrire',
                  onPressed: authState.isLoading ? null : register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
