import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../providers/article_notifier.dart';
import '../widgets/article_form.dart';

class EditArticlePage extends ConsumerWidget {
  const EditArticlePage({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Modifier l\'article'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 16,
                isWide ? 32 : 20,
                isWide ? 32 : 16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        isWide ? 32 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modifier l\'article',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Modifiez les informations de votre article.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                          const SizedBox(height: 28),
                          ArticleForm(
                            isLoading: state.isLoading,
                            initialTitle: article.title,
                            initialContent: article.content,
                            initialImageId: article.imageId,
                            onSubmit: (
                              title,
                              content,
                              imageId,
                            ) async {
                              final updatedArticle =
                                  article.copyWith(
                                title: title,
                                content: content,
                                imageId: imageId,
                                updatedAt: DateTime.now(),
                              );

                              final success = await ref
                                  .read(
                                    articleNotifierProvider
                                        .notifier,
                                  )
                                  .updateArticle(updatedArticle);

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Article modifié avec succès !',
                                    ),
                                  ),
                                );

                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Impossible de modifier l\'article.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}