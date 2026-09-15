import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ),
              child: ArticleForm(
                isLoading: articleState.isLoading,
                onSubmit: (title, content, imageId) async {
                  final user = authState.value;

                  if (user == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vous devez être connecté pour créer '
                            'un article.',
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
                    status: ArticleStatus.published,
                    createdAt: now,
                    updatedAt: now,
                    imageId: imageId,
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

                    context.pop(true);
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
        ),
      ),
    );
  }
}