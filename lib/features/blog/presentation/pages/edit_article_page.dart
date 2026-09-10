import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../providers/article_notifier.dart';
import '../widgets/article_form.dart';

class EditArticlePage extends ConsumerWidget {
  final Article article;

  const EditArticlePage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleState = ref.watch(articleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ArticleForm(
            initialTitle: article.title,
            initialContent: article.content,
            isLoading: articleState.isLoading,
            onSubmit: (newTitle, newContent) async {
              final updatedArticle = article.copyWith(
                title: newTitle,
                content: newContent,
                updatedAt: DateTime.now(),
              );

              final success = await ref
                  .read(articleNotifierProvider.notifier)
                  .updateArticle(updatedArticle);

              if (!context.mounted) {
                return;
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Article modifié avec succès !'),
                  ),
                );
                Navigator.of(context).pop();
              } else {
                final errorMessage =
                    ref.read(articleNotifierProvider).errorMessage ??
                    'Erreur lors de la modification';

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