import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_provider.dart';
import '../providers/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = user?.displayName?.trim();

    final displayName =
        name?.isNotEmpty == true ? name! : 'Utilisateur';

    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Mon compte'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary,
                        colors.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.onPrimary,
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user?.email ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onPrimary.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              colors.primary.withValues(alpha: 0.10),
                          child: Icon(
                            Icons.lock_reset_outlined,
                            color: colors.primary,
                          ),
                        ),
                        title: const Text(
                          'Modifier le mot de passe',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Sécurisez votre compte',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: () {
                          context.push('/change-password');
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        secondary: CircleAvatar(
                          backgroundColor:
                              colors.primary.withValues(alpha: 0.10),
                          child: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: colors.primary,
                          ),
                        ),
                        title: const Text(
                          'Thème sombre',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          themeMode == ThemeMode.dark
                              ? 'Le thème sombre est activé'
                              : 'Le thème clair est activé',
                        ),
                        value: themeMode == ThemeMode.dark,
                        onChanged: (_) {
                          ref
                              .read(themeProvider.notifier)
                              .toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signOut();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Se déconnecter'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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