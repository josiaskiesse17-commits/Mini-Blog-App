import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../providers/article_provider.dart';
import '../widgets/article_form.dart';

class CreateArticlePage extends StatelessWidget {
  const CreateArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ArticleForm(
            isLoading: provider.isLoading,
            onSubmit: (title, content) async {
              // Construction du nouvel article
              final newArticle = Article(
                id: DateTime.now().millisecondsSinceEpoch.toString(), // Identifiant temporaire en attendant Firestore
                title: title,
                content: content,
                authorId: 'temp_user_id', // Sera remplacé plus tard par l'utilisateur connecté via la branche Auth
                authorName: 'Auteur',      // Sera remplacé plus tard via Auth
                createdAt: DateTime.now(),
              );

              // Appel au Provider pour déclencher le UseCase CreateArticle
              final success = await context.read<ArticleProvider>().createArticle(newArticle);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article créé avec succès !')),
                  );
                  Navigator.of(context).pop(); // Ferme la page après la création
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Erreur lors de la création'),
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