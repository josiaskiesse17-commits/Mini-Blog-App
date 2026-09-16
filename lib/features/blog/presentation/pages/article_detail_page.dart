import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/providers/article_repository_provider.dart';
import '../providers/article_notifier.dart';
import '../widgets/article_image.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(articleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Détails de l\'article'),
      ),
      body: FutureBuilder(
        future: repository.getArticle(articleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const _ArticleStateMessage(
              icon: Icons.cloud_off_outlined,
              message: 'Erreur lors du chargement de l\'article.',
            );
          }

          final result = snapshot.data;

          if (result == null) {
            return const _ArticleStateMessage(
              icon: Icons.article_outlined,
              message: 'Article introuvable.',
            );
          }

          final (article, failure) = result;

          if (failure != null || article == null) {
            return _ArticleStateMessage(
              icon: Icons.article_outlined,
              message: failure?.message ?? 'Article introuvable.',
            );
          }

          final currentUser = ref.watch(authStateProvider).value;

          final isOwner =
              currentUser != null && currentUser.uid == article.authorId;

          return _ArticleContent(
            article: article,
            isOwner: isOwner,
            onDelete: () => _deleteArticle(
              context,
              ref,
              article.id,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteArticle(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer l\'article'),
          content: const Text(
            'Voulez-vous vraiment supprimer cet article ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final deleted = await ref
        .read(articleNotifierProvider.notifier)
        .deleteArticle(id);

    if (!context.mounted) {
      return;
    }

    if (deleted) {
      context.go('/home');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Impossible de supprimer l\'article.',
        ),
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  const _ArticleContent({
    required this.article,
    required this.isOwner,
    required this.onDelete,
  });

  final dynamic article;
  final bool isOwner;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = isWide ? 32.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 980,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      isWide ? 24 : 18,
                    ),
                    child: ArticleImage(
                      imageId: article.imageId,
                      height: isWide ? 430 : 240,
                      borderRadius: 0,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor:
                              colors.primary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 19,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Par ${article.authorName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 20,
                      vertical: isWide ? 30 : 22,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      article.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: isWide ? 18 : 16,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(height: 24),
                    _OwnerActions(
                      onEdit: () {
                        context.push('/edit/${article.id}');
                      },
                      onDelete: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OwnerActions extends StatelessWidget {
  const _OwnerActions({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Modifier'),
            ),
            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleStateMessage extends StatelessWidget {
  const _ArticleStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}