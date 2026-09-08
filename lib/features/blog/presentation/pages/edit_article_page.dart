import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../providers/article_provider.dart';
import '../widgets/article_form.dart';

class EditArticlePage extends StatelessWidget {
  final Article article;

  const EditArticlePage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();

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
            isLoading: provider.isLoading,
            onSubmit: (newTitle, newContent) async {
              // Création de l'article mis à jour
              final updatedArticle = Article(
                id: article.id,
                title: newTitle,
                content: newContent,
                authorId: article.authorId,
                authorName: article.authorName,
                createdAt: article.createdAt,
                updatedAt: DateTime.now(),
              );

              final success = await context.read<ArticleProvider>().updateArticle(updatedArticle);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article modifié avec succès !')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Erreur lors de la modification'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}