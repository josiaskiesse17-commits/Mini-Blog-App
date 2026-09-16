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
    final state = ref.watch(articleNotifierProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Créer un article'),
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
                            'Créer un article',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 28),
                          ArticleForm(
                            isLoading: state.isLoading,
                            onSubmit: (
                              title,
                              content,
                              imageId,
                            ) async {
                              if (currentUser == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vous devez être connecté pour créer un article.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final now = DateTime.now();

                              final article = Article(
                                id: '',
                                title: title,
                                content: content,
                                imageId: imageId,
                                authorId: currentUser.uid,
                                authorName:
                                    currentUser.displayName ?? '',
                                status: ArticleStatus.published,
                                createdAt: now,
                                updatedAt: now,
                                publishedAt: now,
                              );

                              final success = await ref
                                  .read(
                                    articleNotifierProvider.notifier,
                                  )
                                  .createArticle(article);

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Article créé avec succès !',
                                    ),
                                  ),
                                );

                                context.pop(true);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Impossible de créer l\'article.',
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