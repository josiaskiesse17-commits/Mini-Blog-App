import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/article.dart';
import '../providers/article_notifier.dart';
import '../widgets/article_form.dart';

class CreateArticlePage extends ConsumerWidget {
  const CreateArticlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleState = ref.watch(articleNotifierProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ArticleForm(
            isLoading: articleState.isLoading,
            onSubmit: (title, content) async {
              final user = authState.value;

              if (user == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Vous devez être connecté pour créer un article.',
                      ),
                    ),
                  );
                }
                return;
              }

              final now = DateTime.now();

              final newArticle = Article(
                id: '',
                title: title,
                content: content,
                authorId: user.uid,
                authorName: user.displayName ?? 'Utilisateur',
                status: ArticleStatus.draft,
                createdAt: now,
                updatedAt: now,
              );

              final success = await ref
                  .read(articleNotifierProvider.notifier)
                  .createArticle(newArticle);

              if (!context.mounted) {
                return;
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Article créé avec succès !'),
                  ),
                );
                Navigator.of(context).pop();
              } else {
                final errorMessage =
                    ref.read(articleNotifierProvider).errorMessage ??
                    'Erreur lors de la création';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
