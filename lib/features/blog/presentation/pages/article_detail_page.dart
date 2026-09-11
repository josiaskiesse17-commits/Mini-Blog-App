import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/article_repository_provider.dart';
import '../providers/article_notifier.dart';
import 'edit_article_page.dart';

class ArticleDetailPage extends ConsumerWidget {
  final String articleId;

  const ArticleDetailPage({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(articleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Erreur lors du chargement de l\'article.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final result = snapshot.data;

          if (result == null) {
            return const Center(
              child: Text('Article introuvable.'),
            );
          }

          final (article, failure) = result;

          if (failure != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  failure.message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (article == null) {
            return const Center(
              child: Text('Article introuvable.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Par ${article.authorName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  article.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),

                // Boutons d'action : Modifier et Supprimer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditArticlePage(article: article),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Boîte de dialogue de confirmation
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer l\'article'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cet article ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final success = await ref
                              .read(articleNotifierProvider.notifier)
                              .deleteArticle(article.id);

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Article supprimé avec succès'),
                                ),
                              );
                              Navigator.of(context).pop(); // Retour à la liste
                            } else {
                              final errorMessage = ref
                                      .read(articleNotifierProvider)
                                      .errorMessage ??
                                  'Erreur lors de la suppression';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}